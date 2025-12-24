use crate::adapters::DatabaseAdapter;
use crate::domain::{LightColor, PeerId};
use crate::services::light_service::LightService;
use crate::services::test_utils::{MockDatabaseAdapter, MockNetworkAdapter};
use std::sync::Arc;

#[tokio::test]
async fn test_set_light_color_end_to_end() {
    // Setup
    let peer_id = PeerId::new("test-peer");
    let peer_name = "Test User".to_string();
    let database = Arc::new(MockDatabaseAdapter::new());
    let network = Arc::new(MockNetworkAdapter::new());

    // Create light service
    let service = LightService::new(
        peer_id.clone(),
        peer_name.clone(),
        database.clone(),
        network.clone(),
    )
    .await
    .unwrap();

    // Test: Change light color to Green
    let result = service.set_light_color(LightColor::Green).await;
    assert!(result.is_ok(), "set_light_color should succeed");

    // Verify: State was updated in database
    let updated_peer = database.get_my_peer().await.unwrap();
    assert_eq!(
        updated_peer.light_state.color,
        LightColor::Green,
        "Color should be updated to Green"
    );
    assert_eq!(updated_peer.name, peer_name, "Name should remain unchanged");

    // Verify: Message was broadcast to network
    let sent_messages = network.get_sent_messages().await;
    assert_eq!(
        sent_messages.len(),
        1,
        "Should broadcast exactly one message"
    );

    // Test: Change color multiple times rapidly (no deadlock)
    for color in [LightColor::Red, LightColor::Yellow, LightColor::Blue] {
        let result = service.set_light_color(color).await;
        assert!(result.is_ok(), "Rapid color changes should not deadlock");
    }

    // Verify: Final state is Blue
    let final_peer = database.get_my_peer().await.unwrap();
    assert_eq!(final_peer.light_state.color, LightColor::Blue);

    // Verify: Vector clock increased with each change
    // We changed colors 4 times (Green, Red, Yellow, Blue), so timestamp should be > 0
    assert!(
        final_peer.light_state.timestamp > 0,
        "Timestamp should be set for state changes"
    );
}

#[tokio::test]
async fn test_concurrent_light_color_changes() {
    // Test that multiple concurrent set_light_color calls don't deadlock
    let peer_id = PeerId::new("concurrent-test-peer");
    let database = Arc::new(MockDatabaseAdapter::new());
    let network = Arc::new(MockNetworkAdapter::new());

    let service = Arc::new(
        LightService::new(
            peer_id.clone(),
            "Test".to_string(),
            database.clone(),
            network.clone(),
        )
        .await
        .unwrap(),
    );

    // Spawn multiple concurrent tasks
    let mut handles = vec![];
    let colors = vec![
        LightColor::Red,
        LightColor::Green,
        LightColor::Blue,
        LightColor::Yellow,
    ];

    for color in colors {
        let service_clone = service.clone();
        let handle = tokio::spawn(async move { service_clone.set_light_color(color).await });
        handles.push(handle);
    }

    // All tasks should complete without deadlock
    for handle in handles {
        let result = handle.await;
        assert!(result.is_ok(), "Task should complete");
        assert!(result.unwrap().is_ok(), "set_light_color should succeed");
    }

    // Verify: All messages were sent
    let sent_messages = network.get_sent_messages().await;
    assert_eq!(
        sent_messages.len(),
        4,
        "All 4 color changes should be broadcast"
    );
}

#[tokio::test]
async fn test_light_service_state_persistence() {
    // Test that state changes are properly persisted
    let peer_id = PeerId::new("persistence-test");
    let database = Arc::new(MockDatabaseAdapter::new());
    let network = Arc::new(MockNetworkAdapter::new());

    let service = LightService::new(
        peer_id.clone(),
        "Test".to_string(),
        database.clone(),
        network.clone(),
    )
    .await
    .unwrap();

    // Change color
    service.set_light_color(LightColor::Red).await.unwrap();

    // Verify persistence by reading directly from database
    let persisted = database.get_my_peer().await.unwrap();
    assert_eq!(persisted.light_state.color, LightColor::Red);

    // Simulate app restart by creating a new service with same database
    let service2 = LightService::new(
        peer_id.clone(),
        "Test".to_string(),
        database.clone(),
        network.clone(),
    )
    .await
    .unwrap();

    let state = service2.get_my_peer_info().await.unwrap();
    assert_eq!(
        state.light_state.color,
        LightColor::Red,
        "State should persist across service restarts"
    );
}
