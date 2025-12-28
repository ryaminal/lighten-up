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

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::migrations::run_migrations;
    use rusqlite::Connection;

    fn setup_test_db() -> Arc<Mutex<Connection>> {
        let conn = Connection::open_in_memory().expect("Failed to create in-memory DB");
        run_migrations(&conn).expect("Failed to run migrations");
        Arc::new(Mutex::new(conn))
    }

    fn create_test_service() -> ChatService {
        ChatService::new(
            setup_test_db(),
            "test-peer-id".to_string(),
            "Test Peer".to_string(),
        )
    }

    #[tokio::test]
    async fn send_message_creates_message_with_correct_fields() {
        let service = create_test_service();

        let result = service.send_message("Hello world".to_string()).await;

        assert!(result.is_ok());
        let msg = result.unwrap();
        assert_eq!(msg.peer_id, "test-peer-id");
        assert_eq!(msg.peer_name, "Test Peer");
        assert_eq!(msg.content, "Hello world");
        assert!(!msg.id.is_empty());
        assert!(msg.timestamp > 0);
    }

    #[tokio::test]
    async fn send_message_persists_to_database() {
        let service = create_test_service();

        let sent = service
            .send_message("Persistent message".to_string())
            .await
            .unwrap();
        let messages = service.get_all_messages().await.unwrap();

        assert_eq!(messages.len(), 1);
        assert_eq!(messages[0].id, sent.id);
        assert_eq!(messages[0].content, "Persistent message");
    }

    #[tokio::test]
    async fn send_message_rejects_content_over_500_chars() {
        let service = create_test_service();
        let long_content = "a".repeat(501);

        let result = service.send_message(long_content).await;

        assert!(result.is_err());
        match result.unwrap_err() {
            AppError::Other(e) => assert!(e.to_string().contains("exceeds maximum length")),
            _ => panic!("Expected Other error"),
        }
    }

    #[tokio::test]
    async fn send_message_accepts_content_at_500_chars() {
        let service = create_test_service();
        let max_content = "a".repeat(500);

        let result = service.send_message(max_content.clone()).await;

        assert!(result.is_ok());
        assert_eq!(result.unwrap().content, max_content);
    }

    #[tokio::test]
    async fn handle_message_persists_incoming_message() {
        let service = create_test_service();
        let incoming = ChatMessage {
            id: "remote-msg-1".to_string(),
            peer_id: "remote-peer".to_string(),
            peer_name: "Remote Peer".to_string(),
            content: "Hello from remote".to_string(),
            timestamp: crate::utils::current_timestamp(),
        };

        let result = service.handle_message(incoming.clone()).await;

        assert!(result.is_ok());
        let messages = service.get_all_messages().await.unwrap();
        assert_eq!(messages.len(), 1);
        assert_eq!(messages[0].id, "remote-msg-1");
        assert_eq!(messages[0].peer_id, "remote-peer");
    }

    #[tokio::test]
    async fn get_all_messages_returns_empty_when_no_messages() {
        let service = create_test_service();

        let messages = service.get_all_messages().await.unwrap();

        assert_eq!(messages.len(), 0);
    }

    #[tokio::test]
    async fn get_all_messages_returns_messages_ordered_by_timestamp() {
        let service = create_test_service();
        let base_time = crate::utils::current_timestamp();
        let msg1 = ChatMessage {
            id: "msg1".to_string(),
            peer_id: "peer1".to_string(),
            peer_name: "Peer 1".to_string(),
            content: "First".to_string(),
            timestamp: base_time,
        };
        let msg2 = ChatMessage {
            id: "msg2".to_string(),
            peer_id: "peer2".to_string(),
            peer_name: "Peer 2".to_string(),
            content: "Second".to_string(),
            timestamp: base_time + 1000,
        };
        let msg3 = ChatMessage {
            id: "msg3".to_string(),
            peer_id: "peer3".to_string(),
            peer_name: "Peer 3".to_string(),
            content: "Third".to_string(),
            timestamp: base_time + 500,
        };

        service.handle_message(msg1).await.unwrap();
        service.handle_message(msg2).await.unwrap();
        service.handle_message(msg3).await.unwrap();

        let messages = service.get_all_messages().await.unwrap();
        assert_eq!(messages.len(), 3);
        assert_eq!(messages[0].timestamp, base_time);
        assert_eq!(messages[1].timestamp, base_time + 500);
        assert_eq!(messages[2].timestamp, base_time + 1000);
    }

    #[tokio::test]
    async fn edit_message_updates_content_and_timestamp() {
        let service = create_test_service();
        let original = service
            .send_message("Original content".to_string())
            .await
            .unwrap();
        let original_timestamp = original.timestamp;

        tokio::time::sleep(tokio::time::Duration::from_millis(10)).await;
        let edited = service
            .edit_message(original.id.clone(), "Edited content".to_string())
            .await
            .unwrap();

        assert_eq!(edited.id, original.id);
        assert_eq!(edited.content, "Edited content");
        assert!(edited.timestamp >= original_timestamp);

        let messages = service.get_all_messages().await.unwrap();
        assert_eq!(messages.len(), 1);
        assert_eq!(messages[0].content, "Edited content");
    }

    #[tokio::test]
    async fn edit_message_denies_editing_other_peers_message() {
        let service = create_test_service();
        let other_msg = ChatMessage {
            id: "other-msg".to_string(),
            peer_id: "other-peer".to_string(),
            peer_name: "Other Peer".to_string(),
            content: "Their message".to_string(),
            timestamp: crate::utils::current_timestamp(),
        };
        service.handle_message(other_msg).await.unwrap();

        let result = service
            .edit_message("other-msg".to_string(), "Hacked".to_string())
            .await;

        assert!(result.is_err());
        match result.unwrap_err() {
            AppError::PermissionDenied => {}
            e => panic!("Expected PermissionDenied, got {:?}", e),
        }

        let messages = service.get_all_messages().await.unwrap();
        assert_eq!(messages[0].content, "Their message");
    }

    #[tokio::test]
    async fn edit_message_returns_not_found_for_nonexistent_message() {
        let service = create_test_service();

        let result = service
            .edit_message("nonexistent".to_string(), "New content".to_string())
            .await;

        assert!(result.is_err());
        match result.unwrap_err() {
            AppError::NotFound => {}
            e => panic!("Expected NotFound, got {:?}", e),
        }
    }

    #[tokio::test]
    async fn delete_message_removes_own_message() {
        let service = create_test_service();
        let msg = service
            .send_message("To be deleted".to_string())
            .await
            .unwrap();

        let result = service.delete_message(msg.id.clone()).await;

        assert!(result.is_ok());
        let messages = service.get_all_messages().await.unwrap();
        assert_eq!(messages.len(), 0);
    }

    #[tokio::test]
    async fn delete_message_denies_deleting_other_peers_message() {
        let service = create_test_service();
        let other_msg = ChatMessage {
            id: "other-msg".to_string(),
            peer_id: "other-peer".to_string(),
            peer_name: "Other Peer".to_string(),
            content: "Protected message".to_string(),
            timestamp: crate::utils::current_timestamp(),
        };
        service.handle_message(other_msg).await.unwrap();

        let result = service.delete_message("other-msg".to_string()).await;

        assert!(result.is_err());
        match result.unwrap_err() {
            AppError::PermissionDenied => {}
            e => panic!("Expected PermissionDenied, got {:?}", e),
        }

        let messages = service.get_all_messages().await.unwrap();
        assert_eq!(messages.len(), 1);
    }

    #[tokio::test]
    async fn delete_message_returns_not_found_for_nonexistent_message() {
        let service = create_test_service();

        let result = service.delete_message("nonexistent".to_string()).await;

        assert!(result.is_err());
        match result.unwrap_err() {
            AppError::NotFound => {}
            e => panic!("Expected NotFound, got {:?}", e),
        }
    }

    #[tokio::test]
    async fn multiple_messages_from_different_peers() {
        let service = create_test_service();
        let _my_msg = service
            .send_message("My message".to_string())
            .await
            .unwrap();
        let other_msg = ChatMessage {
            id: "other-msg".to_string(),
            peer_id: "other-peer".to_string(),
            peer_name: "Other Peer".to_string(),
            content: "Their message".to_string(),
            timestamp: crate::utils::current_timestamp(),
        };
        service.handle_message(other_msg).await.unwrap();

        let messages = service.get_all_messages().await.unwrap();

        assert_eq!(messages.len(), 2);
        let peer_ids: Vec<&str> = messages.iter().map(|m| m.peer_id.as_str()).collect();
        assert!(peer_ids.contains(&"test-peer-id"));
        assert!(peer_ids.contains(&"other-peer"));
    }
}
