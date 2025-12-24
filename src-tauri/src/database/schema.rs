use rusqlite::Connection;

use crate::adapters::Result;

/// SQL schema for the database
pub const CREATE_PEERS_TABLE: &str = "
CREATE TABLE IF NOT EXISTS peers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    light_color TEXT NOT NULL,
    vector_clock TEXT NOT NULL,
    timestamp INTEGER NOT NULL
)";

pub const CREATE_MY_PEER_TABLE: &str = "
CREATE TABLE IF NOT EXISTS my_peer (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    peer_id TEXT NOT NULL,
    name TEXT NOT NULL,
    light_color TEXT NOT NULL,
    vector_clock TEXT NOT NULL,
    timestamp INTEGER NOT NULL
)";

/// Initialize database schema
pub fn initialize_schema(conn: &Connection) -> Result<()> {
    conn.execute(CREATE_PEERS_TABLE, [])?;
    conn.execute(CREATE_MY_PEER_TABLE, [])?;
    Ok(())
}
