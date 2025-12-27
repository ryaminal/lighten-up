use crate::domain::ChatMessage;
use crate::domain::{AppError, DomainResult as Result};
use crate::services::chat_db::{get_chat_messages, save_chat_message};
use log::info;
use rusqlite::{Connection, params};
use std::sync::{Arc, Mutex};
use uuid::Uuid;

pub struct ChatService {
    conn: Arc<Mutex<Connection>>,
    my_peer_id: String,
    my_peer_name: String,
}

impl ChatService {
    pub fn new(conn: Arc<Mutex<Connection>>, my_peer_id: String, my_peer_name: String) -> Self {
        Self {
            conn,
            my_peer_id,
            my_peer_name,
        }
    }

    /// Send a new chat message originating from this peer.
    /// Returns the persisted `ChatMessage` on success.
    pub async fn send_message(&self, content: String) -> Result<ChatMessage> {
        // Simple validation to avoid oversized payloads.
        if content.len() > 500 {
            return Err(AppError::Other(anyhow::anyhow!(
                "Message content exceeds maximum length"
            )));
        }

        let msg = ChatMessage {
            id: Uuid::new_v4().to_string(),
            peer_id: self.my_peer_id.clone(),
            peer_name: self.my_peer_name.clone(),
            content,
            timestamp: crate::utils::current_timestamp(),
        };

        info!("Saving chat message id={} peer_id={}", msg.id, msg.peer_id);
        save_chat_message(&self.conn, &msg).map_err(|e| AppError::Other(e.into()))?;
        Ok(msg)
    }

    /// Persist an incoming chat message.
    pub async fn handle_message(&self, msg: ChatMessage) -> Result<()> {
        info!(
            "Handling incoming chat message id={} from peer_id={}",
            msg.id, msg.peer_id
        );
        save_chat_message(&self.conn, &msg).map_err(|e| AppError::Other(e.into()))?;
        Ok(())
    }

    pub async fn get_all_messages(&self) -> Result<Vec<ChatMessage>> {
        get_chat_messages(&self.conn).map_err(|e| AppError::Other(e.into()))
    }

    /// Edit an existing message owned by this peer.
    pub async fn edit_message(&self, id: String, content: String) -> Result<ChatMessage> {
        let conn = self.conn.lock().expect("Failed to acquire lock");

        // First verify the message exists and belongs to this peer
        let mut stmt = conn
            .prepare("SELECT peer_id FROM chat_messages WHERE id = ?1")
            .map_err(|e| AppError::Other(e.into()))?;
        let peer_id: String = stmt
            .query_row(params![id.clone()], |row| row.get(0))
            .map_err(|_| AppError::NotFound)?;

        if peer_id != self.my_peer_id {
            return Err(AppError::PermissionDenied);
        }

        // Update the message
        let timestamp = crate::utils::current_timestamp();
        conn.execute(
            "UPDATE chat_messages SET content = ?1, timestamp = ?2 WHERE id = ?3",
            params![content, timestamp, id],
        )
        .map_err(|e| AppError::Other(e.into()))?;

        Ok(ChatMessage {
            id,
            peer_id: self.my_peer_id.clone(),
            peer_name: self.my_peer_name.clone(),
            content,
            timestamp,
        })
    }

    /// Delete a message owned by this peer.
    pub async fn delete_message(&self, id: String) -> Result<()> {
        let conn = self.conn.lock().expect("Failed to acquire lock");

        // First verify the message exists and belongs to this peer
        let mut stmt = conn
            .prepare("SELECT peer_id FROM chat_messages WHERE id = ?1")
            .map_err(|e| AppError::Other(e.into()))?;
        let peer_id: String = stmt
            .query_row(params![id.clone()], |row| row.get(0))
            .map_err(|_| AppError::NotFound)?;

        if peer_id != self.my_peer_id {
            return Err(AppError::PermissionDenied);
        }

        conn.execute("DELETE FROM chat_messages WHERE id = ?1", params![id])
            .map_err(|e| AppError::Other(e.into()))?;
        Ok(())
    }
}
