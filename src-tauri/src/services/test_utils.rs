use crate::adapters::{DatabaseAdapter, Message, NetworkAdapter, Result};
use crate::domain::{LightState, PeerId, PeerInfo};
use async_trait::async_trait;
use std::collections::HashMap;
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

/// Mock database adapter for testing
pub struct MockDatabaseAdapter {
    my_peer: Arc<Mutex<Option<PeerInfo>>>,
    peers: Arc<Mutex<HashMap<String, PeerInfo>>>,
}

impl Default for MockDatabaseAdapter {
    fn default() -> Self {
        Self::new()
    }
}

impl MockDatabaseAdapter {
    pub fn new() -> Self {
        Self {
            my_peer: Arc::new(Mutex::new(None)),
            peers: Arc::new(Mutex::new(HashMap::new())),
        }
    }
}

#[async_trait]
impl DatabaseAdapter for MockDatabaseAdapter {
    async fn initialize(&self) -> Result<()> {
        Ok(())
    }

    async fn save_my_peer(&self, peer: &PeerInfo) -> Result<()> {
        *self.my_peer.lock().await = Some(peer.clone());
        Ok(())
    }

    async fn get_my_peer(&self) -> Result<PeerInfo> {
        self.my_peer
            .lock()
            .await
            .clone()
            .ok_or_else(|| crate::adapters::AdapterError::Database("My peer not found".to_string()))
    }

    async fn update_my_name(&self, name: String) -> Result<()> {
        let mut peer = self.get_my_peer().await?;
        peer.name = name;
        self.save_my_peer(&peer).await
    }

    async fn update_my_light_state(&self, state: &LightState) -> Result<()> {
        let mut peer = self.get_my_peer().await?;
        peer.light_state = state.clone();
        self.save_my_peer(&peer).await
    }

    async fn save_peer(&self, peer: &PeerInfo) -> Result<()> {
        self.peers
            .lock()
            .await
            .insert(peer.id.as_str().to_string(), peer.clone());
        Ok(())
    }

    async fn get_peer(&self, peer_id: &PeerId) -> Result<PeerInfo> {
        self.peers
            .lock()
            .await
            .get(peer_id.as_str())
            .cloned()
            .ok_or_else(|| {
                crate::adapters::AdapterError::Database(format!("Peer {} not found", peer_id))
            })
    }

    async fn get_all_peers(&self) -> Result<Vec<PeerInfo>> {
        Ok(self.peers.lock().await.values().cloned().collect())
    }

    async fn delete_peer(&self, peer_id: &PeerId) -> Result<()> {
        self.peers.lock().await.remove(peer_id.as_str());
        Ok(())
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
