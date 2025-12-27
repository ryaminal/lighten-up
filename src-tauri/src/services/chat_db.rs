use crate::domain::ChatMessage;
use rusqlite::{Connection, params};
use std::sync::{Arc, Mutex};

/// Saves a chat message to the database.
pub(crate) fn save_chat_message(
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

/// Retrieves all chat messages from the database.
pub(crate) fn get_chat_messages(
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
