use crate::adapters::Message;
use crate::domain::{LightColor, LightState, PeerId, VectorClock};
use crate::network::message_io;
use crate::network::tests::message_io_tests::create_test_encryption;
use std::sync::Arc;
use tokio::net::{TcpListener, TcpStream};

#[tokio::test]
async fn test_state_update_message() {
    let encryption = create_test_encryption();
    let peer_id = PeerId::new("test-peer");

    let state = LightState::new(LightColor::Red, VectorClock::new(), 12345);
    let message = Message::StateUpdate {
        peer_id: peer_id.clone(),
        state: state.clone(),
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
        Message::StateUpdate {
            peer_id: id,
            state: s,
        } => {
            assert_eq!(id, peer_id);
            assert_eq!(s.color, state.color);
            assert_eq!(s.timestamp, state.timestamp);
        }
        _ => panic!("Wrong message type"),
    }
}
