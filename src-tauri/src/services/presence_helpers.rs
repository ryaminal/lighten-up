use crate::protocol::messages::{LightState, Notification, PresenceMessage};
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::RwLock;

use super::presence_service::PeerPresence;

/// Create an online presence message from current state
pub async fn create_online_message(
    peer_id: &str,
    peer_name: &Arc<RwLock<String>>,
    light_state: &Arc<RwLock<LightState>>,
    note: &Arc<RwLock<Option<String>>>,
    my_notification_status: &Arc<RwLock<Option<Notification>>>,
) -> PresenceMessage {
    let state = light_state.read().await.clone();
    let my_note = note.read().await.clone();
    let name = peer_name.read().await.clone();
    let notif_status = my_notification_status.read().await.clone();

    PresenceMessage::Online {
        peer_id: peer_id.to_string(),
        peer_name: name,
        light_state: state,
        note: my_note,
        timestamp: crate::utils::current_timestamp(),
        notification_status: Box::new(notif_status),
    }
}

/// Add or update a peer in the presence map
pub async fn add_or_update_peer(
    peers: &Arc<RwLock<HashMap<String, PeerPresence>>>,
    peer_id: String,
    peer_name: String,
    light_state: LightState,
    note: Option<String>,
    _timestamp: u64,
    notification_status: Option<Notification>,
) {
    let mut peers_map = peers.write().await;
    let is_new = !peers_map.contains_key(&peer_id);
    let now = crate::utils::current_timestamp();

    peers_map.insert(
        peer_id.clone(),
        PeerPresence {
            peer_id: peer_id.clone(),
            peer_name: peer_name.clone(),
            light_state,
            note,
            last_seen: now,
            notification_status,
        },
    );

    if is_new {
        log::info!("[PRESENCE] Added new peer: {} ({})", peer_id, peer_name);
    } else {
        log::debug!(
            "[PRESENCE] Updated existing peer: {} ({})",
            peer_id,
            peer_name
        );
    }
}

/// Remove a peer from the presence map
pub async fn remove_peer(peers: &Arc<RwLock<HashMap<String, PeerPresence>>>, peer_id: &str) {
    let mut peers_map = peers.write().await;
    peers_map.remove(peer_id);
}
