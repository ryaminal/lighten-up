use crate::adapters::DatabaseAdapter;
use crate::domain::{PeerId, PeerRole};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tokio::sync::RwLock;

/// Service for managing controller state in the network
/// Only one peer can be controller at a time
pub struct ControllerService<D: DatabaseAdapter> {
    /// Currently elected controller (None if no controller)
    current_controller: Arc<RwLock<Option<ControllerInfo>>>,
    /// This peer's ID
    my_peer_id: PeerId,
    /// This peer's role
    my_role: Arc<RwLock<PeerRole>>,
    /// Database for persistence
    database: Arc<D>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ControllerInfo {
    pub id: PeerId,
    pub name: String,
}

impl<D: DatabaseAdapter> ControllerService<D> {
    pub async fn new(my_peer_id: PeerId, database: Arc<D>) -> Self {
        // Load persisted controller info
        let controller_info = database.get_controller_info().await.ok().flatten();

        // Determine our role based on persisted info
        let my_role = if let Some(ref info) = controller_info {
            if info.id == my_peer_id {
                PeerRole::Controller
            } else {
                PeerRole::Follower
            }
        } else {
            PeerRole::Follower
        };

        log::info!(
            "[CONTROLLER] Initialized with role: {:?}, controller: {:?}",
            my_role,
            controller_info
        );

        Self {
            current_controller: Arc::new(RwLock::new(controller_info)),
            my_peer_id,
            my_role: Arc::new(RwLock::new(my_role)),
            database,
        }
    }

    pub async fn get_controller(&self) -> Option<ControllerInfo> {
        self.current_controller.read().await.clone()
    }

    pub async fn is_controller(&self) -> bool {
        *self.my_role.read().await == PeerRole::Controller
    }

    pub async fn get_my_role(&self) -> PeerRole {
        *self.my_role.read().await
    }

    pub async fn become_controller(&self, name: String) {
        let mut role = self.my_role.write().await;
        *role = PeerRole::Controller;

        let info = ControllerInfo {
            id: self.my_peer_id.clone(),
            name,
        };

        let mut controller = self.current_controller.write().await;
        *controller = Some(info.clone());

        // Persist to database
        if let Err(e) = self.database.save_controller_info(Some(info)).await {
            log::error!("[CONTROLLER] Failed to persist controller info: {}", e);
        }

        log::info!("[CONTROLLER] This peer is now the controller");
    }

    pub async fn resign_controller(&self) {
        let mut role = self.my_role.write().await;
        *role = PeerRole::Follower;

        // Note: We don't clear current_controller here, network still has a controller
        // Just stepping down as controller ourselves

        log::info!("[CONTROLLER] This peer has resigned as controller");
    }

    pub async fn set_controller(&self, id: PeerId, name: String) {
        if id == self.my_peer_id {
            return;
        }

        let info = ControllerInfo { id, name };

        let mut controller = self.current_controller.write().await;
        *controller = Some(info.clone());

        let mut role = self.my_role.write().await;
        *role = PeerRole::Follower;

        // Persist to database
        if let Err(e) = self.database.save_controller_info(Some(info)).await {
            log::error!("[CONTROLLER] Failed to persist controller info: {}", e);
        }

        log::info!(
            "[CONTROLLER] Network controller is now: {}",
            controller.as_ref().unwrap().id
        );
    }

    pub async fn clear_controller(&self) {
        let mut controller = self.current_controller.write().await;
        *controller = None;

        let mut role = self.my_role.write().await;
        *role = PeerRole::Follower;

        // Persist to database
        if let Err(e) = self.database.save_controller_info(None).await {
            log::error!("[CONTROLLER] Failed to persist controller info: {}", e);
        }

        log::info!("[CONTROLLER] Controller has resigned, no controller");
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::services::test_utils::MockDatabaseAdapter;

    #[tokio::test]
    async fn test_initial_state_is_follower() {
        let db = Arc::new(MockDatabaseAdapter::new());
        let service = ControllerService::new(PeerId::new("test"), db).await;
        assert!(!service.is_controller().await);
        assert_eq!(service.get_my_role().await, PeerRole::Follower);
        assert!(service.get_controller().await.is_none());
    }

    #[tokio::test]
    async fn test_become_controller() {
        let db = Arc::new(MockDatabaseAdapter::new());
        let service = ControllerService::new(PeerId::new("test"), db).await;
        service.become_controller("Test".to_string()).await;

        assert!(service.is_controller().await);
        assert_eq!(service.get_my_role().await, PeerRole::Controller);

        let controller = service.get_controller().await;
        assert!(controller.is_some());
    }

    #[tokio::test]
    async fn test_resign_controller() {
        let db = Arc::new(MockDatabaseAdapter::new());
        let service = ControllerService::new(PeerId::new("test"), db).await;
        service.become_controller("Test".to_string()).await;
        service.resign_controller().await;

        assert!(!service.is_controller().await);
        assert_eq!(service.get_my_role().await, PeerRole::Follower);
    }
}
