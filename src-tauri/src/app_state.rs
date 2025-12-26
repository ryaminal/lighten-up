use crate::adapters::{Message, NetworkAdapter};
use crate::database::Database;
use crate::encryption::ChaCha20Encryption;
use crate::network::MdnsNetwork;
use crate::services::{ChatService, ConfigService, PresenceService};
use std::sync::Arc;

/// Application state managed by Tauri
pub struct AppState {
    pub network: Arc<MdnsNetwork<ChaCha20Encryption>>,
    pub my_peer_id: String,
    pub presence_service: Arc<PresenceService>,
    pub config_service: Arc<ConfigService>,
    pub chat_service: Arc<ChatService>,
    pub database: Arc<Database>,
}

impl AppState {
    pub fn new(
        network: Arc<MdnsNetwork<ChaCha20Encryption>>,
        my_peer_id: String,
        presence_service: Arc<PresenceService>,
        config_service: Arc<ConfigService>,
        chat_service: Arc<ChatService>,
        database: Arc<Database>,
    ) -> Self {
        Self {
            network,
            my_peer_id,
            presence_service,
            config_service,
            chat_service,
            database,
        }
    }

    /// Gracefully shutdown the application
    pub async fn shutdown(&self) -> Result<(), String> {
        log::info!("[SHUTDOWN] Initiating graceful shutdown");

        // Broadcast offline status
        log::info!("[SHUTDOWN] Broadcasting goodbye message to all peers");
        let message = self.presence_service.get_offline_message().await;
        if let Err(e) = self.network.broadcast(Message::Presence(message)).await {
            log::warn!("[SHUTDOWN] Failed to broadcast offline status: {:?}", e);
        } else {
            log::info!("[SHUTDOWN] Goodbye message broadcast successfully");
        }

        // Give more time for message to be sent before stopping network
        log::info!("[SHUTDOWN] Waiting for goodbye message to be delivered...");
        tokio::time::sleep(tokio::time::Duration::from_millis(500)).await;

        // Stop network
        log::info!("[SHUTDOWN] Stopping network services");
        if let Err(e) = self.network.stop().await {
            log::error!("[SHUTDOWN] Failed to stop network: {:?}", e);
        }

        log::info!("[SHUTDOWN] Graceful shutdown completed");
        Ok(())
    }
}
