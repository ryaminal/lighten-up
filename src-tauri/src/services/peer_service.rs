use crate::adapters::{DatabaseAdapter, NetworkAdapter, Result};
use crate::domain::{Event, PeerId, PeerInfo};
use crate::services::message_handler;
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::{RwLock, broadcast};

/// Service for managing peer discovery and state synchronization
pub struct PeerService<D: DatabaseAdapter, N: NetworkAdapter> {
    my_peer_id: PeerId,
    database: Arc<D>,
    network: Arc<N>,
    peers: Arc<RwLock<HashMap<PeerId, PeerInfo>>>,
    event_tx: broadcast::Sender<Event>,
    shutdown_tx: tokio::sync::watch::Sender<bool>,
}

impl<D: DatabaseAdapter + 'static, N: NetworkAdapter + 'static> PeerService<D, N> {
    /// Create a new peer service
    pub async fn new(
        my_peer_id: PeerId,
        database: Arc<D>,
        network: Arc<N>,
        event_tx: broadcast::Sender<Event>,
    ) -> Result<Self> {
        let peers = Self::load_peers(&database).await?;
        let peers = Arc::new(RwLock::new(peers));
        let (shutdown_tx, _) = tokio::sync::watch::channel(false);

        Ok(Self {
            my_peer_id,
            database,
            network,
            peers,
            event_tx,
            shutdown_tx,
        })
    }

    async fn load_peers(database: &Arc<D>) -> Result<HashMap<PeerId, PeerInfo>> {
        let peers = database.get_all_peers().await?;
        Ok(peers.into_iter().map(|p| (p.id.clone(), p)).collect())
    }

    /// Start listening for incoming messages
    pub async fn start(&self) -> Result<()> {
        let network = self.network.clone();
        let database = self.database.clone();
        let peers = self.peers.clone();
        let event_tx = self.event_tx.clone();
        let my_peer_id = self.my_peer_id.clone();
        let mut shutdown_rx = self.shutdown_tx.subscribe();

        tokio::spawn(async move {
            loop {
                tokio::select! {
                    _ = shutdown_rx.changed() => {
                        break;
                    }
                    result = network.receive() => {
                        match result {
                            Ok((peer_id, message)) => {
                                if let Err(e) = message_handler::handle_message(
                                    &my_peer_id,
                                    peer_id,
                                    message,
                                    &database,
                                    &peers,
                                    &event_tx,
                                ).await {
                                    eprintln!("Error handling message: {:?}", e);
                                }
                            }
                            Err(e) => {
                                eprintln!("Error receiving message: {:?}", e);
                            }
                        }
                    }
                }
            }
        });

        Ok(())
    }

    /// Stop the message loop
    pub fn stop(&self) -> Result<()> {
        let _ = self.shutdown_tx.send(true);
        Ok(())
    }

    /// Get all known peers
    pub async fn get_peers(&self) -> Vec<PeerInfo> {
        self.peers.read().await.values().cloned().collect()
    }

    /// Get a specific peer by ID
    pub async fn get_peer(&self, peer_id: &PeerId) -> Option<PeerInfo> {
        self.peers.read().await.get(peer_id).cloned()
    }
}
