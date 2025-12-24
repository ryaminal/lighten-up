use crate::adapters::{DatabaseAdapter, Message, NetworkAdapter, Result};
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
                                    log::error!("Error handling message: {:?}", e);
                                }
                            }
                            Err(e) => {
                                log::error!("Error receiving message: {:?}", e);
                            }
                        }
                    }
                }
            }
        });

        // Start periodic announcement loop
        self.start_announcement_loop();

        Ok(())
    }

    /// Start a background task that announces our presence
    fn start_announcement_loop(&self) {
        let network = self.network.clone();
        let database = self.database.clone();
        let mut shutdown_rx = self.shutdown_tx.subscribe();

        tokio::spawn(async move {
            // Wait briefly for network/mDNS to be ready
            tokio::time::sleep(tokio::time::Duration::from_millis(500)).await;
            
            // Send initial announcement - peers will respond to this
            if let Ok(my_peer) = database.get_my_peer().await {
                let message = Message::PeerAnnouncement { peer: my_peer };
                log::info!("📢 Broadcasting initial peer announcement");
                if let Err(e) = network.broadcast(message).await {
                    log::debug!("Initial broadcast failed (no peers yet?): {:?}", e);
                }
            }

            // Announce frequently at startup, then slow down
            let delays = vec![2, 5, 10, 30]; // seconds
            for delay in delays {
                tokio::time::sleep(tokio::time::Duration::from_secs(delay)).await;
                
                if let Ok(my_peer) = database.get_my_peer().await {
                    let message = Message::PeerAnnouncement { peer: my_peer };
                    log::info!("📢 Broadcasting peer announcement");
                    if let Err(e) = network.broadcast(message).await {
                        log::debug!("Broadcast failed: {:?}", e);
                    }
                }
            }

            // Then send periodic announcements every 30 seconds
            loop {
                tokio::select! {
                    _ = shutdown_rx.changed() => {
                        log::info!("🛑 Stopping announcement loop");
                        break;
                    }
                    _ = tokio::time::sleep(tokio::time::Duration::from_secs(30)) => {
                        if let Ok(my_peer) = database.get_my_peer().await {
                            let message = Message::PeerAnnouncement { peer: my_peer };
                            log::info!("📢 Broadcasting periodic peer announcement");
                            if let Err(e) = network.broadcast(message).await {
                                log::debug!("Periodic broadcast failed: {:?}", e);
                            }
                        }
                    }
                }
            }
        });
    }

    /// Announce our presence to all peers on the network
    pub async fn announce(&self) -> Result<()> {
        let my_peer = self.database.get_my_peer().await?;
        let message = Message::PeerAnnouncement { peer: my_peer };

        log::info!("📢 Broadcasting peer announcement");
        self.network.broadcast(message).await?;

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
