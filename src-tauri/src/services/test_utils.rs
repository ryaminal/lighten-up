use crate::adapters::{Message, NetworkAdapter, Result};
use crate::domain::PeerId;
use async_trait::async_trait;
use std::sync::Arc;
use tokio::sync::Mutex;

type SentMessage = (Option<PeerId>, Message);
type IncomingMessage = (PeerId, Message);

/// Mock network adapter for testing
pub struct MockNetworkAdapter {
    sent_messages: Arc<Mutex<Vec<SentMessage>>>,
    incoming_messages: Arc<Mutex<Vec<IncomingMessage>>>,
}

impl Default for MockNetworkAdapter {
    fn default() -> Self {
        Self::new()
    }
}

impl MockNetworkAdapter {
    pub fn new() -> Self {
        Self {
            sent_messages: Arc::new(Mutex::new(Vec::new())),
            incoming_messages: Arc::new(Mutex::new(Vec::new())),
        }
    }

    pub async fn push_incoming(&self, peer_id: PeerId, message: Message) {
        self.incoming_messages.lock().await.push((peer_id, message));
    }

    pub async fn get_sent_messages(&self) -> Vec<SentMessage> {
        self.sent_messages.lock().await.clone()
    }

    pub async fn clear_sent(&self) {
        self.sent_messages.lock().await.clear();
    }
}

#[async_trait]
impl NetworkAdapter for MockNetworkAdapter {
    async fn start(&self) -> Result<()> {
        Ok(())
    }

    async fn stop(&self) -> Result<()> {
        Ok(())
    }

    async fn send_to_peer(&self, peer_id: &PeerId, message: Message) -> Result<()> {
        self.sent_messages
            .lock()
            .await
            .push((Some(peer_id.clone()), message));
        Ok(())
    }

    async fn broadcast(&self, message: Message) -> Result<()> {
        self.sent_messages.lock().await.push((None, message));
        Ok(())
    }

    async fn receive(&self) -> Result<(PeerId, Message)> {
        loop {
            let mut msgs = self.incoming_messages.lock().await;
            if let Some(msg) = msgs.pop() {
                return Ok(msg);
            }
            drop(msgs);
            tokio::time::sleep(tokio::time::Duration::from_millis(10)).await;
        }
    }

    async fn get_connected_peers(&self) -> Result<Vec<PeerId>> {
        Ok(Vec::new())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_mock_network_send() {
        let network = MockNetworkAdapter::new();
        let peer_id = PeerId::new("test");
        let message = Message::Heartbeat {
            peer_id: peer_id.clone(),
        };

        network.send_to_peer(&peer_id, message).await.unwrap();

        let sent = network.get_sent_messages().await;
        assert_eq!(sent.len(), 1);
    }
}
