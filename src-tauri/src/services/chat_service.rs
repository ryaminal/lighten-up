use crate::protocol::messages::ChatMessage;
use anyhow::Result;
use rusqlite::{params, Connection};
use std::sync::{Arc, Mutex};
use uuid::Uuid;

pub struct ChatService {
    conn: Arc<Mutex<Connection>>,
    my_peer_id: String,
    my_peer_name: String,
}

impl ChatService {
    pub fn new(
        conn: Arc<Mutex<Connection>>,
        my_peer_id: String,
        my_peer_name: String,
    ) -> Self {
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
        let peer_id: String = stmt.query_row(params![id], |row| row.get(0))
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
        let peer_id: String = stmt.query_row(params![id], |row| row.get(0))
            .map_err(|_| anyhow::anyhow!("Message not found"))?;
        
        if peer_id != self.my_peer_id {
            return Err(anyhow::anyhow!("Cannot delete another user's message"));
        }

        conn.execute("DELETE FROM chat_messages WHERE id = ?1", params![id])?;
        Ok(())
    }
}

fn save_chat_message(
    conn: &Arc<Mutex<Connection>>,
    msg: &ChatMessage,
) -> Result<(), rusqlite::Error> {
    let connection = conn.lock().expect("Failed to acquire lock");
    connection.execute(
        "INSERT OR IGNORE INTO chat_messages (id, peer_id, peer_name, content, timestamp) 
         VALUES (?1, ?2, ?3, ?4, ?5)",
        params![
            msg.id,
            msg.peer_id,
            msg.peer_name,
            msg.content,
            msg.timestamp,
        ],
    )?;
    Ok(())
}

fn get_chat_messages(
    conn: &Arc<Mutex<Connection>>,
) -> Result<Vec<ChatMessage>, rusqlite::Error> {
    let connection = conn.lock().expect("Failed to acquire lock");
    let mut stmt = connection.prepare(
        "SELECT id, peer_id, peer_name, content, timestamp 
         FROM chat_messages 
         ORDER BY timestamp ASC",
    )?;

    let messages = stmt
        .query_map([], |row| {
            Ok(ChatMessage {
                id: row.get(0)?,
                peer_id: row.get(1)?,
                peer_name: row.get(2)?,
                content: row.get(3)?,
                timestamp: row.get(4)?,
            })
        })?
        .collect::<Result<Vec<_>, _>>()?;

    Ok(messages)
}
