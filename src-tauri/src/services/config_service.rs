use crate::database::Database;
use crate::domain::{AppError, DomainResult as Result};
use crate::protocol::messages::{ConfigMessage, ConfigOp, LightConfig};
use crate::services::config_handlers::{apply_delete_if_newer, apply_upsert_with_lww};
use log::info;
use std::sync::Arc;

pub struct ConfigService {
    db: Arc<Database>,
    my_peer_id: String,
}

impl ConfigService {
    pub fn new(db: Arc<Database>, my_peer_id: String) -> Self {
        Self { db, my_peer_id }
    }

    pub async fn get_all_lights(&self) -> Result<Vec<LightConfig>> {
        info!("Fetching all light configurations");
        let conn = self.db.connection();
        crate::database::queries::get_all_lights(&conn)
            .map_err(|e| AppError::Other(anyhow::anyhow!("Failed to get lights: {}", e)))
    }

    pub async fn upsert_light(&self, mut light: LightConfig) -> Result<ConfigMessage> {
        info!("Upserting light config id={}", light.id);
        light.updated_at = crate::utils::current_timestamp();
        light.updated_by = self.my_peer_id.clone();

        let conn = self.db.connection();
        crate::database::queries::upsert_light(&conn, &light)
            .map_err(|e| AppError::Other(anyhow::anyhow!("Failed to upsert light: {}", e)))?;

        Ok(ConfigMessage {
            op: ConfigOp::Upsert {
                id: light.id,
                color: light.color,
                name: light.name,
                enabled: light.enabled,
                priority: light.priority,
                updated_at: light.updated_at,
                updated_by: light.updated_by,
            },
            peer_id: self.my_peer_id.clone(),
            timestamp: crate::utils::current_timestamp(),
        })
    }

    pub async fn delete_light(&self, id: String) -> Result<ConfigMessage> {
        info!("Deleting light config id={}", id);
        let conn = self.db.connection();
        crate::database::queries::delete_light(&conn, &id)
            .map_err(|e| AppError::Other(anyhow::anyhow!("Failed to delete light: {}", e)))?;

        Ok(ConfigMessage {
            op: ConfigOp::Delete {
                id,
                deleted_at: crate::utils::current_timestamp(),
            },
            peer_id: self.my_peer_id.clone(),
            timestamp: crate::utils::current_timestamp(),
        })
    }

    pub async fn handle_config_message(&self, msg: ConfigMessage) -> Result<bool> {
        match msg.op {
            ConfigOp::Upsert {
                id,
                color,
                name,
                enabled,
                priority,
                updated_at,
                updated_by,
            } => {
                apply_upsert_with_lww(
                    &self.db, id, color, name, enabled, priority, updated_at, updated_by,
                )
                .await?;
                Ok(false)
            }
            ConfigOp::Delete { id, deleted_at } => {
                apply_delete_if_newer(&self.db, &id, deleted_at).await?;
                Ok(false)
            }
            ConfigOp::RequestSync { .. } => {
                // Return true to signal that a sync response is needed
                Ok(true)
            }
        }
    }

    pub async fn get_all_config_messages(&self) -> Result<Vec<ConfigMessage>> {
        let lights = self.get_all_lights().await?;
        let messages = lights
            .into_iter()
            .map(|light| ConfigMessage {
                op: ConfigOp::Upsert {
                    id: light.id,
                    color: light.color,
                    name: light.name,
                    enabled: light.enabled,
                    priority: light.priority,
                    updated_at: light.updated_at,
                    updated_by: light.updated_by,
                },
                peer_id: self.my_peer_id.clone(),
                timestamp: crate::utils::current_timestamp(),
            })
            .collect();
        Ok(messages)
    }
}
