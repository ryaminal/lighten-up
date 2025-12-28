use crate::protocol::messages::{LightState, Notification, PresenceMessage};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::RwLock;

const PEER_TIMEOUT_SECS: u64 = 60;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PeerPresence {
    pub peer_id: String,
    pub peer_name: String,
    pub light_state: LightState,
    pub note: Option<String>,
    pub last_seen: u64,
    pub notification_status: Option<Notification>,
}

pub struct PresenceService {
    my_peer_id: String,
    my_peer_name: Arc<RwLock<String>>,
    peers: Arc<RwLock<HashMap<String, PeerPresence>>>,
    my_light_state: Arc<RwLock<LightState>>,
    my_note: Arc<RwLock<Option<String>>>,
}

impl PresenceService {
    pub fn new(peer_id: String, peer_name: String) -> Self {
        Self {
            my_peer_id: peer_id,
            my_peer_name: Arc::new(RwLock::new(peer_name)),
            peers: Arc::new(RwLock::new(HashMap::new())),
            my_light_state: Arc::new(RwLock::new(LightState::new("#000000".to_string()))),
            my_note: Arc::new(RwLock::new(None)),
        }
    }

    pub async fn get_my_presence(&self) -> PresenceMessage {
        create_online_message(
            &self.my_peer_id,
            &self.my_peer_name,
            &self.my_light_state,
            &self.my_note,
        )
        .await
    }

    pub async fn get_offline_message(&self) -> PresenceMessage {
        PresenceMessage::Goodbye {
            peer_id: self.my_peer_id.clone(),
        }
    }

    pub async fn set_light_color(&self, color: String) {
        let mut state = self.my_light_state.write().await;
        *state = LightState::new(color);
    }

    pub async fn set_note(&self, note: Option<String>) {
        let mut my_note = self.my_note.write().await;
        *my_note = note;
    }

    pub async fn set_peer_name(&self, name: String) {
        let mut peer_name = self.my_peer_name.write().await;
        *peer_name = name;
    }

    pub async fn get_peer_name(&self) -> String {
        self.my_peer_name.read().await.clone()
    }

    pub fn get_my_peer_id(&self) -> String {
        self.my_peer_id.clone()
    }

    pub async fn handle_presence(&self, msg: PresenceMessage) {
        match msg {
            PresenceMessage::Online {
                peer_id,
                peer_name,
                light_state,
                note,
                timestamp,
            } => {
                add_or_update_peer(
                    &self.peers,
                    peer_id,
                    peer_name,
                    light_state,
                    note,
                    timestamp,
                )
                .await;
            }
            PresenceMessage::Goodbye { peer_id } => {
                log::info!(
                    "[PRESENCE] Peer {} is going offline - removing from peer list",
                    peer_id
                );
                remove_peer(&self.peers, &peer_id).await;
            }
            // RequestStatus is a lightweight ping; we do not need to update state.
            PresenceMessage::RequestStatus { .. } => {
                // No action needed – the routing layer will reply directly.
            }
        }
    }

    pub async fn cleanup_stale_peers(&self) {
        let now = crate::utils::current_timestamp();
        let mut peers = self.peers.write().await;
        peers.retain(|_, peer| now - peer.last_seen < PEER_TIMEOUT_SECS);
    }
    
    pub async fn set_peer_notification(&self, peer_id: String, notification: Notification) {
        let mut peers = self.peers.write().await;
        if let Some(peer) = peers.get_mut(&peer_id) {
            peer.notification_status = Some(notification);
        }
    }
    
    pub async fn clear_peer_notification(&self, peer_id: &str) {
        let mut peers = self.peers.write().await;
        if let Some(peer) = peers.get_mut(peer_id) {
            peer.notification_status = None;
        }
    }

    pub async fn get_all_peers(&self) -> Vec<PeerPresence> {
        let mut all_peers: Vec<PeerPresence> = self.peers.read().await.values().cloned().collect();

        // Include myself in the peers list
        let my_presence = PeerPresence {
            peer_id: self.my_peer_id.clone(),
            peer_name: self.my_peer_name.read().await.clone(),
            light_state: self.my_light_state.read().await.clone(),
            note: self.my_note.read().await.clone(),
            last_seen: crate::utils::current_timestamp(),
            notification_status: None, // I don't have a notification for myself
        };
        all_peers.push(my_presence);

        all_peers
    }
}

async fn create_online_message(
    peer_id: &str,
    peer_name: &Arc<RwLock<String>>,
    light_state: &Arc<RwLock<LightState>>,
    note: &Arc<RwLock<Option<String>>>,
) -> PresenceMessage {
    let state = light_state.read().await.clone();
    let my_note = note.read().await.clone();
    let name = peer_name.read().await.clone();

    PresenceMessage::Online {
        peer_id: peer_id.to_string(),
        peer_name: name,
        light_state: state,
        note: my_note,
        timestamp: crate::utils::current_timestamp(),
    }
}

async fn add_or_update_peer(
    peers: &Arc<RwLock<HashMap<String, PeerPresence>>>,
    peer_id: String,
    peer_name: String,
    light_state: LightState,
    note: Option<String>,
    timestamp: u64,
) {
    let mut peers_map = peers.write().await;
    
    // Preserve existing notification_status if peer exists
    let existing_notification = peers_map
        .get(&peer_id)
        .and_then(|p| p.notification_status.clone());
    
    peers_map.insert(
        peer_id.clone(),
        PeerPresence {
            peer_id,
            peer_name,
            light_state,
            note,
            last_seen: timestamp,
            notification_status: existing_notification,
        },
    );
}

async fn remove_peer(peers: &Arc<RwLock<HashMap<String, PeerPresence>>>, peer_id: &str) {
    let mut peers_map = peers.write().await;
    peers_map.remove(peer_id);
}
