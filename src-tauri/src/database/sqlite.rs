use crate::adapters::{AdapterError, Result};
use rusqlite::Connection;
use std::sync::{Arc, Mutex};

/// SQLite implementation of DatabaseAdapter
pub struct SqliteDatabase {
    pub(crate) conn: Arc<Mutex<Connection>>,
}

impl SqliteDatabase {
    /// Create a new SQLite database adapter
    pub fn new(path: &str) -> Result<Self> {
        let conn = Connection::open(path)
            .map_err(|e| AdapterError::Database(format!("Failed to open database: {}", e)))?;

        Ok(Self {
            conn: Arc::new(Mutex::new(conn)),
        })
    }

    /// Create an in-memory database (for testing)
    pub fn in_memory() -> Result<Self> {
        let conn = Connection::open_in_memory().map_err(|e| {
            AdapterError::Database(format!("Failed to create in-memory database: {}", e))
        })?;

        Ok(Self {
            conn: Arc::new(Mutex::new(conn)),
        })
    }
}
