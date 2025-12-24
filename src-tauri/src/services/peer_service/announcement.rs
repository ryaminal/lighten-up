use crate::adapters::{DatabaseAdapter, Message, NetworkAdapter};
use std::sync::Arc;
use tokio::sync::watch;

/// Delays between announcements at startup (in seconds)
const STARTUP_DELAYS: &[u64] = &[2, 5, 10, 30];

/// Interval for periodic announcements after startup (in seconds)
const PERIODIC_INTERVAL_SECS: u64 = 30;

/// Start a background task that announces our presence to peers
pub fn start_announcement_loop<D, N>(
    network: Arc<N>,
    database: Arc<D>,
    mut shutdown_rx: watch::Receiver<bool>,
) where
    D: DatabaseAdapter + 'static,
    N: NetworkAdapter + 'static,
{
    tokio::spawn(async move {
        send_initial_announcement(&database, &network).await;
        send_startup_announcements(&database, &network).await;
        send_periodic_announcements(&database, &network, &mut shutdown_rx).await;
    });
}

async fn send_initial_announcement<D, N>(database: &Arc<D>, network: &Arc<N>)
where
    D: DatabaseAdapter,
    N: NetworkAdapter,
{
    tokio::time::sleep(tokio::time::Duration::from_millis(500)).await;

    if let Ok(my_peer) = database.get_my_peer().await {
        let message = Message::PeerAnnouncement { peer: my_peer };
        log::info!("[ANNOUNCE] Broadcasting initial peer announcement");
        if let Err(e) = network.broadcast(message).await {
            log::debug!("Initial broadcast failed (no peers yet?): {:?}", e);
        }
    }
}

async fn send_startup_announcements<D, N>(database: &Arc<D>, network: &Arc<N>)
where
    D: DatabaseAdapter,
    N: NetworkAdapter,
{
    for delay in STARTUP_DELAYS {
        tokio::time::sleep(tokio::time::Duration::from_secs(*delay)).await;
        broadcast_announcement(database, network).await;
    }
}

async fn send_periodic_announcements<D, N>(
    database: &Arc<D>,
    network: &Arc<N>,
    shutdown_rx: &mut watch::Receiver<bool>,
) where
    D: DatabaseAdapter,
    N: NetworkAdapter,
{
    loop {
        tokio::select! {
            _ = shutdown_rx.changed() => {
                log::info!("[STOP] Stopping announcement loop");
                break;
            }
            _ = tokio::time::sleep(tokio::time::Duration::from_secs(PERIODIC_INTERVAL_SECS)) => {
                broadcast_announcement(database, network).await;
            }
        }
    }
}

async fn broadcast_announcement<D, N>(database: &Arc<D>, network: &Arc<N>)
where
    D: DatabaseAdapter,
    N: NetworkAdapter,
{
    if let Ok(my_peer) = database.get_my_peer().await {
        let message = Message::PeerAnnouncement { peer: my_peer };
        log::info!("[ANNOUNCE] Broadcasting peer announcement");
        if let Err(e) = network.broadcast(message).await {
            log::debug!("Broadcast failed: {:?}", e);
        }
    }
}
