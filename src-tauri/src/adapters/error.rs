pub type Result<T> = std::result::Result<T, AdapterError>;

/// Errors that can occur in adapters
#[derive(Debug, thiserror::Error)]
pub enum AdapterError {
    #[error("Database error: {0}")]
    Database(String),

    #[error("Network error: {0}")]
    Network(String),

    #[error("Encryption error: {0}")]
    Encryption(String),

    #[error("Serialization error: {0}")]
    Serialization(String),

    #[error("Not found: {0}")]
    NotFound(String),

    #[error("Invalid data: {0}")]
    InvalidData(String),
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_adapter_error_display() {
        let error = AdapterError::Database("connection failed".to_string());
        assert_eq!(error.to_string(), "Database error: connection failed");

        let error = AdapterError::Network("timeout".to_string());
        assert_eq!(error.to_string(), "Network error: timeout");
    }
}
