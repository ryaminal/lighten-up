use crate::domain::PeerId;
use crate::network::peer_info::PeerConnection;
use mdns_sd::{ResolvedService, ServiceEvent};
use std::collections::HashMap;
use std::net::{IpAddr, SocketAddr};
use std::sync::Arc;
use tokio::sync::Mutex;

/// Handle mDNS service discovery events
pub async fn handle_event(
    event: ServiceEvent,
    peers: &Arc<Mutex<HashMap<String, PeerConnection>>>,
    my_peer_id: &PeerId,
) {
    match event {
        ServiceEvent::ServiceResolved(info) => {
            if let Some(peer_conn) = extract_peer_info(&info, my_peer_id) {
                peers
                    .lock()
                    .await
                    .insert(peer_conn.peer_id.as_str().to_string(), peer_conn);
            }
        }
        ServiceEvent::ServiceRemoved(_, fullname) => {
            if let Some(peer_id) = extract_peer_id(&fullname) {
                peers.lock().await.remove(peer_id.as_str());
            }
        }
        _ => {}
    }
}

fn extract_peer_info(info: &ResolvedService, my_peer_id: &PeerId) -> Option<PeerConnection> {
    let peer_id_str = info.get_fullname().split('.').next()?;
    let peer_id = PeerId::new(peer_id_str);

    if peer_id == *my_peer_id {
        return None;
    }

    let scoped_ip = info.get_addresses().iter().next()?;
    let ip_addr: IpAddr = scoped_ip.to_string().parse().ok()?;
    let addr = SocketAddr::new(ip_addr, info.get_port());
    Some(PeerConnection::new(peer_id, addr))
}

fn extract_peer_id(fullname: &str) -> Option<PeerId> {
    let peer_id_str = fullname.split('.').next()?;
    Some(PeerId::new(peer_id_str))
}
