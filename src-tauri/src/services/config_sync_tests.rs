use crate::adapters::{DatabaseAdapter, Message, NetworkAdapter};
use crate::domain::{Event, LightColor, LightConfig, PeerId};
use crate::services::test_utils::MockDatabaseAdapter;
use crate::services::{ConfigService, MessageContext, message_handler};
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::{RwLock, broadcast};
use tokio::time::{Duration, sleep};

#[tokio::test]
async fn test_config_sync_disables_active_light_on_remote_peer() {
    // Setup Peer 1 (Alice) - will delete a light definition
    let peer1_id = PeerId::new("alice");
    let database1 = Arc::new(MockDatabaseAdapter::new());

    // Setup Peer 2 (Bob) - has that light active
    let peer2_id = PeerId::new("bob");
    let database2 = Arc::new(MockDatabaseAdapter::new());

    // Create config services
    let config_service1 = Arc::new(
        ConfigService::new(database1.clone(), &peer1_id)
            .await
            .expect("Failed to create config service 1"),
    );

    let config_service2 = Arc::new(
        ConfigService::new(database2.clone(), &peer2_id)
            .await
            .expect("Failed to create config service 2"),
    );

    // Get initial config for both peers
    let mut config1 = config_service1.get_config().await;
    let config2 = config_service2.get_config().await;

    println!("Initial config1 definitions: {}", config1.definitions.len());
    println!("Initial config2 definitions: {}", config2.definitions.len());

    // Find the Red light definition
    let red_def = config1
        .definitions
        .iter()
        .find(|d| d.color == LightColor::Red)
        .cloned();
    assert!(red_def.is_some(), "Red light definition should exist");

    println!("Found Red light definition");

    // Peer 2 (Bob) activates Red light
    // First, save Bob as a peer
    let bob_peer = crate::domain::PeerInfo::new(
        peer2_id.clone(),
        "Bob".to_string(),
        crate::domain::LightState::new(LightColor::Off, crate::domain::VectorClock::new(), 0),
    );
    database2
        .save_my_peer(&bob_peer)
        .await
        .expect("Failed to save Bob");

    let red_state = crate::domain::LightState::new(
        LightColor::Red,
        crate::domain::VectorClock::new(),
        crate::domain::current_timestamp_secs(),
    );
    database2
        .update_my_light_state(&red_state)
        .await
        .expect("Failed to set Bob's state");

    let bob_state_before = database2
        .get_my_peer()
        .await
        .expect("Failed to get Bob's state");
    assert_eq!(
        bob_state_before.light_state.color,
        LightColor::Red,
        "Bob should have Red light active"
    );
    println!(
        "Bob's light before config sync: {:?}",
        bob_state_before.light_state.color
    );

    // Give time for Bob's config to stabilize its timestamps
    sleep(Duration::from_millis(100)).await;

    // Peer 1 (Alice) marks Red light as deleted (tombstone)
    // Use a future timestamp to ensure it's newer than Bob's
    let future_timestamp = crate::domain::current_timestamp_secs() + 10;
    if let Some(def) = config1
        .definitions
        .iter_mut()
        .find(|d| d.color == LightColor::Red)
    {
        def.deleted_at = Some(future_timestamp);
        def.updated_at = future_timestamp;
        println!(
            "Alice's Red definition: updated_at={}, deleted_at={:?}",
            def.updated_at, def.deleted_at
        );
    }

    config_service1
        .update_config(config1.clone())
        .await
        .expect("Failed to update config");

    println!("Alice marked Red as deleted, broadcasting config sync...");

    // Create message context for Peer 2 with config service
    let (event_tx2, mut event_rx2) = broadcast::channel(100);
    let peers2 = Arc::new(RwLock::new(HashMap::new()));

    let ctx2 = MessageContext::new(
        database2.clone(),
        peers2.clone(),
        event_tx2.clone(),
        peer2_id.clone(),
    )
    .with_config_service(config_service2.clone());

    // Create a mock network adapter for the message handler
    struct MockNetwork;

    #[async_trait::async_trait]
    impl NetworkAdapter for MockNetwork {
        async fn start(&self) -> crate::adapters::Result<()> {
            Ok(())
        }
        async fn stop(&self) -> crate::adapters::Result<()> {
            Ok(())
        }
        async fn broadcast(&self, _message: Message) -> crate::adapters::Result<()> {
            println!("MockNetwork: broadcast called");
            Ok(())
        }
        async fn send_to_peer(
            &self,
            _peer_id: &PeerId,
            _message: Message,
        ) -> crate::adapters::Result<()> {
            Ok(())
        }
        async fn receive(&self) -> crate::adapters::Result<(PeerId, Message)> {
            tokio::time::sleep(Duration::from_secs(1000)).await;
            unreachable!()
        }
        async fn get_connected_peers(&self) -> crate::adapters::Result<Vec<PeerId>> {
            Ok(vec![])
        }
    }

    let network2 = Arc::new(MockNetwork);

    // Simulate Alice sending LightConfigSync to Bob
    let sync_message = Message::LightConfigSync {
        config: config1.clone(),
    };

    println!("Calling handle_message for Bob...");
    message_handler::handle_message(
        &peer2_id,
        peer1_id.clone(),
        sync_message,
        &ctx2,
        network2.clone(),
    )
    .await
    .expect("Failed to handle config sync message");

    println!("handle_message completed, checking Bob's state...");

    // Give a moment for async operations to complete
    sleep(Duration::from_millis(100)).await;

    // Verify Bob's light was turned off
    let bob_state_after = database2
        .get_my_peer()
        .await
        .expect("Failed to get Bob's state");
    println!(
        "Bob's light after config sync: {:?}",
        bob_state_after.light_state.color
    );

    assert_eq!(
        bob_state_after.light_state.color,
        LightColor::Off,
        "Bob's light should be turned off after receiving config with deleted Red"
    );

    // Verify Bob's config was updated with the tombstone
    let bob_config = config_service2.get_config().await;
    let bob_red_def = bob_config
        .definitions
        .iter()
        .find(|d| d.color == LightColor::Red);
    assert!(
        bob_red_def.is_some(),
        "Red definition should still exist (as tombstone)"
    );
    assert!(
        bob_red_def.unwrap().deleted_at.is_some(),
        "Red definition should be marked as deleted"
    );

    // Verify Bob can't see Red in enabled definitions
    let enabled = bob_config.enabled_definitions();
    assert!(
        !enabled.iter().any(|d| d.color == LightColor::Red),
        "Red should not appear in enabled definitions"
    );

    // Check for events
    let mut my_state_changed = false;
    let mut config_changed = false;

    // Try to receive events (non-blocking)
    while let Ok(event) = event_rx2.try_recv() {
        match event {
            Event::MyStateChanged { state } => {
                println!("Event received: MyStateChanged - color: {:?}", state.color);
                assert_eq!(state.color, LightColor::Off);
                my_state_changed = true;
            }
            Event::LightConfigChanged { .. } => {
                println!("Event received: LightConfigChanged");
                config_changed = true;
            }
            _ => {}
        }
    }

    assert!(
        my_state_changed,
        "MyStateChanged event should have been emitted"
    );
    assert!(
        config_changed,
        "LightConfigChanged event should have been emitted"
    );

    println!("✅ Test passed! Bob's light was turned off and config was synced with tombstone");
}

