use rusqlite::Connection;
use std::sync::{Arc, Mutex};

pub fn execute_query<F, R>(
    conn: &Arc<Mutex<Connection>>,
    f: F,
) -> Result<R, rusqlite::Error>
where
    F: FnOnce(&Connection) -> Result<R, rusqlite::Error>,
{
    let connection = conn
        .lock()
        .expect("Failed to acquire database lock");
    f(&connection)
}
