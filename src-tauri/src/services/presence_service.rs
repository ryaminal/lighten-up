use crate::protocol::messages::{LightState, Notification, PresenceMessage};
use crate::services::presence_helpers::{add_or_update_peer, create_online_message, remove_peer};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::RwLock;

// Peers are considered offline if not seen for 30 seconds (3 missed 10s heartbeats)
const PEER_TIMEOUT_SECS: u64 = 30;

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
    my_notification_status: Arc<RwLock<Option<Notification>>>,
}

impl PresenceService {
    pub fn new(peer_id: String, peer_name: String) -> Self {
        Self {
            my_peer_id: peer_id,
            my_peer_name: Arc::new(RwLock::new(peer_name)),
            peers: Arc::new(RwLock::new(HashMap::new())),
            my_light_state: Arc::new(RwLock::new(LightState::new("#000000".to_string()))),
            my_note: Arc::new(RwLock::new(None)),
            my_notification_status: Arc::new(RwLock::new(None)),
        }
    }

    pub async fn get_my_presence(&self) -> PresenceMessage {
        create_online_message(
            &self.my_peer_id,
            &self.my_peer_name,
            &self.my_light_state,
            &self.my_note,
            &self.my_notification_status,
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
                notification_status,
            } => {
                log::info!(
                    "[PRESENCE] Received Online from peer {} ({})",
                    peer_id,
                    peer_name
                );
                add_or_update_peer(
                    &self.peers,
                    peer_id,
                    peer_name,
                    light_state,
                    note,
                    timestamp,
                    *notification_status,
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
            PresenceMessage::RequestStatus { peer_id } => {
                log::info!("[PRESENCE] Received RequestStatus from peer {}", peer_id);
                // No action needed – the routing layer will reply directly.
            }
        }
    }

    pub async fn cleanup_stale_peers(&self) -> bool {
        let now = crate::utils::current_timestamp();
        let mut peers = self.peers.write().await;

        let initial_count = peers.len();
        let stale_peers: Vec<String> = peers
            .iter()
            .filter(|(_, peer)| now - peer.last_seen >= PEER_TIMEOUT_SECS)
            .map(|(id, peer)| format!("{} ({})", id, peer.peer_name))
            .collect();

        peers.retain(|_, peer| now - peer.last_seen < PEER_TIMEOUT_SECS);

        let removed_any = !stale_peers.is_empty();

        if removed_any {
            log::info!(
                "[CLEANUP] Removed {} stale peer(s): {}",
                stale_peers.len(),
                stale_peers.join(", ")
            );
        } else if initial_count > 0 {
            log::debug!("[CLEANUP] All {} peers still active", initial_count);
        }

        removed_any
    }

    pub async fn set_peer_notification(&self, peer_id: String, notification: Notification) {
        // If this is for me, store in my_notification_status
        if peer_id == self.my_peer_id {
            let mut my_notif = self.my_notification_status.write().await;
            *my_notif = Some(notification);
        } else {
            // Otherwise store in peers map
            let mut peers = self.peers.write().await;
            if let Some(peer) = peers.get_mut(&peer_id) {
                peer.notification_status = Some(notification);
            }
        }
    }

    pub async fn clear_peer_notification(&self, peer_id: &str) {
        // If this is for me, clear my_notification_status
        if peer_id == self.my_peer_id {
            let mut my_notif = self.my_notification_status.write().await;
            *my_notif = None;
        } else {
            // Otherwise clear in peers map
            let mut peers = self.peers.write().await;
            if let Some(peer) = peers.get_mut(peer_id) {
                peer.notification_status = None;
            }
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
            notification_status: self.my_notification_status.read().await.clone(),
        };
        all_peers.push(my_presence);

        all_peers
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::protocol::messages::NotificationType;

    #[tokio::test]
    async fn new_creates_service_with_initial_state() {
        let service = PresenceService::new("peer-1".to_string(), "Test Peer".to_string());

        assert_eq!(service.get_my_peer_id(), "peer-1");
        assert_eq!(service.get_peer_name().await, "Test Peer");
        let peers = service.get_all_peers().await;
        assert_eq!(peers.len(), 1);
        assert_eq!(peers[0].peer_id, "peer-1");
    }

    #[tokio::test]
    async fn set_light_color_updates_state() {
        let service = PresenceService::new("peer-1".to_string(), "Test Peer".to_string());

        service.set_light_color("red".to_string()).await;

        let presence = service.get_my_presence().await;
        match presence {
            PresenceMessage::Online { light_state, .. } => {
                assert_eq!(light_state.color, "red");
            }
            _ => panic!("Expected Online message"),
        }
    }

    #[tokio::test]
    async fn set_note_updates_state() {
        let service = PresenceService::new("peer-1".to_string(), "Test Peer".to_string());

        service.set_note(Some("Busy".to_string())).await;

        let presence = service.get_my_presence().await;
        match presence {
            PresenceMessage::Online { note, .. } => {
                assert_eq!(note, Some("Busy".to_string()));
            }
            _ => panic!("Expected Online message"),
        }
    }

    #[tokio::test]
    async fn set_peer_name_updates_name() {
        let service = PresenceService::new("peer-1".to_string(), "Original Name".to_string());

        service.set_peer_name("Updated Name".to_string()).await;

        assert_eq!(service.get_peer_name().await, "Updated Name");
        let presence = service.get_my_presence().await;
        match presence {
            PresenceMessage::Online { peer_name, .. } => {
                assert_eq!(peer_name, "Updated Name");
            }
            _ => panic!("Expected Online message"),
        }
    }

    #[tokio::test]
    async fn get_offline_message_returns_goodbye() {
        let service = PresenceService::new("peer-1".to_string(), "Test Peer".to_string());

        let message = service.get_offline_message().await;

        match message {
            PresenceMessage::Goodbye { peer_id } => {
                assert_eq!(peer_id, "peer-1");
            }
            _ => panic!("Expected Goodbye message"),
        }
    }

    #[tokio::test]
    async fn handle_presence_adds_new_peer() {
        let service = PresenceService::new("my-peer".to_string(), "Me".to_string());
        let online_msg = PresenceMessage::Online {
            peer_id: "peer-2".to_string(),
            peer_name: "Other Peer".to_string(),
            light_state: LightState::new("blue".to_string()),
            note: Some("Available".to_string()),
            timestamp: crate::utils::current_timestamp(),
            notification_status: Box::new(None),
        };

        service.handle_presence(online_msg).await;

        let peers = service.get_all_peers().await;
        assert_eq!(peers.len(), 2);
        let other_peer = peers.iter().find(|p| p.peer_id == "peer-2").unwrap();
        assert_eq!(other_peer.peer_name, "Other Peer");
        assert_eq!(other_peer.light_state.color, "blue");
        assert_eq!(other_peer.note, Some("Available".to_string()));
    }

    #[tokio::test]
    async fn handle_presence_updates_existing_peer() {
        let service = PresenceService::new("my-peer".to_string(), "Me".to_string());
        let online_msg1 = PresenceMessage::Online {
            peer_id: "peer-2".to_string(),
            peer_name: "Other Peer".to_string(),
            light_state: LightState::new("blue".to_string()),
            note: None,
            timestamp: crate::utils::current_timestamp(),
            notification_status: Box::new(None),
        };
        service.handle_presence(online_msg1).await;

        let online_msg2 = PresenceMessage::Online {
            peer_id: "peer-2".to_string(),
            peer_name: "Other Peer Updated".to_string(),
            light_state: LightState::new("green".to_string()),
            note: Some("Updated".to_string()),
            timestamp: crate::utils::current_timestamp(),
            notification_status: Box::new(None),
        };
        service.handle_presence(online_msg2).await;

        let peers = service.get_all_peers().await;
        assert_eq!(peers.len(), 2);
        let other_peer = peers.iter().find(|p| p.peer_id == "peer-2").unwrap();
        assert_eq!(other_peer.peer_name, "Other Peer Updated");
        assert_eq!(other_peer.light_state.color, "green");
        assert_eq!(other_peer.note, Some("Updated".to_string()));
    }

    #[tokio::test]
    async fn handle_presence_removes_peer_on_goodbye() {
        let service = PresenceService::new("my-peer".to_string(), "Me".to_string());
        let online_msg = PresenceMessage::Online {
            peer_id: "peer-2".to_string(),
            peer_name: "Other Peer".to_string(),
            light_state: LightState::new("blue".to_string()),
            note: None,
            timestamp: crate::utils::current_timestamp(),
            notification_status: Box::new(None),
        };
        service.handle_presence(online_msg).await;

        let goodbye_msg = PresenceMessage::Goodbye {
            peer_id: "peer-2".to_string(),
        };
        service.handle_presence(goodbye_msg).await;

        let peers = service.get_all_peers().await;
        assert_eq!(peers.len(), 1);
        assert_eq!(peers[0].peer_id, "my-peer");
    }

    #[tokio::test]
    async fn cleanup_stale_peers_removes_old_peers() {
        let service = PresenceService::new("my-peer".to_string(), "Me".to_string());

        let old_timestamp = crate::utils::current_timestamp() - 31;
        let online_msg = PresenceMessage::Online {
            peer_id: "stale-peer".to_string(),
            peer_name: "Stale Peer".to_string(),
            light_state: LightState::new("red".to_string()),
            note: None,
            timestamp: old_timestamp,
            notification_status: Box::new(None),
        };
        service.handle_presence(online_msg).await;

        {
            let mut peers = service.peers.write().await;
            if let Some(peer) = peers.get_mut("stale-peer") {
                peer.last_seen = old_timestamp;
            }
        }

        let removed = service.cleanup_stale_peers().await;

        assert!(removed);
        let peers = service.get_all_peers().await;
        assert_eq!(peers.len(), 1);
        assert_eq!(peers[0].peer_id, "my-peer");
    }

    #[tokio::test]
    async fn cleanup_stale_peers_keeps_active_peers() {
        let service = PresenceService::new("my-peer".to_string(), "Me".to_string());
        let online_msg = PresenceMessage::Online {
            peer_id: "active-peer".to_string(),
            peer_name: "Active Peer".to_string(),
            light_state: LightState::new("green".to_string()),
            note: None,
            timestamp: crate::utils::current_timestamp(),
            notification_status: Box::new(None),
        };
        service.handle_presence(online_msg).await;

        let removed = service.cleanup_stale_peers().await;

        assert!(!removed);
        let peers = service.get_all_peers().await;
        assert_eq!(peers.len(), 2);
    }

    #[tokio::test]
    async fn cleanup_stale_peers_boundary_at_30_seconds() {
        let service = PresenceService::new("my-peer".to_string(), "Me".to_string());

        let boundary_timestamp = crate::utils::current_timestamp() - 30;
        let online_msg = PresenceMessage::Online {
            peer_id: "boundary-peer".to_string(),
            peer_name: "Boundary Peer".to_string(),
            light_state: LightState::new("yellow".to_string()),
            note: None,
            timestamp: boundary_timestamp,
            notification_status: Box::new(None),
        };
        service.handle_presence(online_msg).await;

        {
            let mut peers = service.peers.write().await;
            if let Some(peer) = peers.get_mut("boundary-peer") {
                peer.last_seen = boundary_timestamp;
            }
        }

        let removed = service.cleanup_stale_peers().await;

        assert!(removed);
        let peers = service.get_all_peers().await;
        assert_eq!(peers.len(), 1);
    }

    #[tokio::test]
    async fn set_peer_notification_for_self() {
        let service = PresenceService::new("my-peer".to_string(), "Me".to_string());
        let notification = Notification {
            notification_type: NotificationType::PatientReady,
            message: "Patient ready".to_string(),
            target_peer_id: "my-peer".to_string(),
            sender_peer_id: "other-peer".to_string(),
            timestamp: crate::utils::current_timestamp(),
            priority: None,
            color: Some("red".to_string()),
        };

        service
            .set_peer_notification("my-peer".to_string(), notification.clone())
            .await;

        let peers = service.get_all_peers().await;
        let my_peer = peers.iter().find(|p| p.peer_id == "my-peer").unwrap();
        assert!(my_peer.notification_status.is_some());
        assert_eq!(
            my_peer.notification_status.as_ref().unwrap().message,
            "Patient ready"
        );
    }

    #[tokio::test]
    async fn set_peer_notification_for_other_peer() {
        let service = PresenceService::new("my-peer".to_string(), "Me".to_string());
        let online_msg = PresenceMessage::Online {
            peer_id: "peer-2".to_string(),
            peer_name: "Other Peer".to_string(),
            light_state: LightState::new("blue".to_string()),
            note: None,
            timestamp: crate::utils::current_timestamp(),
            notification_status: Box::new(None),
        };
        service.handle_presence(online_msg).await;

        let notification = Notification {
            notification_type: NotificationType::UrgentAssist,
            message: "Urgent assistance needed".to_string(),
            target_peer_id: "peer-2".to_string(),
            sender_peer_id: "my-peer".to_string(),
            timestamp: crate::utils::current_timestamp(),
            priority: Some("high".to_string()),
            color: None,
        };
        service
            .set_peer_notification("peer-2".to_string(), notification.clone())
            .await;

        let peers = service.get_all_peers().await;
        let other_peer = peers.iter().find(|p| p.peer_id == "peer-2").unwrap();
        assert!(other_peer.notification_status.is_some());
        assert_eq!(
            other_peer.notification_status.as_ref().unwrap().message,
            "Urgent assistance needed"
        );
    }

    #[tokio::test]
    async fn clear_peer_notification_for_self() {
        let service = PresenceService::new("my-peer".to_string(), "Me".to_string());
        let notification = Notification {
            notification_type: NotificationType::PatientReady,
            message: "Patient ready".to_string(),
            target_peer_id: "my-peer".to_string(),
            sender_peer_id: "other-peer".to_string(),
            timestamp: crate::utils::current_timestamp(),
            priority: None,
            color: Some("red".to_string()),
        };
        service
            .set_peer_notification("my-peer".to_string(), notification)
            .await;

        service.clear_peer_notification("my-peer").await;

        let peers = service.get_all_peers().await;
        let my_peer = peers.iter().find(|p| p.peer_id == "my-peer").unwrap();
        assert!(my_peer.notification_status.is_none());
    }

    #[tokio::test]
    async fn clear_peer_notification_for_other_peer() {
        let service = PresenceService::new("my-peer".to_string(), "Me".to_string());
        let online_msg = PresenceMessage::Online {
            peer_id: "peer-2".to_string(),
            peer_name: "Other Peer".to_string(),
            light_state: LightState::new("blue".to_string()),
            note: None,
            timestamp: crate::utils::current_timestamp(),
            notification_status: Box::new(None),
        };
        service.handle_presence(online_msg).await;

        let notification = Notification {
            notification_type: NotificationType::UrgentAssist,
            message: "Urgent".to_string(),
            target_peer_id: "peer-2".to_string(),
            sender_peer_id: "my-peer".to_string(),
            timestamp: crate::utils::current_timestamp(),
            priority: None,
            color: None,
        };
        service
            .set_peer_notification("peer-2".to_string(), notification)
            .await;

        service.clear_peer_notification("peer-2").await;

        let peers = service.get_all_peers().await;
        let other_peer = peers.iter().find(|p| p.peer_id == "peer-2").unwrap();
        assert!(other_peer.notification_status.is_none());
    }

    #[tokio::test]
    async fn get_all_peers_includes_self() {
        let service = PresenceService::new("my-peer".to_string(), "Me".to_string());

        let peers = service.get_all_peers().await;

        assert_eq!(peers.len(), 1);
        assert_eq!(peers[0].peer_id, "my-peer");
        assert_eq!(peers[0].peer_name, "Me");
    }

    #[tokio::test]
    async fn get_all_peers_includes_all_peers() {
        let service = PresenceService::new("my-peer".to_string(), "Me".to_string());
        for i in 1..=3 {
            let online_msg = PresenceMessage::Online {
                peer_id: format!("peer-{}", i),
                peer_name: format!("Peer {}", i),
                light_state: LightState::new("blue".to_string()),
                note: None,
                timestamp: crate::utils::current_timestamp(),
                notification_status: Box::new(None),
            };
            service.handle_presence(online_msg).await;
        }

        let peers = service.get_all_peers().await;

        assert_eq!(peers.len(), 4);
        assert!(peers.iter().any(|p| p.peer_id == "my-peer"));
        assert!(peers.iter().any(|p| p.peer_id == "peer-1"));
        assert!(peers.iter().any(|p| p.peer_id == "peer-2"));
        assert!(peers.iter().any(|p| p.peer_id == "peer-3"));
    }

    #[tokio::test]
    async fn multiple_peers_with_different_states() {
        let service = PresenceService::new("my-peer".to_string(), "Me".to_string());

        let msg1 = PresenceMessage::Online {
            peer_id: "peer-1".to_string(),
            peer_name: "Peer 1".to_string(),
            light_state: LightState::new("red".to_string()),
            note: Some("Busy".to_string()),
            timestamp: crate::utils::current_timestamp(),
            notification_status: Box::new(None),
        };
        let msg2 = PresenceMessage::Online {
            peer_id: "peer-2".to_string(),
            peer_name: "Peer 2".to_string(),
            light_state: LightState::new("green".to_string()),
            note: None,
            timestamp: crate::utils::current_timestamp(),
            notification_status: Box::new(Some(Notification {
                notification_type: NotificationType::PatientReady,
                message: "Test".to_string(),
                target_peer_id: "peer-2".to_string(),
                sender_peer_id: "my-peer".to_string(),
                timestamp: crate::utils::current_timestamp(),
                priority: None,
                color: None,
            })),
        };

        service.handle_presence(msg1).await;
        service.handle_presence(msg2).await;

        let peers = service.get_all_peers().await;
        assert_eq!(peers.len(), 3);

        let peer1 = peers.iter().find(|p| p.peer_id == "peer-1").unwrap();
        assert_eq!(peer1.light_state.color, "red");
        assert_eq!(peer1.note, Some("Busy".to_string()));
        assert!(peer1.notification_status.is_none());

        let peer2 = peers.iter().find(|p| p.peer_id == "peer-2").unwrap();
        assert_eq!(peer2.light_state.color, "green");
        assert!(peer2.note.is_none());
        assert!(peer2.notification_status.is_some());
    }
}