#[tokio::test]
async fn test_config_sync_with_no_active_light() {
    // Test that config sync works when peer doesn't have the deleted light active
    let peer1_id = PeerId::new("alice");
    let peer2_id = PeerId::new("bob");
    let database2 = Arc::new(MockDatabaseAdapter::new());

    let config_service2 = Arc::new(
        ConfigService::new(database2.clone(), &peer2_id)
            .await
            .expect("Failed to create config service"),
    );

    // Bob has Green light active (not Red)
    let bob_peer = crate::domain::PeerInfo::new(
        peer2_id.clone(),
        "Bob".to_string(),
        crate::domain::LightState::new(LightColor::Off, crate::domain::VectorClock::new(), 0),
    );
    database2
        .save_my_peer(&bob_peer)
        .await
        .expect("Failed to save Bob");

    let green_state = crate::domain::LightState::new(
        LightColor::Green,
        crate::domain::VectorClock::new(),
        crate::domain::current_timestamp_secs(),
    );
    database2
        .update_my_light_state(&green_state)
        .await
        .expect("Failed to set state");

    // Create config with Red deleted
    let mut config = LightConfig::default_config(peer1_id.as_str());
    let future_timestamp = crate::domain::current_timestamp_secs() + 10;
    if let Some(def) = config
        .definitions
        .iter_mut()
        .find(|d| d.color == LightColor::Red)
    {
        def.deleted_at = Some(future_timestamp);
        def.updated_at = future_timestamp;
    }

    let (event_tx, _event_rx) = broadcast::channel(100);
    let peers = Arc::new(RwLock::new(HashMap::new()));
    let ctx = MessageContext::new(database2.clone(), peers, event_tx, peer2_id.clone())
        .with_config_service(config_service2.clone());

    struct MockNetwork;
    #[async_trait::async_trait]
    impl NetworkAdapter for MockNetwork {
        async fn start(&self) -> crate::adapters::Result<()> {
            Ok(())
        }
        async fn stop(&self) -> crate::adapters::Result<()> {
            Ok(())
        }
        async fn broadcast(&self, _message: Message) -> crate::adapters::Result<()> {
            Ok(())
        }
        async fn send_to_peer(
            &self,
            _peer_id: &PeerId,
            _message: Message,
        ) -> crate::adapters::Result<()> {
            Ok(())
        }
        async fn receive(&self) -> crate::adapters::Result<(PeerId, Message)> {
            tokio::time::sleep(Duration::from_secs(1000)).await;
            unreachable!()
        }
        async fn get_connected_peers(&self) -> crate::adapters::Result<Vec<PeerId>> {
            Ok(vec![])
        }
    }

    let network = Arc::new(MockNetwork);

    let sync_message = Message::LightConfigSync { config };
    message_handler::handle_message(&peer2_id, peer1_id, sync_message, &ctx, network)
        .await
        .expect("Failed to handle message");

    sleep(Duration::from_millis(100)).await;

    // Bob's light should still be Green (not affected)
    let bob_state = database2.get_my_peer().await.expect("Failed to get state");
    assert_eq!(
        bob_state.light_state.color,
        LightColor::Green,
        "Bob's Green light should remain active"
    );

    // But config should be updated
    let bob_config = config_service2.get_config().await;
    let red_def = bob_config
        .definitions
        .iter()
        .find(|d| d.color == LightColor::Red);
    assert!(
        red_def.unwrap().deleted_at.is_some(),
        "Red should be marked as deleted"
    );

    println!("✅ Test passed! Config synced without affecting different active light");
}

