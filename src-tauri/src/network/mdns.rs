use crate::adapters::{EncryptionAdapter, Message, NetworkAdapter, Result};
use crate::domain::PeerId;
use crate::network::discovery::Discovery;
use crate::network::transport::{Transport, TransportReceiver};
use async_trait::async_trait;
use std::sync::Arc;
use tokio::sync::Mutex;

/// mDNS-based network adapter
pub struct MdnsNetwork<E: EncryptionAdapter + Send + Sync + 'static> {
    _encryption: Arc<E>,
    my_peer_id: PeerId,
    discovery: Arc<Mutex<Option<Discovery>>>,
    transport: Arc<Transport<E>>,
    receiver: Arc<Mutex<TransportReceiver>>,
}

impl<E: EncryptionAdapter + Send + Sync + 'static> MdnsNetwork<E> {
    /// Create a new mDNS network adapter
    pub fn new(my_peer_id: PeerId, encryption: E) -> Self {
        let encryption = Arc::new(encryption);
        let (transport, receiver) = Transport::new(encryption.clone());

        Self {
            _encryption: encryption,
            my_peer_id,
            discovery: Arc::new(Mutex::new(None)),
            transport: Arc::new(transport),
            receiver: Arc::new(Mutex::new(receiver)),
        }
    }
}

#[async_trait]
impl<E: EncryptionAdapter + Send + Sync + 'static> NetworkAdapter for MdnsNetwork<E> {
    async fn start(&self) -> Result<()> {
        let port = self.transport.listen().await?;
        let discovery = Discovery::new(self.my_peer_id.clone(), port)?;
        
        // Register our service so other peers can discover us
        discovery.register()?;
        log::info!("📡 Registered mDNS service on port {}", port);
        
        // Start browsing for other peers
        discovery.browse()?;
        log::info!("🔍 Started browsing for peers");
        
        *self.discovery.lock().await = Some(discovery);
        Ok(())
    }

    async fn send_to_peer(&self, peer_id: &PeerId, message: Message) -> Result<()> {
        let discovery = self.discovery.lock().await;
        if let Some(disc) = discovery.as_ref() {
            let peers = disc.get_peers().await;
            if let Some(peer) = peers.iter().find(|p| &p.peer_id == peer_id) {
                self.transport.send(peer.addr, &message).await?;
            }
        }
        Ok(())
    }

    async fn broadcast(&self, message: Message) -> Result<()> {
        log::info!("🌐 broadcast: acquiring discovery lock");
        let discovery = self.discovery.lock().await;
        log::info!("🌐 broadcast: got discovery lock");
        if let Some(disc) = discovery.as_ref() {
            let peers = disc.get_peers().await;
            log::info!("🌐 broadcast: found {} peers", peers.len());
            drop(discovery); // Release discovery lock

            log::info!("🌐 broadcast: sending to all peers");
            for peer in peers {
                log::info!("🌐 broadcast: sending to peer {:?}", peer.peer_id);
                let _ = self.transport.send(peer.addr, &message).await;
            }
            log::info!("🌐 broadcast: done sending to all peers");
        } else {
            log::info!("🌐 broadcast: no discovery service");
        }
        log::info!("🌐 broadcast: returning");
        Ok(())
    }

    async fn receive(&self) -> Result<(PeerId, Message)> {
        self.receiver
            .lock()
            .await
            .receive()
            .await
            .ok_or_else(|| crate::adapters::AdapterError::Network("Channel closed".to_string()))
    }

    async fn stop(&self) -> Result<()> {
        *self.discovery.lock().await = None;
        Ok(())
    }

    async fn get_connected_peers(&self) -> Result<Vec<PeerId>> {
        let discovery = self.discovery.lock().await;
        if let Some(disc) = discovery.as_ref() {
            Ok(disc
                .get_peers()
                .await
                .into_iter()
                .map(|p| p.peer_id)
                .collect())
        } else {
            Ok(Vec::new())
        }
    }
}
