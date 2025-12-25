pub mod announcement;
pub mod cleanup;

use crate::adapters::{DatabaseAdapter, Message, NetworkAdapter, Result};
use crate::domain::{Event, PeerId, PeerInfo};
use crate::services::{ConfigService, ControllerService, MessageContext, message_handler};
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
    config_service: Arc<RwLock<Option<Arc<ConfigService<D>>>>>,
    controller_service: Arc<RwLock<Option<Arc<ControllerService<D>>>>>,
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
            config_service: Arc::new(RwLock::new(None)),
            controller_service: Arc::new(RwLock::new(None)),
        })
    }

    async fn load_peers(database: &Arc<D>) -> Result<HashMap<PeerId, PeerInfo>> {
        let peers = database.get_all_peers().await?;
        Ok(peers.into_iter().map(|p| (p.id.clone(), p)).collect())
    }

    /// Attach config service for handling config sync messages
    pub async fn attach_config_service(&self, config_service: Arc<ConfigService<D>>) {
        let mut guard = self.config_service.write().await;
        *guard = Some(config_service);
        log::info!("[PEER_SERVICE] Config service attached");
    }

    /// Attach controller service for handling controller messages
    pub async fn attach_controller_service(&self, controller_service: Arc<ControllerService<D>>) {
        let mut guard = self.controller_service.write().await;
        *guard = Some(controller_service);
        log::info!("[PEER_SERVICE] Controller service attached");
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
        let database = self.database.clone();
        let peers = self.peers.clone();
        let event_tx = self.event_tx.clone();
        let config_service = self.config_service.clone();
        let controller_service = self.controller_service.clone();

        tokio::spawn(async move {
            loop {
                tokio::select! {
                    _ = shutdown_rx.changed() => {
                        break;
                    }
                    result = network.receive() => {
                        // Build context with config and controller services if available
                        let mut ctx = MessageContext::new(
                            database.clone(),
                            peers.clone(),
                            event_tx.clone(),
                            my_peer_id.clone(),
                        );

                        if let Some(cfg_svc) = config_service.read().await.as_ref() {
                            ctx = ctx.with_config_service(cfg_svc.clone());
                        }

                        if let Some(ctrl_svc) = controller_service.read().await.as_ref() {
                            ctx = ctx.with_controller_service(ctrl_svc.clone());
                        }

                        handle_receive_result(result, &my_peer_id, &ctx, network.clone()).await;
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
            self.my_peer_id.clone(),
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

async fn handle_receive_result<D: DatabaseAdapter, N: NetworkAdapter>(
    result: Result<(PeerId, Message)>,
    my_peer_id: &PeerId,
    ctx: &MessageContext<D>,
    network: Arc<N>,
) {
    match result {
        Ok((peer_id, message)) => {
            if let Err(e) =
                message_handler::handle_message(my_peer_id, peer_id, message, ctx, network).await
            {
                log::error!("Error handling message: {:?}", e);
            }
        }
        Err(e) => {
            log::error!("Error receiving message: {:?}", e);
        }
    }
}
