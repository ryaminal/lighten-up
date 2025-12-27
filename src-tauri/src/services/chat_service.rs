use crate::protocol::messages::ChatMessage;
use crate::services::chat_db::{get_chat_messages, save_chat_message};
use anyhow::Result;
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

    pub async fn send_message(&self, content: String) -> Result<ChatMessage> {
        let msg = ChatMessage {
            id: Uuid::new_v4().to_string(),
            peer_id: self.my_peer_id.clone(),
            peer_name: self.my_peer_name.clone(),
            content,
            timestamp: crate::utils::current_timestamp(),
        };

        save_chat_message(&self.conn, &msg)?;
        Ok(msg)
    }

    pub async fn handle_message(&self, msg: ChatMessage) -> Result<()> {
        save_chat_message(&self.conn, &msg)?;
        Ok(())
    }

    pub async fn get_all_messages(&self) -> Result<Vec<ChatMessage>> {
        Ok(get_chat_messages(&self.conn)?)
    }

    pub async fn edit_message(&self, id: String, content: String) -> Result<ChatMessage> {
        let conn = self.conn.lock().expect("Failed to acquire lock");

        // First verify the message exists and belongs to this peer
        let mut stmt = conn.prepare("SELECT peer_id FROM chat_messages WHERE id = ?1")?;
        let peer_id: String = stmt
            .query_row(params![id], |row| row.get(0))
            .map_err(|_| anyhow::anyhow!("Message not found"))?;

        if peer_id != self.my_peer_id {
            return Err(anyhow::anyhow!("Cannot edit another user's message"));
        }

        // Update the message
        let timestamp = crate::utils::current_timestamp();
        conn.execute(
            "UPDATE chat_messages SET content = ?1, timestamp = ?2 WHERE id = ?3",
            params![content, timestamp, id],
        )?;

        Ok(ChatMessage {
            id,
            peer_id: self.my_peer_id.clone(),
            peer_name: self.my_peer_name.clone(),
            content,
            timestamp,
        })
    }

    pub async fn delete_message(&self, id: String) -> Result<()> {
        let conn = self.conn.lock().expect("Failed to acquire lock");

        // First verify the message exists and belongs to this peer
        let mut stmt = conn.prepare("SELECT peer_id FROM chat_messages WHERE id = ?1")?;
        let peer_id: String = stmt
            .query_row(params![id], |row| row.get(0))
            .map_err(|_| anyhow::anyhow!("Message not found"))?;

        if peer_id != self.my_peer_id {
            return Err(anyhow::anyhow!("Cannot delete another user's message"));
        }

        conn.execute("DELETE FROM chat_messages WHERE id = ?1", params![id])?;
        Ok(())
    }
}
