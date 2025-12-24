use crate::adapters::{DatabaseAdapter, Message, NetworkAdapter, Result};
use crate::domain::{Event, PeerId, PeerInfo};
use crate::services::message_handler;
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::{RwLock, broadcast};

/// Default timeout in seconds after which a peer is considered stale
const PEER_TIMEOUT_SECS: u64 = 90; // 1.5 minutes

/// How often to check for stale peers (in seconds)
const CLEANUP_INTERVAL_SECS: u64 = 30;

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

        // Start stale peer cleanup task
        self.start_stale_peer_cleanup();

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
                log::info!("[ANNOUNCE] Broadcasting initial peer announcement");
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
                    log::info!("[ANNOUNCE] Broadcasting peer announcement");
                    if let Err(e) = network.broadcast(message).await {
                        log::debug!("Broadcast failed: {:?}", e);
                    }
                }
            }

            // Then send periodic announcements every 30 seconds
            loop {
                tokio::select! {
                    _ = shutdown_rx.changed() => {
                        log::info!("[STOP] Stopping announcement loop");
                        break;
                    }
                    _ = tokio::time::sleep(tokio::time::Duration::from_secs(30)) => {
                        if let Ok(my_peer) = database.get_my_peer().await {
                            let message = Message::PeerAnnouncement { peer: my_peer };
                            log::info!("[ANNOUNCE] Broadcasting periodic peer announcement");
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

        log::info!("[ANNOUNCE] Broadcasting peer announcement");
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

    /// Start a background task to periodically check for and remove stale peers
    fn start_stale_peer_cleanup(&self) {
        let peers = self.peers.clone();
        let database = self.database.clone();
        let event_tx = self.event_tx.clone();
        let mut shutdown_rx = self.shutdown_tx.subscribe();

        tokio::spawn(async move {
            loop {
                tokio::select! {
                    _ = shutdown_rx.changed() => {
                        log::info!("[CLEANUP] Stopping stale peer cleanup task");
                        break;
                    }
                    _ = tokio::time::sleep(tokio::time::Duration::from_secs(CLEANUP_INTERVAL_SECS)) => {
                        Self::cleanup_stale_peers(&peers, &database, &event_tx).await;
                    }
                }
            }
        });

        log::info!(
            "[CLEANUP] Started stale peer cleanup task (timeout: {}s, interval: {}s)",
            PEER_TIMEOUT_SECS,
            CLEANUP_INTERVAL_SECS
        );
    }

    /// Check for and remove stale peers
    async fn cleanup_stale_peers(
        peers: &Arc<RwLock<HashMap<PeerId, PeerInfo>>>,
        database: &Arc<D>,
        event_tx: &broadcast::Sender<Event>,
    ) {
        let mut peers_guard = peers.write().await;
        let stale_peer_ids: Vec<PeerId> = peers_guard
            .iter()
            .filter(|(_, peer)| peer.is_stale(PEER_TIMEOUT_SECS))
            .map(|(id, peer)| {
                log::warn!(
                    "[CLEANUP] Removing stale peer {} ({}) - last seen {}s ago",
                    peer.name,
                    id.as_str(),
                    std::time::SystemTime::now()
                        .duration_since(std::time::UNIX_EPOCH)
                        .unwrap()
                        .as_secs()
                        .saturating_sub(peer.last_seen)
                );
                id.clone()
            })
            .collect();

        for peer_id in stale_peer_ids {
            peers_guard.remove(&peer_id);
            if let Err(e) = database.delete_peer(&peer_id).await {
                log::error!("Failed to delete stale peer {}: {:?}", peer_id.as_str(), e);
            }
            let _ = event_tx.send(Event::PeerLeft { peer_id });
        }
    }
}
