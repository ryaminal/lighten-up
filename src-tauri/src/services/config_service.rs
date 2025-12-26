use crate::database::Database;
use crate::protocol::messages::{ConfigMessage, ConfigOp, LightConfig};
use anyhow::Result;
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
        let conn = self.db.connection();
        crate::database::queries::get_all_lights(&conn)
            .map_err(|e| anyhow::anyhow!("Failed to get lights: {}", e))
    }

    pub async fn upsert_light(&self, mut light: LightConfig) -> Result<ConfigMessage> {
        light.updated_at = crate::utils::current_timestamp();
        light.updated_by = self.my_peer_id.clone();

        let conn = self.db.connection();
        crate::database::queries::upsert_light(&conn, &light)
            .map_err(|e| anyhow::anyhow!("Failed to upsert light: {}", e))?;

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
        let conn = self.db.connection();
        crate::database::queries::delete_light(&conn, &id)
            .map_err(|e| anyhow::anyhow!("Failed to delete light: {}", e))?;

        Ok(ConfigMessage {
            op: ConfigOp::Delete {
                id,
                deleted_at: crate::utils::current_timestamp(),
            },
            peer_id: self.my_peer_id.clone(),
            timestamp: crate::utils::current_timestamp(),
        })
    }

    pub async fn handle_config_message(&self, msg: ConfigMessage) -> Result<()> {
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
                    &self.db,
                    id,
                    color,
                    name,
                    enabled,
                    priority,
                    updated_at,
                    updated_by,
                ).await
            }
            ConfigOp::Delete { id, deleted_at } => {
                apply_delete_if_newer(&self.db, &id, deleted_at).await
            }
        }
    }
}

async fn apply_upsert_with_lww(
    db: &Arc<Database>,
    id: String,
    color: String,
    name: String,
    enabled: bool,
    priority: i32,
    updated_at: u64,
    updated_by: String,
) -> Result<()> {
    let conn = db.connection();
    let existing = crate::database::queries::get_all_lights(&conn)?
        .into_iter()
        .find(|l| l.id == id);

    // Apply if the incoming update is newer or has the same timestamp.
    // Using `>=` ensures that updates with identical timestamps (e.g., rapid succession
    // on different peers) are not silently dropped, which improves eventual consistency.
    let should_apply = match existing {
        Some(existing) => updated_at >= existing.updated_at,
        None => true,
    };

    if should_apply {
        let light = LightConfig {
            id,
            color,
            name,
            enabled,
            priority,
            updated_at,
            updated_by,
        };
        crate::database::queries::upsert_light(&conn, &light)?;
    }

    Ok(())
}

async fn apply_delete_if_newer(
    db: &Arc<Database>,
    id: &str,
    deleted_at: u64,
) -> Result<()> {
    let conn = db.connection();
    let existing = crate::database::queries::get_all_lights(&conn)?
        .into_iter()
        .find(|l| l.id == id);

    // Delete if the delete timestamp is newer or equal to the current record's timestamp.
    let should_delete = match existing {
        Some(existing) => deleted_at >= existing.updated_at,
        None => false,
    };

    if should_delete {
        crate::database::queries::delete_light(&conn, id)?;
    }

    Ok(())
}
