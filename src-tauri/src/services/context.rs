use crate::adapters::DatabaseAdapter;
use crate::domain::{Event, PeerId, PeerInfo};
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
}

impl<D: DatabaseAdapter> MessageContext<D> {
    pub fn new(
        database: Arc<D>,
        peers: Arc<RwLock<HashMap<PeerId, PeerInfo>>>,
        event_tx: broadcast::Sender<Event>,
    ) -> Self {
        Self {
            database,
            peers,
            event_tx,
        }
    }
}

impl<D: DatabaseAdapter> Clone for MessageContext<D> {
    fn clone(&self) -> Self {
        Self {
            database: self.database.clone(),
            peers: self.peers.clone(),
            event_tx: self.event_tx.clone(),
        }
    }
}
