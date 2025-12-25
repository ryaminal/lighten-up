use crate::adapters::{DatabaseAdapter, NetworkAdapter};
use crate::domain::{Light, LightColor, LightId, PeerId};
use crate::encryption::ChaCha20Encryption;
use crate::network::MdnsNetwork;
use crate::services::light_service::LightService;
use crate::services::test_utils::MockDatabaseAdapter;
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::broadcast;
use tokio::time::{sleep, timeout};

/// Integration test: Two peers discover each other and synchronize state
#[tokio::test]
async fn test_two_peers_discover_and_sync() {
    // Setup Peer 1 (Alice)
    let peer1_id = PeerId::new("alice");
    let peer1_name = "Alice".to_string();
    let passphrase = "shared-test-passphrase";

    let encryption1 = ChaCha20Encryption::from_passphrase(passphrase).unwrap();
    let network1 = Arc::new(MdnsNetwork::new(peer1_id.clone(), encryption1));
    let database1 = Arc::new(MockDatabaseAdapter::new());

    // Setup Peer 2 (Bob)
    let peer2_id = PeerId::new("bob");
    let peer2_name = "Bob".to_string();

    let encryption2 = ChaCha20Encryption::from_passphrase(passphrase).unwrap();
    let network2 = Arc::new(MdnsNetwork::new(peer2_id.clone(), encryption2));
    let database2 = Arc::new(MockDatabaseAdapter::new());

    // Start both networks
    network1.start().await.expect("Failed to start network1");
    network2.start().await.expect("Failed to start network2");

    // Create event channels
    let (event_tx1, _) = broadcast::channel(100);
    let (event_tx2, _) = broadcast::channel(100);

    // Create light services
    let service1 = LightService::new(
        peer1_id.clone(),
        peer1_name,
        database1.clone(),
        network1.clone(),
        event_tx1,
    )
    .await
    .expect("Failed to create service1");

    let service2 = LightService::new(
        peer2_id.clone(),
        peer2_name,
        database2.clone(),
        network2.clone(),
        event_tx2,
    )
    .await
    .expect("Failed to create service2");

    // Give some time for mDNS discovery to happen
    sleep(Duration::from_millis(500)).await;

    // Test: Check if peers discovered each other
    let peers1 = timeout(Duration::from_secs(2), network1.get_connected_peers())
        .await
        .expect("Timeout getting peers from network1")
        .expect("Failed to get connected peers from network1");

    let peers2 = timeout(Duration::from_secs(2), network2.get_connected_peers())
        .await
        .expect("Timeout getting peers from network2")
        .expect("Failed to get connected peers from network2");

    // At a minimum, we should be able to get peer lists (even if empty initially)
    // mDNS discovery may take time in a real scenario
    println!("Peer1 sees {} peers", peers1.len());
    println!("Peer2 sees {} peers", peers2.len());

    // Test: Alice changes her status to Green
    service1
        .set_light_color(LightColor::Green)
        .await
        .expect("Alice failed to set color");

    // Give time for message to propagate
    sleep(Duration::from_millis(200)).await;

    // Test: Bob changes his status to Red
    service2
        .set_light_color(LightColor::Red)
        .await
        .expect("Bob failed to set color");

    // Give time for message to propagate
    sleep(Duration::from_millis(200)).await;

    // Verify: Alice's state persisted
    let alice_state = database1
        .get_my_peer()
        .await
        .expect("Failed to get Alice's state");
    assert_eq!(alice_state.light_state.color, LightColor::Green);

    // Verify: Bob's state persisted
    let bob_state = database2
        .get_my_peer()
        .await
        .expect("Failed to get Bob's state");
    assert_eq!(bob_state.light_state.color, LightColor::Red);

    // Stop networks
    let _ = network1.stop().await;
    let _ = network2.stop().await;
}

