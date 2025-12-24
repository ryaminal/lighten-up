use crate::adapters::{DatabaseAdapter, NetworkAdapter, Message};
use crate::domain::PeerId;
use crate::services::{LightService, PeerService};
use std::sync::Arc;

/// Application state managed by Tauri
pub struct AppState<D: DatabaseAdapter, N: NetworkAdapter> {
    pub light_service: Arc<LightService<D, N>>,
    pub peer_service: Arc<PeerService<D, N>>,
    pub network: Arc<N>,
    pub my_peer_id: PeerId,
}

impl<D: DatabaseAdapter + 'static, N: NetworkAdapter + 'static> AppState<D, N> {
    pub fn new(
        light_service: Arc<LightService<D, N>>,
        peer_service: Arc<PeerService<D, N>>,
        network: Arc<N>,
        my_peer_id: PeerId,
    ) -> Self {
        Self {
            light_service,
            peer_service,
            network,
            my_peer_id,
        }
    }

    /// Gracefully shutdown the application
    pub async fn shutdown(&self) -> Result<(), String> {
        log::info!("Initiating graceful shutdown");

        // Broadcast PeerLeaving message to all peers
        let message = Message::PeerLeaving {
            peer_id: self.my_peer_id.clone(),
        };

        if let Err(e) = self.network.broadcast(message).await {
            log::warn!("Failed to broadcast PeerLeaving message: {:?}", e);
        } else {
            log::info!("PeerLeaving message broadcast successfully");
        }

        // Stop peer service
        if let Err(e) = self.peer_service.stop() {
            log::error!("Failed to stop peer service: {:?}", e);
        }

        // Stop network
        if let Err(e) = self.network.stop().await {
            log::error!("Failed to stop network: {:?}", e);
        }

        // Small delay to ensure message is sent
        tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;

        log::info!("Graceful shutdown completed");
        Ok(())
    }
}
