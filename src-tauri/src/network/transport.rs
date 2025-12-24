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
    incoming_rx: mpsc::UnboundedReceiver<(PeerId, Message)>,
    incoming_tx: mpsc::UnboundedSender<(PeerId, Message)>,
}

impl<E: EncryptionAdapter + Send + Sync + 'static> Transport<E> {
    /// Create a new transport
    pub fn new(encryption: Arc<E>) -> Self {
        let (incoming_tx, incoming_rx) = mpsc::unbounded_channel();

        Self {
            encryption,
            incoming_rx,
            incoming_tx,
        }
    }

    /// Start listening on a random port
    pub async fn listen(&mut self) -> Result<u16> {
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
            while let Ok((peer_id, message)) =
                message_io::read_message(&mut stream, &*encryption).await
            {
                if tx.send((peer_id, message)).is_err() {
                    break;
                }
            }
        });
    }

    /// Receive incoming message
    pub async fn receive(&mut self) -> Option<(PeerId, Message)> {
        self.incoming_rx.recv().await
    }

    /// Connect to a peer
    pub async fn connect(&self, addr: SocketAddr) -> Result<TcpStream> {
        TcpStream::connect(addr)
            .await
            .map_err(|e| AdapterError::Network(format!("Failed to connect: {}", e)))
    }

    /// Send message to a peer
    pub async fn send(&self, addr: SocketAddr, message: &Message) -> Result<()> {
        let mut stream = self.connect(addr).await?;
        message_io::write_message(&mut stream, message, &*self.encryption).await
    }
}
