use crate::adapters::{AdapterError, EncryptionAdapter, Message, Result};
use crate::domain::PeerId;
use crate::network::message_io;
use std::net::SocketAddr;
use std::sync::Arc;
use tokio::net::{TcpListener, TcpStream};
use tokio::sync::mpsc;

/// TCP transport with encryption
pub struct Transport<E: EncryptionAdapter + Send + Sync + 'static> {
    encryption: Arc<E>,
    incoming_tx: mpsc::UnboundedSender<(PeerId, Message)>,
}

/// Receiver for incoming messages (separated to avoid mutex contention)
pub struct TransportReceiver {
    incoming_rx: mpsc::UnboundedReceiver<(PeerId, Message)>,
}

impl TransportReceiver {
    /// Receive incoming message
    pub async fn receive(&mut self) -> Option<(PeerId, Message)> {
        self.incoming_rx.recv().await
    }
}

impl<E: EncryptionAdapter + Send + Sync + 'static> Transport<E> {
    /// Create a new transport, returning both the transport and receiver
    pub fn new(encryption: Arc<E>) -> (Self, TransportReceiver) {
        let (incoming_tx, incoming_rx) = mpsc::unbounded_channel();

        let transport = Self {
            encryption,
            incoming_tx,
        };

        let receiver = TransportReceiver { incoming_rx };

        (transport, receiver)
    }

    /// Start listening on a random port
    pub async fn listen(&self) -> Result<u16> {
        let listener = TcpListener::bind("0.0.0.0:0")
            .await
            .map_err(|e| AdapterError::Network(format!("Failed to bind listener: {}", e)))?;

        let port = listener
            .local_addr()
            .map_err(|e| AdapterError::Network(format!("Failed to get local addr: {}", e)))?
            .port();

        self.start_accept_loop(listener);

        Ok(port)
    }

    fn start_accept_loop(&self, listener: TcpListener) {
        let incoming_tx = self.incoming_tx.clone();
        let encryption = self.encryption.clone();

        tokio::spawn(async move {
            loop {
                if let Ok((stream, _)) = listener.accept().await {
                    Self::spawn_handler(stream, incoming_tx.clone(), encryption.clone());
                }
            }
        });
    }

    fn spawn_handler(
        mut stream: TcpStream,
        tx: mpsc::UnboundedSender<(PeerId, Message)>,
        encryption: Arc<E>,
    ) {
        tokio::spawn(async move {
            let peer_addr = stream.peer_addr().ok();
            log::info!("[CONN] New connection from {:?}", peer_addr);
            loop {
                match message_io::read_message(&mut stream, &*encryption).await {
                    Ok((peer_id, message)) => {
                        log::info!(
                            "[RECV] Received message from {}: {:?}",
                            peer_id.as_str(),
                            message
                        );
                        if tx.send((peer_id, message)).is_err() {
                            log::warn!("Failed to send message to channel");
                            break;
                        }
                    }
                    Err(e) => {
                        log::error!(
                            "[ERROR] Error reading message from {:?}: {:?}",
                            peer_addr,
                            e
                        );
                        break;
                    }
                }
            }
            log::info!("[CONN] Connection closed from {:?}", peer_addr);
        });
    }

    /// Connect to a peer
    pub async fn connect(&self, addr: SocketAddr) -> Result<TcpStream> {
        TcpStream::connect(addr)
            .await
            .map_err(|e| AdapterError::Network(format!("Failed to connect: {}", e)))
    }

    /// Send message to a peer
    pub async fn send(&self, addr: SocketAddr, message: &Message) -> Result<()> {
        log::info!("[EVENT] Sending message to {}: {:?}", addr, message);
        let mut stream = self.connect(addr).await?;
        message_io::write_message(&mut stream, message, &*self.encryption).await
    }
}