#[tokio::test]
async fn test_offline_peer_catches_up() {
    // Test that an offline peer correctly syncs deleted definitions when it comes back
    let peer1_id = PeerId::new("alice");
    let peer2_id = PeerId::new("bob");

    let database1 = Arc::new(MockDatabaseAdapter::new());
    let database2 = Arc::new(MockDatabaseAdapter::new());

    let config_service1 = Arc::new(
        ConfigService::new(database1.clone(), &peer1_id)
            .await
            .expect("Failed to create config"),
    );

    let config_service2 = Arc::new(
        ConfigService::new(database2.clone(), &peer2_id)
            .await
            .expect("Failed to create config"),
    );

    // Both peers start with same config
    let initial_config = config_service1.get_config().await;
    assert_eq!(
        initial_config.definitions.len(),
        6,
        "Should have 6 default light definitions"
    );

    // Initialize Bob's peer
    let bob_peer = crate::domain::PeerInfo::new(
        peer2_id.clone(),
        "Bob".to_string(),
        crate::domain::LightState::new(LightColor::Off, crate::domain::VectorClock::new(), 0),
    );
    database2
        .save_my_peer(&bob_peer)
        .await
        .expect("Failed to save Bob");

    // Bob goes offline (we simulate this by not processing messages)

    // Alice deletes Red while Bob is offline
    let mut alice_config = config_service1.get_config().await;
    let future_timestamp = crate::domain::current_timestamp_secs() + 10;
    if let Some(def) = alice_config
        .definitions
        .iter_mut()
        .find(|d| d.color == LightColor::Red)
    {
        def.deleted_at = Some(future_timestamp);
        def.updated_at = future_timestamp;
    }
    config_service1
        .update_config(alice_config.clone())
        .await
        .expect("Failed to update");

    // Bob comes back online and receives the config
    let (event_tx, _) = broadcast::channel(100);
    let peers = Arc::new(RwLock::new(HashMap::new()));
    let ctx = MessageContext::new(database2.clone(), peers, event_tx, peer2_id.clone())
        .with_config_service(config_service2.clone());

    struct MockNetwork;
    #[async_trait::async_trait]
    impl NetworkAdapter for MockNetwork {
        async fn start(&self) -> crate::adapters::Result<()> {
            Ok(())
        }
        async fn stop(&self) -> crate::adapters::Result<()> {
            Ok(())
        }
        async fn broadcast(&self, _message: Message) -> crate::adapters::Result<()> {
            Ok(())
        }
        async fn send_to_peer(
            &self,
            _peer_id: &PeerId,
            _message: Message,
        ) -> crate::adapters::Result<()> {
            Ok(())
        }
        async fn receive(&self) -> crate::adapters::Result<(PeerId, Message)> {
            tokio::time::sleep(Duration::from_secs(1000)).await;
            unreachable!()
        }
        async fn get_connected_peers(&self) -> crate::adapters::Result<Vec<PeerId>> {
            Ok(vec![])
        }
    }

    let network = Arc::new(MockNetwork);

    // Bob receives config sync
    let sync_message = Message::LightConfigSync {
        config: alice_config,
    };
    message_handler::handle_message(&peer2_id, peer1_id, sync_message, &ctx, network)
        .await
        .expect("Failed to handle message");

    sleep(Duration::from_millis(100)).await;

    // Verify Bob's config has the deleted Red
    let bob_config = config_service2.get_config().await;
    let red_def = bob_config
        .definitions
        .iter()
        .find(|d| d.color == LightColor::Red);
    assert!(
        red_def.is_some(),
        "Red definition should exist as tombstone"
    );
    assert!(
        red_def.unwrap().deleted_at.is_some(),
        "Red should be marked as deleted"
    );

    // Verify Red doesn't show in enabled definitions
    let enabled = bob_config.enabled_definitions();
    assert!(
        !enabled.iter().any(|d| d.color == LightColor::Red),
        "Red should not be in enabled list"
    );

    println!("✅ Test passed! Offline peer caught up with deleted definition");
}

