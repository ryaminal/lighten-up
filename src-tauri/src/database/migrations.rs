use rusqlite::Connection;

pub fn run_migrations(conn: &Connection) -> Result<(), rusqlite::Error> {
    conn.execute_batch(
        "
        CREATE TABLE IF NOT EXISTS my_settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS light_config (
            id TEXT PRIMARY KEY,
            color TEXT NOT NULL,
            name TEXT NOT NULL,
            enabled INTEGER NOT NULL DEFAULT 1,
            priority INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            updated_by TEXT NOT NULL,
            UNIQUE(priority)
        );

        CREATE TABLE IF NOT EXISTS chat_messages (
            id TEXT PRIMARY KEY,
            peer_id TEXT NOT NULL,
            peer_name TEXT NOT NULL,
            content TEXT NOT NULL,
            timestamp INTEGER NOT NULL
        );

        DROP TRIGGER IF EXISTS cleanup_old_chat;

        CREATE TRIGGER cleanup_old_chat
        AFTER INSERT ON chat_messages
        BEGIN
            DELETE FROM chat_messages 
            WHERE timestamp < (strftime('%s', 'now') - 86400);
        END;
        ",
    )?;
    Ok(())
}
