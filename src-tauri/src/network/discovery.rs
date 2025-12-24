use crate::adapters::{AdapterError, Result};
use crate::domain::PeerId;
use crate::network::discovery_handler;
use crate::network::peer_info::PeerConnection;
use mdns_sd::{ServiceDaemon, ServiceInfo};
use std::collections::HashMap;
use std::net::{IpAddr, Ipv4Addr};
use std::sync::Arc;
use tokio::sync::Mutex;

// mDNS discovery is not fully integrated yet
#[allow(dead_code)]
const SERVICE_TYPE: &str = "_lightenup._tcp.local.";

/// mDNS service discovery manager
#[allow(dead_code)]
pub struct Discovery {
    daemon: ServiceDaemon,
    my_peer_id: PeerId,
    my_port: u16,
    peers: Arc<Mutex<HashMap<String, PeerConnection>>>,
}

impl Discovery {
    /// Create a new discovery manager
    pub fn new(my_peer_id: PeerId, my_port: u16) -> Result<Self> {
        let daemon = ServiceDaemon::new()
            .map_err(|e| AdapterError::Network(format!("Failed to create mDNS daemon: {}", e)))?;

        Ok(Self {
            daemon,
            my_peer_id,
            my_port,
            peers: Arc::new(Mutex::new(HashMap::new())),
        })
    }

    /// Register our service
    #[allow(dead_code)]
    pub fn register(&self) -> Result<()> {
        let service_name = format!("{}.{}", self.my_peer_id.as_str(), SERVICE_TYPE);
        let host_name = format!("{}.local.", self.my_peer_id.as_str());

        let service_info = ServiceInfo::new(
            SERVICE_TYPE,
            &service_name,
            &host_name,
            IpAddr::V4(Ipv4Addr::UNSPECIFIED),
            self.my_port,
            None,
        )
        .map_err(|e| AdapterError::Network(format!("Failed to create service info: {}", e)))?;

        self.daemon
            .register(service_info)
            .map_err(|e| AdapterError::Network(format!("Failed to register service: {}", e)))?;

        Ok(())
    }

    /// Start browsing for peers
    #[allow(dead_code)]
    pub fn browse(&self) -> Result<()> {
        let receiver = self
            .daemon
            .browse(SERVICE_TYPE)
            .map_err(|e| AdapterError::Network(format!("Failed to browse services: {}", e)))?;

        let peers = self.peers.clone();
        let my_peer_id = self.my_peer_id.clone();

        tokio::spawn(async move {
            while let Ok(event) = receiver.recv() {
                discovery_handler::handle_event(event, &peers, &my_peer_id).await;
            }
        });

        Ok(())
    }

    /// Get all discovered peers
    pub async fn get_peers(&self) -> Vec<PeerConnection> {
        self.peers.lock().await.values().cloned().collect()
    }
}