#[tokio::test]
async fn test_new_peer_joins_existing_network_with_custom_config() {
    // Test that a new peer joining an existing network adopts the network's config
    // instead of overwriting it with its default config

    // Peer 1 (Alice) - existing peer with custom config
    let peer1_id = PeerId::new("alice");
    let database1 = Arc::new(MockDatabaseAdapter::new());
    let config_service1 = Arc::new(
        ConfigService::new(database1.clone(), &peer1_id)
            .await
            .expect("Failed to create config"),
    );

    // Alice has been running for a while and has customized her config
    let mut alice_config = config_service1.get_config().await;

    // Customize: disable Yellow, rename Green
    let timestamp = crate::domain::current_timestamp_secs();
    if let Some(yellow) = alice_config
        .definitions
        .iter_mut()
        .find(|d| d.color == LightColor::Yellow)
    {
        yellow.enabled = false;
        yellow.updated_at = timestamp;
    }
    if let Some(green) = alice_config
        .definitions
        .iter_mut()
        .find(|d| d.color == LightColor::Green)
    {
        green.name = "Available Now".to_string();
        green.updated_at = timestamp;
    }
    alice_config.version = 5; // Alice has been using this config for a while

    config_service1
        .update_config(alice_config.clone())
        .await
        .expect("Failed to update Alice's config");

    println!(
        "Alice's customized config: {} definitions, version {}",
        alice_config.definitions.len(),
        alice_config.version
    );
    println!(
        "  Yellow enabled: {}",
        alice_config
            .definitions
            .iter()
            .find(|d| d.color == LightColor::Yellow)
            .unwrap()
            .enabled
    );
    println!(
        "  Green name: {}",
        alice_config
            .definitions
            .iter()
            .find(|d| d.color == LightColor::Green)
            .unwrap()
            .name
    );

    // Peer 2 (Bob) - brand new peer joining the network
    let peer2_id = PeerId::new("bob");
    let database2 = Arc::new(MockDatabaseAdapter::new());

    // Initialize Bob's peer
    let bob_peer = crate::domain::PeerInfo::new(
        peer2_id.clone(),
        "Bob".to_string(),
        crate::domain::LightState::new(LightColor::Off, crate::domain::VectorClock::new(), 0),
    );
    database2
        .save_my_peer(&bob_peer)
        .await
        .expect("Failed to save Bob");

    // Bob creates config service (gets default config with version 1)
    let config_service2 = Arc::new(
        ConfigService::new(database2.clone(), &peer2_id)
            .await
            .expect("Failed to create config"),
    );

    let bob_initial_config = config_service2.get_config().await;
    println!(
        "Bob's initial default config: {} definitions, version {}",
        bob_initial_config.definitions.len(),
        bob_initial_config.version
    );
    assert_eq!(
        bob_initial_config.version, 1,
        "Bob should start with version 1"
    );
    assert!(
        bob_initial_config
            .definitions
            .iter()
            .find(|d| d.color == LightColor::Yellow)
            .unwrap()
            .enabled,
        "Bob's default should have Yellow enabled"
    );

    // Bob receives Alice's config via sync
    let (event_tx, _) = broadcast::channel(100);
    let peers = Arc::new(RwLock::new(HashMap::new()));
    let ctx = MessageContext::new(database2.clone(), peers, event_tx, peer2_id.clone())
        .with_config_service(config_service2.clone());

    struct MockNetwork;
    #[async_trait::async_trait]
    impl NetworkAdapter for MockNetwork {
        async fn start(&self) -> crate::adapters::Result<()> {
            Ok(())
        }
        async fn stop(&self) -> crate::adapters::Result<()> {
            Ok(())
        }
        async fn broadcast(&self, _message: Message) -> crate::adapters::Result<()> {
            Ok(())
        }
        async fn send_to_peer(
            &self,
            _peer_id: &PeerId,
            _message: Message,
        ) -> crate::adapters::Result<()> {
            Ok(())
        }
        async fn receive(&self) -> crate::adapters::Result<(PeerId, Message)> {
            tokio::time::sleep(Duration::from_secs(1000)).await;
            unreachable!()
        }
        async fn get_connected_peers(&self) -> crate::adapters::Result<Vec<PeerId>> {
            Ok(vec![])
        }
    }

    let network = Arc::new(MockNetwork);

    // Bob receives Alice's customized config
    let sync_message = Message::LightConfigSync {
        config: alice_config.clone(),
    };
    message_handler::handle_message(&peer2_id, peer1_id.clone(), sync_message, &ctx, network)
        .await
        .expect("Failed to handle message");

    sleep(Duration::from_millis(100)).await;

    // Verify Bob adopted Alice's config (not the other way around)
    let bob_final_config = config_service2.get_config().await;
    println!(
        "Bob's final config after sync: {} definitions, version {}",
        bob_final_config.definitions.len(),
        bob_final_config.version
    );

    assert_eq!(
        bob_final_config.version, 5,
        "Bob should adopt Alice's version 5"
    );

    let bob_yellow = bob_final_config
        .definitions
        .iter()
        .find(|d| d.color == LightColor::Yellow)
        .unwrap();
    assert!(
        !bob_yellow.enabled,
        "Bob should have Yellow disabled (from Alice's config)"
    );

    let bob_green = bob_final_config
        .definitions
        .iter()
        .find(|d| d.color == LightColor::Green)
        .unwrap();
    assert_eq!(
        bob_green.name, "Available Now",
        "Bob should have Alice's custom Green name"
    );

    // Critical: Alice's config should NOT be affected by Bob joining
    let alice_final_config = config_service1.get_config().await;
    assert_eq!(
        alice_final_config.version, 5,
        "Alice's version should remain 5"
    );
    assert!(
        !alice_final_config
            .definitions
            .iter()
            .find(|d| d.color == LightColor::Yellow)
            .unwrap()
            .enabled,
        "Alice's Yellow should still be disabled"
    );

    println!("✅ Test passed! New peer adopted existing network config without disrupting it");
}
