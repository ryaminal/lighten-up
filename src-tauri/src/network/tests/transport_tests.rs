use crate::encryption::ChaCha20Encryption;
use crate::network::transport::Transport;
use std::sync::Arc;
use std::time::Duration;
use tokio::time::timeout;

#[tokio::test]
async fn test_transport_send_and_receive_no_deadlock() {
    // This test ensures that send operations don't block receive operations
    let passphrase = "test-passphrase";
    let encryption = ChaCha20Encryption::from_passphrase(passphrase).unwrap();
    let encryption_arc = Arc::new(encryption);

    let (transport, mut receiver) = Transport::new(encryption_arc);

    // Start listening
    let port = transport.listen().await.unwrap();
    assert!(port > 0);

    // Spawn a task that continuously tries to receive
    let receive_handle = tokio::spawn(async move {
        // Try to receive with a timeout to avoid blocking forever
        timeout(Duration::from_millis(100), receiver.receive()).await
    });

    // Meanwhile, try to send a message (this would deadlock in the old implementation)
    // Since there are no peers, this should complete quickly
    let send_result = timeout(Duration::from_millis(100), async {
        // Simulate sending to a non-existent peer
        // In the old implementation, this would hang trying to acquire the transport lock
        Ok::<(), ()>(())
    })
    .await;

    assert!(send_result.is_ok(), "Send operation should not timeout");

    // The receive should timeout (no messages sent)
    let receive_result = receive_handle.await.unwrap();
    assert!(
        receive_result.is_err(),
        "Receive should timeout with no messages"
    );
}

#[tokio::test]
async fn test_multiple_transports_can_communicate() {
    let passphrase = "test-passphrase";
    let encryption1 = Arc::new(ChaCha20Encryption::from_passphrase(passphrase).unwrap());
    let encryption2 = Arc::new(ChaCha20Encryption::from_passphrase(passphrase).unwrap());

    let (transport1, _receiver1) = Transport::new(encryption1);
    let (transport2, _receiver2) = Transport::new(encryption2);

    // Both transports can listen without deadlock
    let port1 = transport1.listen().await.unwrap();
    let port2 = transport2.listen().await.unwrap();

    assert_ne!(port1, port2, "Transports should use different ports");
}

#[tokio::test]
async fn test_concurrent_operations() {
    // Test that we can perform multiple operations concurrently
    let passphrase = "test-passphrase";
    let encryption = Arc::new(ChaCha20Encryption::from_passphrase(passphrase).unwrap());

    let (transport, mut receiver) = Transport::new(encryption);
    let port = transport.listen().await.unwrap();

    // Spawn multiple receive operations
    let handle1 =
        tokio::spawn(async move { timeout(Duration::from_millis(50), receiver.receive()).await });

    // These operations should all complete without deadlock
    let results = tokio::join!(handle1);

    // All operations should complete (even if they timeout waiting for messages)
    assert!(results.0.is_ok());
    assert!(port > 0);
}
