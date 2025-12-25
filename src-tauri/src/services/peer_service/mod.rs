pub mod announcement;
pub mod cleanup;

use crate::adapters::{DatabaseAdapter, Message, NetworkAdapter, Result};
use crate::domain::{Event, PeerId, PeerInfo};
use crate::services::{MessageContext, message_handler};
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
        self.start_message_loop();
        self.start_announcement_loop();
        self.start_stale_peer_cleanup();
        Ok(())
    }

    fn start_message_loop(&self) {
        let network = self.network.clone();
        let my_peer_id = self.my_peer_id.clone();
        let mut shutdown_rx = self.shutdown_tx.subscribe();
        let ctx = MessageContext::new(
            self.database.clone(),
            self.peers.clone(),
            self.event_tx.clone(),
        );

        tokio::spawn(async move {
            loop {
                tokio::select! {
                    _ = shutdown_rx.changed() => {
                        break;
                    }
                    result = network.receive() => {
                        handle_receive_result(result, &my_peer_id, &ctx).await;
                    }
                }
            }
        });
    }

    fn start_announcement_loop(&self) {
        let shutdown_rx = self.shutdown_tx.subscribe();
        announcement::start_announcement_loop(
            self.network.clone(),
            self.database.clone(),
            shutdown_rx,
        );
    }

    fn start_stale_peer_cleanup(&self) {
        let shutdown_rx = self.shutdown_tx.subscribe();
        let ctx = MessageContext::new(
            self.database.clone(),
            self.peers.clone(),
            self.event_tx.clone(),
        );
        cleanup::start_stale_peer_cleanup(ctx, shutdown_rx);
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
}

async fn handle_receive_result<D: DatabaseAdapter>(
    result: Result<(PeerId, Message)>,
    my_peer_id: &PeerId,
    ctx: &MessageContext<D>,
) {
    match result {
        Ok((peer_id, message)) => {
            if let Err(e) = message_handler::handle_message(my_peer_id, peer_id, message, ctx).await
            {
                log::error!("Error handling message: {:?}", e);
            }
        }
        Err(e) => {
            log::error!("Error receiving message: {:?}", e);
        }
    }
}
