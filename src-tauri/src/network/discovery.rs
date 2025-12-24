use crate::adapters::{AdapterError, Result};
use crate::domain::PeerId;
use crate::network::discovery_handler;
use crate::network::peer_info::PeerConnection;
use mdns_sd::{ServiceDaemon, ServiceInfo};
use std::collections::HashMap;
use std::net::{IpAddr, Ipv4Addr};
use std::sync::Arc;
use tokio::sync::Mutex;

const SERVICE_TYPE: &str = "_lightenup._tcp.local.";

/// mDNS service discovery manager
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
    pub fn register(&self) -> Result<()> {
        // Instance name is just the peer ID (e.g., "alice")
        let instance_name = self.my_peer_id.as_str();
        let host_name = format!("{}.local.", self.my_peer_id.as_str());
        
        // Get local IP - use empty string to let mdns-sd handle it
        let my_addrs = if_addrs::get_if_addrs()
            .ok()
            .and_then(|addrs| {
                addrs.into_iter()
                    .find(|addr| !addr.is_loopback() && addr.ip().is_ipv4())
                    .map(|addr| addr.ip())
            });

        let service_info = ServiceInfo::new(
            SERVICE_TYPE,
            instance_name,
            &host_name,
            my_addrs.unwrap_or(IpAddr::V4(Ipv4Addr::LOCALHOST)),
            self.my_port,
            None,
        )
        .map_err(|e| AdapterError::Network(format!("Failed to create service info: {}", e)))?;
        
        log::info!("Registering mDNS service: instance='{}', type='{}', host='{}', addr={:?}, port={}", 
            instance_name, SERVICE_TYPE, host_name, my_addrs, self.my_port);

        self.daemon
            .register(service_info)
            .map_err(|e| AdapterError::Network(format!("Failed to register service: {}", e)))?;

        Ok(())
    }

    /// Start browsing for peers
    pub fn browse(&self) -> Result<()> {
        let receiver = self
            .daemon
            .browse(SERVICE_TYPE)
            .map_err(|e| AdapterError::Network(format!("Failed to browse services: {}", e)))?;

        let peers = self.peers.clone();
        let my_peer_id = self.my_peer_id.clone();

        // Use spawn_blocking since mdns-sd receiver is synchronous
        std::thread::spawn(move || {
            log::info!("🔍 mDNS browser thread started");
            while let Ok(event) = receiver.recv() {
                log::debug!("📡 Received mDNS event: {:?}", event);
                // Spawn async task to handle the event
                let peers_clone = peers.clone();
                let my_peer_id_clone = my_peer_id.clone();
                tokio::spawn(async move {
                    discovery_handler::handle_event(event, &peers_clone, &my_peer_id_clone).await;
                });
            }
            log::warn!("🔍 mDNS browser thread ended");
        });

        Ok(())
    }

    /// Get all discovered peers
    pub async fn get_peers(&self) -> Vec<PeerConnection> {
        self.peers.lock().await.values().cloned().collect()
    }
}
