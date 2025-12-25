use crate::adapters::DatabaseAdapter;
use crate::domain::{LightConfig, PeerId};
use std::sync::Arc;
use tokio::sync::RwLock;

/// Service for managing light configuration
pub struct ConfigService<D: DatabaseAdapter> {
    database: Arc<D>,
    config: Arc<RwLock<LightConfig>>,
}

impl<D: DatabaseAdapter> ConfigService<D> {
    pub async fn new(database: Arc<D>, peer_id: &PeerId) -> Result<Self, String> {
        let config = match database.get_light_config().await {
            Ok(cfg) => cfg,
            Err(_) => {
                let default_cfg = LightConfig::default_config(peer_id.as_str());
                database
                    .save_light_config(&default_cfg)
                    .await
                    .map_err(|e| format!("Failed to save config: {}", e))?;
                default_cfg
            }
        };

        Ok(Self {
            database,
            config: Arc::new(RwLock::new(config)),
        })
    }

    pub async fn get_config(&self) -> LightConfig {
        self.config.read().await.clone()
    }

    pub async fn update_config(&self, config: LightConfig) -> Result<(), String> {
        self.database
            .save_light_config(&config)
            .await
            .map_err(|e| format!("Failed to save config: {}", e))?;

        let mut current = self.config.write().await;
        *current = config;

        Ok(())
    }

    pub async fn merge_config(&self, other: &LightConfig) -> Result<(), String> {
        let mut current = self.config.write().await;
        current.merge(other);

        self.database
            .save_light_config(&current)
            .await
            .map_err(|e| format!("Failed to save merged config: {}", e))?;

        Ok(())
    }

    /// Replace config completely (for followers receiving controller config)
    pub async fn replace_config(&self, config: &LightConfig) -> Result<(), String> {
        log::info!(
            "[CONFIG] Replacing config with controller's config (version {})",
            config.version
        );

        self.database
            .save_light_config(config)
            .await
            .map_err(|e| format!("Failed to save config: {}", e))?;

        let mut current = self.config.write().await;
        *current = config.clone();

        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::adapters::{AdapterError, Result};
    use crate::domain::{Light, LightId, LightState, PeerId, PeerInfo};
    use async_trait::async_trait;

    struct MockDatabase {
        config: Arc<RwLock<Option<LightConfig>>>,
    }

    impl MockDatabase {
        fn new() -> Self {
            Self {
                config: Arc::new(RwLock::new(None)),
            }
        }
    }

    #[async_trait]
    impl DatabaseAdapter for MockDatabase {
        async fn initialize(&self) -> Result<()> {
            Ok(())
        }

        async fn save_peer(&self, _peer: &PeerInfo) -> Result<()> {
            Ok(())
        }

        async fn get_peer(&self, _peer_id: &PeerId) -> Result<PeerInfo> {
            Err(AdapterError::Database("not implemented".to_string()))
        }

        async fn get_all_peers(&self) -> Result<Vec<PeerInfo>> {
            Ok(vec![])
        }

        async fn delete_peer(&self, _peer_id: &PeerId) -> Result<()> {
            Ok(())
        }

        async fn save_my_peer(&self, _peer: &PeerInfo) -> Result<()> {
            Ok(())
        }

        async fn get_my_peer(&self) -> Result<PeerInfo> {
            Err(AdapterError::Database("not implemented".to_string()))
        }

        async fn update_my_name(&self, _name: String) -> Result<()> {
            Ok(())
        }

        async fn update_my_light_state(&self, _state: &LightState) -> Result<()> {
            Ok(())
        }

        async fn save_light(&self, _light: &Light) -> Result<()> {
            Ok(())
        }

        async fn get_light(&self, _light_id: &LightId) -> Result<Light> {
            Err(AdapterError::Database("not implemented".to_string()))
        }

        async fn get_all_lights(&self) -> Result<Vec<Light>> {
            Ok(vec![])
        }

        async fn delete_light(&self, _light_id: &LightId) -> Result<()> {
            Ok(())
        }

        async fn save_light_config(&self, config: &LightConfig) -> Result<()> {
            *self.config.write().await = Some(config.clone());
            Ok(())
        }

        async fn get_light_config(&self) -> Result<LightConfig> {
            self.config
                .read()
                .await
                .clone()
                .ok_or_else(|| AdapterError::Database("config not found".to_string()))
        }

        async fn save_controller_info(
            &self,
            _info: Option<crate::services::controller_service::ControllerInfo>,
        ) -> Result<()> {
            Ok(())
        }

        async fn get_controller_info(
            &self,
        ) -> Result<Option<crate::services::controller_service::ControllerInfo>> {
            Ok(None)
        }
    }

    #[tokio::test]
    async fn test_new_creates_default_config() {
        let db = Arc::new(MockDatabase::new());
        let peer_id = PeerId::new("test-peer");

        let service = ConfigService::new(db.clone(), &peer_id).await.expect("ok");

        let config = service.get_config().await;
        assert_eq!(config.definitions.len(), 6);
        assert_eq!(config.version, 1);
    }

    #[tokio::test]
    async fn test_update_config() {
        let db = Arc::new(MockDatabase::new());
        let peer_id = PeerId::new("test-peer");

        let service = ConfigService::new(db.clone(), &peer_id).await.expect("ok");

        let mut config = service.get_config().await;
        config.version = 2;

        service.update_config(config.clone()).await.expect("ok");

        let retrieved = service.get_config().await;
        assert_eq!(retrieved.version, 2);
    }

    #[tokio::test]
    async fn test_merge_config() {
        let db = Arc::new(MockDatabase::new());
        let peer_id = PeerId::new("test-peer");

        let service = ConfigService::new(db.clone(), &peer_id).await.expect("ok");

        let mut other_config = service.get_config().await;
        other_config.definitions[0].name = "Updated".to_string();
        other_config.definitions[0].updated_at += 1;
        other_config.version = 2;

        service.merge_config(&other_config).await.expect("ok");

        let merged = service.get_config().await;
        assert_eq!(merged.definitions[0].name, "Updated");
        assert_eq!(merged.version, 2);
    }
}
