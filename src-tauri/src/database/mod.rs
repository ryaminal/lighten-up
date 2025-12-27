pub mod connection;
pub mod migrations;
pub mod queries;

use rusqlite::Connection;
use std::path::PathBuf;
use std::sync::{Arc, Mutex};

pub struct Database {
    conn: Arc<Mutex<Connection>>,
}

impl Database {
    pub fn new(path: PathBuf) -> Result<Self, rusqlite::Error> {
        let conn = Connection::open(path)?;
        migrations::run_migrations(&conn)?;
        Ok(Self {
            conn: Arc::new(Mutex::new(conn)),
        })
    }

    pub fn connection(&self) -> Arc<Mutex<Connection>> {
        self.conn.clone()
    }

    pub fn get_setting(&self, key: &str) -> Option<String> {
        queries::get_setting(&self.conn, key).ok().flatten()
    }

    pub fn set_setting(&self, key: &str, value: &str) -> Result<(), String> {
        queries::set_setting(&self.conn, key, value).map_err(|e| e.to_string())
    }
}
