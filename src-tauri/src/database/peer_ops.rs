use crate::adapters::{AdapterError, Result};
use crate::database::{schema, serialization, sqlite::SqliteDatabase};
use crate::domain::{PeerId, PeerInfo};

impl SqliteDatabase {
    pub async fn initialize(&self) -> Result<()> {
        let conn = self
            .conn
            .lock()
            .map_err(|e| AdapterError::Database(format!("Failed to acquire lock: {}", e)))?;

        schema::initialize_schema(&conn)?;
        Ok(())
    }

    pub async fn save_peer(&self, peer: &PeerInfo) -> Result<()> {
        let conn = self
            .conn
            .lock()
            .map_err(|e| AdapterError::Database(format!("Failed to acquire lock: {}", e)))?;

        let color_str = serialization::serialize_light_color(&peer.light_state.color);
        let clock_json = serialization::serialize_vector_clock(&peer.light_state.vector_clock)?;

        conn.execute(
            "INSERT OR REPLACE INTO peers (id, name, light_color, vector_clock, timestamp) VALUES (?1, ?2, ?3, ?4, ?5)",
            rusqlite::params![peer.id.as_str(), &peer.name, color_str, clock_json, peer.light_state.timestamp as i64],
        ).map_err(|e| AdapterError::Database(format!("Failed to save peer: {}", e)))?;

        Ok(())
    }

    pub async fn get_peer(&self, peer_id: &PeerId) -> Result<PeerInfo> {
        let conn = self
            .conn
            .lock()
            .map_err(|e| AdapterError::Database(format!("Failed to acquire lock: {}", e)))?;

        let peer_info = conn
            .query_row(
                "SELECT id, name, light_color, vector_clock, timestamp FROM peers WHERE id = ?1",
                [peer_id.as_str()],
                serialization::row_to_peer_info,
            )
            .map_err(|e| match e {
                rusqlite::Error::QueryReturnedNoRows => {
                    AdapterError::NotFound(format!("Peer not found: {}", peer_id))
                }
                _ => AdapterError::Database(format!("Failed to get peer: {}", e)),
            })?;

        Ok(peer_info)
    }

    pub async fn get_all_peers(&self) -> Result<Vec<PeerInfo>> {
        let conn = self
            .conn
            .lock()
            .map_err(|e| AdapterError::Database(format!("Failed to acquire lock: {}", e)))?;

        let mut stmt = conn
            .prepare("SELECT id, name, light_color, vector_clock, timestamp FROM peers")
            .map_err(|e| AdapterError::Database(format!("Failed to prepare statement: {}", e)))?;

        let peers = stmt
            .query_map([], serialization::row_to_peer_info)
            .map_err(|e| AdapterError::Database(format!("Failed to query peers: {}", e)))?
            .collect::<rusqlite::Result<Vec<_>>>()
            .map_err(|e| AdapterError::Database(format!("Failed to collect peers: {}", e)))?;

        Ok(peers)
    }

    pub async fn delete_peer(&self, peer_id: &PeerId) -> Result<()> {
        let conn = self
            .conn
            .lock()
            .map_err(|e| AdapterError::Database(format!("Failed to acquire lock: {}", e)))?;

        conn.execute("DELETE FROM peers WHERE id = ?1", [peer_id.as_str()])
            .map_err(|e| AdapterError::Database(format!("Failed to delete peer: {}", e)))?;

        Ok(())
    }
}