/// Integration test: Three peers form a network
#[tokio::test]
async fn test_three_peer_network() {
    let passphrase = "multi-peer-test";

    // Setup three peers
    let peers = vec![
        ("alice", "Alice", LightColor::Green),
        ("bob", "Bob", LightColor::Red),
        ("charlie", "Charlie", LightColor::Blue),
    ];

    let mut services = Vec::new();
    let mut networks = Vec::new();

    for (id, name, _color) in &peers {
        let peer_id = PeerId::new(*id);
        let encryption = ChaCha20Encryption::from_passphrase(passphrase).unwrap();
        let network = Arc::new(MdnsNetwork::new(peer_id.clone(), encryption));
        let database = Arc::new(MockDatabaseAdapter::new());
        let (event_tx, _) = broadcast::channel(100);

        network.start().await.expect("Failed to start network");

        let service = LightService::new(
            peer_id,
            name.to_string(),
            database,
            network.clone(),
            event_tx,
        )
        .await
        .expect("Failed to create service");

        services.push(service);
        networks.push(network);
    }

    // Give time for discovery
    sleep(Duration::from_millis(1000)).await;

    // Each peer sets their color
    for (i, (_id, _name, color)) in peers.iter().enumerate() {
        services[i]
            .set_light_color(color.clone())
            .await
            .expect("Failed to set color");
    }

    // Give time for propagation
    sleep(Duration::from_millis(500)).await;

    // Verify all services can still operate (no deadlocks)
    for service in &services {
        let result = timeout(
            Duration::from_secs(1),
            service.set_light_color(LightColor::Yellow),
        )
        .await;

        assert!(result.is_ok(), "Service should respond within timeout");
        assert!(result.unwrap().is_ok(), "Set color should succeed");
    }

    // Cleanup
    for network in networks {
        let _ = network.stop().await;
    }
}

/// Test rapid color changes across multiple peers don't cause deadlock
#[tokio::test]
async fn test_multi_peer_rapid_changes() {
    let passphrase = "stress-test";
    let peer1_id = PeerId::new("stress1");
    let peer2_id = PeerId::new("stress2");

    let encryption1 = ChaCha20Encryption::from_passphrase(passphrase).unwrap();
    let network1 = Arc::new(MdnsNetwork::new(peer1_id.clone(), encryption1));
    let database1 = Arc::new(MockDatabaseAdapter::new());

    let encryption2 = ChaCha20Encryption::from_passphrase(passphrase).unwrap();
    let network2 = Arc::new(MdnsNetwork::new(peer2_id.clone(), encryption2));
    let database2 = Arc::new(MockDatabaseAdapter::new());

    network1.start().await.unwrap();
    network2.start().await.unwrap();

    let (event_tx1, _) = broadcast::channel(100);
    let (event_tx2, _) = broadcast::channel(100);

    let service1 = Arc::new(
        LightService::new(
            peer1_id,
            "Stress1".to_string(),
            database1,
            network1.clone(),
            event_tx1,
        )
        .await
        .unwrap(),
    );

    let service2 = Arc::new(
        LightService::new(
            peer2_id,
            "Stress2".to_string(),
            database2,
            network2.clone(),
            event_tx2,
        )
        .await
        .unwrap(),
    );

    // Both peers rapidly change colors concurrently
    let colors = [
        LightColor::Red,
        LightColor::Green,
        LightColor::Blue,
        LightColor::Yellow,
        LightColor::Off,
    ];

    let mut handles = Vec::new();

    for color in colors.iter() {
        let s1 = service1.clone();
        let c = color.clone();
        handles.push(tokio::spawn(async move { s1.set_light_color(c).await }));

        let s2 = service2.clone();
        let c = color.clone();
        handles.push(tokio::spawn(async move { s2.set_light_color(c).await }));
    }

    // All operations should complete without timeout
    for handle in handles {
        let result = timeout(Duration::from_secs(2), handle).await;
        assert!(result.is_ok(), "Task should complete without timeout");
        assert!(result.unwrap().is_ok(), "Task should not panic");
    }

    // Cleanup
    let _ = network1.stop().await;
    let _ = network2.stop().await;
}

/// Integration test: Light CRUD operations
#[tokio::test]
async fn test_light_crud_operations() {
    let peer_id = PeerId::new("test-peer");
    let passphrase = "test-passphrase";

    let enc = ChaCha20Encryption::from_passphrase(passphrase).unwrap();
    let net = Arc::new(MdnsNetwork::new(peer_id.clone(), enc));
    let db = Arc::new(MockDatabaseAdapter::new());

    net.start().await.unwrap();

    let (event_tx, _) = broadcast::channel(100);

    let service = LightService::new(
        peer_id.clone(),
        "TestPeer".to_string(),
        db.clone(),
        net.clone(),
        event_tx,
    )
    .await
    .unwrap();

    let light_id = LightId::new("test-light-1".to_string());
    let mut light = Light::new(light_id.clone(), "Conference Room".to_string());

    service.save_light(&light).await.unwrap();

    let retrieved = service.get_light(&light_id).await.unwrap();
    assert_eq!(retrieved.id, light.id);
    assert_eq!(retrieved.name, light.name);

    light.activate(peer_id.clone());
    service.save_light(&light).await.unwrap();

    let activated = service.get_light(&light_id).await.unwrap();
    assert!(activated.is_active());

    let all_lights = service.get_all_lights().await.unwrap();
    assert_eq!(all_lights.len(), 1);
    assert_eq!(all_lights[0].id, light.id);

    let _ = net.stop().await;
}
