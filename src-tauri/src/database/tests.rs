use super::*;
use crate::domain::{LightColor, LightState, PeerId, PeerInfo, VectorClock};

#[tokio::test]
async fn test_initialize_database() {
    let db = SqliteDatabase::in_memory().expect("Failed to create database");
    db.initialize().await.expect("Failed to initialize");
}

#[tokio::test]
async fn test_save_and_get_peer() {
    let db = SqliteDatabase::in_memory().expect("Failed to create database");
    db.initialize().await.expect("Failed to initialize");

    let peer_id = PeerId::new("test-peer");
    let mut clock = VectorClock::new();
    clock.increment(&peer_id);
    let state = LightState::new(LightColor::Red, clock, 123456);
    let peer = PeerInfo::new(peer_id.clone(), "Test Peer".to_string(), state);

    db.save_peer(&peer).await.expect("Failed to save peer");

    let retrieved = db.get_peer(&peer_id).await.expect("Failed to get peer");
    assert_eq!(retrieved.id, peer.id);
    assert_eq!(retrieved.name, peer.name);
    assert_eq!(retrieved.light_state.color, peer.light_state.color);
}

#[tokio::test]
async fn test_get_all_peers() {
    let db = SqliteDatabase::in_memory().expect("Failed to create database");
    db.initialize().await.expect("Failed to initialize");

    let peer1_id = PeerId::new("peer1");
    let mut clock1 = VectorClock::new();
    clock1.increment(&peer1_id);
    let state1 = LightState::new(LightColor::Red, clock1, 100);
    let peer1 = PeerInfo::new(peer1_id, "Peer 1".to_string(), state1);

    let peer2_id = PeerId::new("peer2");
    let mut clock2 = VectorClock::new();
    clock2.increment(&peer2_id);
    let state2 = LightState::new(LightColor::Blue, clock2, 200);
    let peer2 = PeerInfo::new(peer2_id, "Peer 2".to_string(), state2);

    db.save_peer(&peer1).await.expect("Failed to save peer1");
    db.save_peer(&peer2).await.expect("Failed to save peer2");

    let peers = db.get_all_peers().await.expect("Failed to get all peers");
    assert_eq!(peers.len(), 2);
}

#[tokio::test]
async fn test_delete_peer() {
    let db = SqliteDatabase::in_memory().expect("Failed to create database");
    db.initialize().await.expect("Failed to initialize");

    let peer_id = PeerId::new("test-peer");
    let mut clock = VectorClock::new();
    clock.increment(&peer_id);
    let state = LightState::new(LightColor::Green, clock, 300);
    let peer = PeerInfo::new(peer_id.clone(), "Test Peer".to_string(), state);

    db.save_peer(&peer).await.expect("Failed to save peer");
    db.delete_peer(&peer_id)
        .await
        .expect("Failed to delete peer");

    let result = db.get_peer(&peer_id).await;
    assert!(result.is_err());
}

#[tokio::test]
async fn test_my_peer_operations() {
    let db = SqliteDatabase::in_memory().expect("Failed to create database");
    db.initialize().await.expect("Failed to initialize");

    let peer_id = PeerId::new("my-peer");
    let mut clock = VectorClock::new();
    clock.increment(&peer_id);
    let state = LightState::new(LightColor::Yellow, clock, 400);
    let peer = PeerInfo::new(peer_id.clone(), "My Name".to_string(), state);

    db.save_my_peer(&peer)
        .await
        .expect("Failed to save my peer");

    let retrieved = db.get_my_peer().await.expect("Failed to get my peer");
    assert_eq!(retrieved.name, "My Name");

    db.update_my_name("New Name".to_string())
        .await
        .expect("Failed to update name");

    let updated = db.get_my_peer().await.expect("Failed to get my peer");
    assert_eq!(updated.name, "New Name");
}
