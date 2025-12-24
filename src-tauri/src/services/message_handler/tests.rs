use super::*;
use crate::domain::{LightColor, VectorClock};
use crate::services::test_utils::MockDatabaseAdapter;

#[tokio::test]
async fn test_handle_peer_announcement_new_peer() {
    let db = Arc::new(MockDatabaseAdapter::new());
    db.initialize().await.unwrap();

    let peers = Arc::new(RwLock::new(HashMap::new()));
    let (event_tx, mut event_rx) = broadcast::channel(10);

    let peer_id = PeerId::new("test-peer");
    let my_peer_id = PeerId::new("my-peer");
    let state = LightState::new(LightColor::Red, VectorClock::new(), 100);
    let peer = PeerInfo::new(peer_id.clone(), "Test".to_string(), state);

    handle_message(
        &my_peer_id,
        peer_id.clone(),
        Message::PeerAnnouncement { peer: peer.clone() },
        &db,
        &peers,
        &event_tx,
    )
    .await
    .unwrap();

    assert!(peers.read().await.contains_key(&peer_id));

    let event = event_rx.try_recv().unwrap();
    match event {
        Event::PeerDiscovered { peer: p } => assert_eq!(p.id, peer_id),
        _ => panic!("Wrong event type"),
    }
}

#[tokio::test]
async fn test_handle_state_update_crdt_merge() {
    let db = Arc::new(MockDatabaseAdapter::new());
    db.initialize().await.unwrap();

    let peer_id = PeerId::new("test-peer");
    let my_peer_id = PeerId::new("my-peer");

    let mut clock1 = VectorClock::new();
    clock1.increment(&peer_id);
    let state1 = LightState::new(LightColor::Red, clock1, 100);
    let peer = PeerInfo::new(peer_id.clone(), "Test".to_string(), state1);

    let peers = Arc::new(RwLock::new(HashMap::new()));
    peers.write().await.insert(peer_id.clone(), peer);

    let (event_tx, mut event_rx) = broadcast::channel(10);

    let mut clock2 = VectorClock::new();
    clock2.increment(&peer_id);
    clock2.increment(&peer_id);
    let state2 = LightState::new(LightColor::Blue, clock2, 200);

    handle_message(
        &my_peer_id,
        peer_id.clone(),
        Message::StateUpdate {
            peer_id: peer_id.clone(),
            state: state2,
        },
        &db,
        &peers,
        &event_tx,
    )
    .await
    .unwrap();

    let updated_peer = peers.read().await.get(&peer_id).cloned().unwrap();
    assert_eq!(updated_peer.light_state.color, LightColor::Blue);

    let event = event_rx.try_recv().unwrap();
    match event {
        Event::PeerStateChanged { peer_id: id, .. } => assert_eq!(id, peer_id),
        _ => panic!("Wrong event type"),
    }
}

#[tokio::test]
async fn test_handle_peer_leaving() {
    let db = Arc::new(MockDatabaseAdapter::new());
    db.initialize().await.unwrap();

    let peer_id = PeerId::new("test-peer");
    let my_peer_id = PeerId::new("my-peer");
    let state = LightState::new(LightColor::Red, VectorClock::new(), 100);
    let peer = PeerInfo::new(peer_id.clone(), "Test".to_string(), state);

    db.save_peer(&peer).await.unwrap();

    let peers = Arc::new(RwLock::new(HashMap::new()));
    peers.write().await.insert(peer_id.clone(), peer);

    let (event_tx, mut event_rx) = broadcast::channel(10);

    handle_message(
        &my_peer_id,
        peer_id.clone(),
        Message::PeerLeaving {
            peer_id: peer_id.clone(),
        },
        &db,
        &peers,
        &event_tx,
    )
    .await
    .unwrap();

    assert!(!peers.read().await.contains_key(&peer_id));

    let event = event_rx.try_recv().unwrap();
    match event {
        Event::PeerLeft { peer_id: id } => assert_eq!(id, peer_id),
        _ => panic!("Wrong event type"),
    }
}
