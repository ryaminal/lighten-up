use crate::adapters::DatabaseAdapter;
use crate::domain::{Event, PeerId, PeerInfo};
use crate::services::{ConfigService, ControllerService};
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::{RwLock, broadcast};

/// Shared context for message handling operations
///
/// Groups commonly-passed dependencies to reduce parameter count
/// and improve function signatures per AGENTS.md guidelines.
pub struct MessageContext<D: DatabaseAdapter> {
    pub database: Arc<D>,
    pub peers: Arc<RwLock<HashMap<PeerId, PeerInfo>>>,
    pub event_tx: broadcast::Sender<Event>,
    pub my_peer_id: PeerId,
    pub config_service: Option<Arc<ConfigService<D>>>,
    pub controller_service: Option<Arc<ControllerService<D>>>,
}

impl<D: DatabaseAdapter> MessageContext<D> {
    pub fn new(
        database: Arc<D>,
        peers: Arc<RwLock<HashMap<PeerId, PeerInfo>>>,
        event_tx: broadcast::Sender<Event>,
        my_peer_id: PeerId,
    ) -> Self {
        Self {
            database,
            peers,
            event_tx,
            my_peer_id,
            config_service: None,
            controller_service: None,
        }
    }

    pub fn with_config_service(mut self, config_service: Arc<ConfigService<D>>) -> Self {
        self.config_service = Some(config_service);
        self
    }

    pub fn with_controller_service(
        mut self,
        controller_service: Arc<ControllerService<D>>,
    ) -> Self {
        self.controller_service = Some(controller_service);
        self
    }
}

impl<D: DatabaseAdapter> Clone for MessageContext<D> {
    fn clone(&self) -> Self {
        Self {
            database: self.database.clone(),
            peers: self.peers.clone(),
            event_tx: self.event_tx.clone(),
            my_peer_id: self.my_peer_id.clone(),
            config_service: self.config_service.clone(),
            controller_service: self.controller_service.clone(),
        }
    }
}
