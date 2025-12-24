use crate::adapters::{AdapterError, Result};
use crate::database::{serialization, sqlite::SqliteDatabase};
use crate::domain::{LightState, PeerInfo};

impl SqliteDatabase {
    pub async fn save_my_peer(&self, peer: &PeerInfo) -> Result<()> {
        let conn = self
            .conn
            .lock()
            .map_err(|e| AdapterError::Database(format!("Failed to acquire lock: {}", e)))?;

        let color_str = serialization::serialize_light_color(&peer.light_state.color);
        let clock_json = serialization::serialize_vector_clock(&peer.light_state.vector_clock)?;

        conn.execute(
            "INSERT OR REPLACE INTO my_peer (id, peer_id, name, light_color, vector_clock, timestamp) VALUES (1, ?1, ?2, ?3, ?4, ?5)",
            rusqlite::params![peer.id.as_str(), &peer.name, color_str, clock_json, peer.light_state.timestamp as i64],
        ).map_err(|e| AdapterError::Database(format!("Failed to save my peer: {}", e)))?;

        Ok(())
    }

    pub async fn get_my_peer(&self) -> Result<PeerInfo> {
        let conn = self
            .conn
            .lock()
            .map_err(|e| AdapterError::Database(format!("Failed to acquire lock: {}", e)))?;

        let peer_info = conn.query_row(
            "SELECT peer_id, name, light_color, vector_clock, timestamp FROM my_peer WHERE id = 1",
            [],
            serialization::row_to_peer_info,
        ).map_err(|e| match e {
            rusqlite::Error::QueryReturnedNoRows => AdapterError::NotFound("My peer not found".to_string()),
            _ => AdapterError::Database(format!("Failed to get my peer: {}", e)),
        })?;

        Ok(peer_info)
    }

    pub async fn update_my_name(&self, name: String) -> Result<()> {
        let conn = self
            .conn
            .lock()
            .map_err(|e| AdapterError::Database(format!("Failed to acquire lock: {}", e)))?;

        conn.execute("UPDATE my_peer SET name = ?1 WHERE id = 1", [&name])
            .map_err(|e| AdapterError::Database(format!("Failed to update my name: {}", e)))?;

        Ok(())
    }

    pub async fn update_my_light_state(&self, state: &LightState) -> Result<()> {
        let conn = self
            .conn
            .lock()
            .map_err(|e| AdapterError::Database(format!("Failed to acquire lock: {}", e)))?;

        let color_str = serialization::serialize_light_color(&state.color);
        let clock_json = serialization::serialize_vector_clock(&state.vector_clock)?;

        conn.execute(
            "UPDATE my_peer SET light_color = ?1, vector_clock = ?2, timestamp = ?3 WHERE id = 1",
            rusqlite::params![color_str, clock_json, state.timestamp as i64],
        )
        .map_err(|e| AdapterError::Database(format!("Failed to update my light state: {}", e)))?;

        Ok(())
    }
}
