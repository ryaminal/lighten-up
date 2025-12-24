use crate::adapters::{AdapterError, DatabaseAdapter, Result};
use crate::domain::{LightState, PeerInfo};
use async_trait::async_trait;
use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::Arc;
use tauri::AppHandle;
use tauri_plugin_store::{Store, StoreExt};
use tokio::sync::RwLock;

/// Store-based database implementation using tauri-plugin-store
pub struct StoreDatabase {
    store: RwLock<Arc<Store<tauri::Wry>>>,
}

impl StoreDatabase {
    /// Create a new store database
    pub fn new(app: &AppHandle) -> Result<Self> {
        let store = if let Ok(data_dir) = std::env::var("LIGHTEN_UP_DATA_DIR") {
            let path = PathBuf::from(&data_dir).join("lighten-up-data.json");
            std::fs::create_dir_all(&data_dir).map_err(|e| {
                AdapterError::Database(format!("Failed to create data directory: {}", e))
            })?;
            app.store_builder(path)
                .build()
                .map_err(|e| AdapterError::Database(format!("Failed to open store: {}", e)))?
        } else {
            app.store("lighten-up-data.json")
                .map_err(|e| AdapterError::Database(format!("Failed to open store: {}", e)))?
        };

        Ok(Self {
            store: RwLock::new(store),
        })
    }
}

#[async_trait]
impl DatabaseAdapter for StoreDatabase {
    async fn initialize(&self) -> Result<()> {
        let store = self.store.write().await;

        // Initialize empty peers map if it doesn't exist
        if store.get("peers").is_none() {
            store.set("peers", serde_json::json!({}));
        }

        store
            .save()
            .map_err(|e| AdapterError::Database(format!("Failed to save store: {}", e)))?;

        Ok(())
    }

    async fn save_my_peer(&self, peer: &PeerInfo) -> Result<()> {
        let store = self.store.write().await;
        store.set(
            "my_peer",
            serde_json::to_value(peer).expect("PeerInfo should always serialize to JSON"),
        );
        store
            .save()
            .map_err(|e| AdapterError::Database(format!("Failed to save my peer: {}", e)))?;
        Ok(())
    }

    async fn get_my_peer(&self) -> Result<PeerInfo> {
        let store = self.store.read().await;
        store
            .get("my_peer")
            .and_then(|v| serde_json::from_value(v.clone()).ok())
            .ok_or_else(|| AdapterError::Database("My peer not found".to_string()))
    }

    async fn update_my_name(&self, name: String) -> Result<()> {
        let mut peer = self.get_my_peer().await?;
        peer.name = name;
        self.save_my_peer(&peer).await
    }

    async fn update_my_light_state(&self, state: &LightState) -> Result<()> {
        let mut peer = self.get_my_peer().await?;
        peer.light_state = state.clone();
        self.save_my_peer(&peer).await
    }

    async fn save_peer(&self, peer: &PeerInfo) -> Result<()> {
        let store = self.store.write().await;

        // Get current peers map
        let mut peers: HashMap<String, serde_json::Value> = store
            .get("peers")
            .and_then(|v| serde_json::from_value(v.clone()).ok())
            .unwrap_or_default();

        // Update peer
        peers.insert(
            peer.id.as_str().to_string(),
            serde_json::to_value(peer).expect("PeerInfo should always serialize to JSON"),
        );

        // Save back
        store.set(
            "peers",
            serde_json::to_value(peers).expect("HashMap should always serialize to JSON"),
        );
        store
            .save()
            .map_err(|e| AdapterError::Database(format!("Failed to save peer: {}", e)))?;

        Ok(())
    }

    async fn get_peer(&self, peer_id: &crate::domain::PeerId) -> Result<PeerInfo> {
        let store = self.store.read().await;

        let peers: HashMap<String, serde_json::Value> = store
            .get("peers")
            .and_then(|v| serde_json::from_value(v.clone()).ok())
            .unwrap_or_default();

        peers
            .get(peer_id.as_str())
            .and_then(|v| serde_json::from_value(v.clone()).ok())
            .ok_or_else(|| AdapterError::Database(format!("Peer {} not found", peer_id)))
    }

    async fn get_all_peers(&self) -> Result<Vec<PeerInfo>> {
        let store = self.store.read().await;

        let peers: HashMap<String, serde_json::Value> = store
            .get("peers")
            .and_then(|v| serde_json::from_value(v.clone()).ok())
            .unwrap_or_default();

        let result: Vec<PeerInfo> = peers
            .values()
            .filter_map(|v| serde_json::from_value(v.clone()).ok())
            .collect();

        Ok(result)
    }

    async fn delete_peer(&self, peer_id: &crate::domain::PeerId) -> Result<()> {
        let store = self.store.write().await;

        let mut peers: HashMap<String, serde_json::Value> = store
            .get("peers")
            .and_then(|v| serde_json::from_value(v.clone()).ok())
            .unwrap_or_default();

        peers.remove(peer_id.as_str());

        store.set(
            "peers",
            serde_json::to_value(peers).expect("HashMap should always serialize to JSON"),
        );
        store
            .save()
            .map_err(|e| AdapterError::Database(format!("Failed to delete peer: {}", e)))?;

        Ok(())
    }
}
