use crate::adapters::{AdapterError, EncryptionAdapter, Message, Result};
use crate::domain::PeerId;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpStream;

/// Read an encrypted message from a TCP stream
pub async fn read_message<E: EncryptionAdapter>(
    stream: &mut TcpStream,
    encryption: &E,
) -> Result<(PeerId, Message)> {
    let len = stream
        .read_u32()
        .await
        .map_err(|e| AdapterError::Network(format!("Failed to read length: {}", e)))?
        as usize;

    let mut buf = vec![0u8; len];
    stream
        .read_exact(&mut buf)
        .await
        .map_err(|e| AdapterError::Network(format!("Failed to read message: {}", e)))?;

    let decrypted = encryption.decrypt(&buf)?;
    let message: Message = serde_json::from_slice(&decrypted)
        .map_err(|e| AdapterError::Serialization(format!("Failed to deserialize: {}", e)))?;

    let peer_id = extract_peer_id(&message)?;
    Ok((peer_id, message))
}

/// Write an encrypted message to a TCP stream
pub async fn write_message<E: EncryptionAdapter>(
    stream: &mut TcpStream,
    message: &Message,
    encryption: &E,
) -> Result<()> {
    let json = serde_json::to_vec(message)
        .map_err(|e| AdapterError::Serialization(format!("Failed to serialize: {}", e)))?;

    let encrypted = encryption.encrypt(&json)?;
    let len = encrypted.len() as u32;

    stream
        .write_u32(len)
        .await
        .map_err(|e| AdapterError::Network(format!("Failed to write length: {}", e)))?;

    stream
        .write_all(&encrypted)
        .await
        .map_err(|e| AdapterError::Network(format!("Failed to write message: {}", e)))?;

    Ok(())
}

    fn extract_peer_id(message: &Message) -> Result<PeerId> {
        match message {
            Message::Presence(presence) => {
                use crate::protocol::messages::PresenceMessage;
                match presence {
                    PresenceMessage::Online { peer_id, .. } => Ok(PeerId::new(peer_id)),
                    PresenceMessage::Goodbye { peer_id } => Ok(PeerId::new(peer_id)),
                    PresenceMessage::RequestStatus { peer_id } => Ok(PeerId::new(peer_id)),
                }
            }
            Message::Config(config) => Ok(PeerId::new(&config.peer_id)),
            Message::Chat(chat) => Ok(PeerId::new(&chat.peer_id)),
        }
    }
