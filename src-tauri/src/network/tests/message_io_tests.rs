use crate::adapters::Message;
use crate::domain::PeerId;
use crate::encryption::ChaCha20Encryption;
use crate::network::message_io;
use std::sync::Arc;
use tokio::net::{TcpListener, TcpStream};

pub fn create_test_encryption() -> ChaCha20Encryption {
    let key = [42u8; 32];
    ChaCha20Encryption::from_key_bytes(&key).unwrap()
}

#[tokio::test]
async fn test_message_io_roundtrip() {
    let encryption = create_test_encryption();
    let peer_id = PeerId::new("test-peer");

    let message = Message::Heartbeat {
        peer_id: peer_id.clone(),
    };

    let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
    let addr = listener.local_addr().unwrap();

    let encryption_clone = Arc::new(encryption);
    let message_clone = message.clone();

    tokio::spawn(async move {
        let (mut stream, _) = listener.accept().await.unwrap();
        message_io::write_message(&mut stream, &message_clone, &*encryption_clone)
            .await
            .unwrap();
    });

    let encryption2 = create_test_encryption();
    let mut client = TcpStream::connect(addr).await.unwrap();

    let (received_peer_id, received_message) = message_io::read_message(&mut client, &encryption2)
        .await
        .unwrap();

    assert_eq!(received_peer_id, peer_id);
    match received_message {
        Message::Heartbeat { peer_id: id } => assert_eq!(id, peer_id),
        _ => panic!("Wrong message type"),
    }
}

#[tokio::test]
async fn test_message_io_invalid_decryption() {
    let encryption1 = create_test_encryption();

    let key2 = [43u8; 32];
    let encryption2 = ChaCha20Encryption::from_key_bytes(&key2).unwrap();

    let peer_id = PeerId::new("test-peer");
    let message = Message::Heartbeat {
        peer_id: peer_id.clone(),
    };

    let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
    let addr = listener.local_addr().unwrap();

    let encryption1_clone = Arc::new(encryption1);
    let message_clone = message.clone();

    tokio::spawn(async move {
        let (mut stream, _) = listener.accept().await.unwrap();
        message_io::write_message(&mut stream, &message_clone, &*encryption1_clone)
            .await
            .unwrap();
    });

    let mut client = TcpStream::connect(addr).await.unwrap();

    let result = message_io::read_message(&mut client, &encryption2).await;
    assert!(result.is_err());
}
