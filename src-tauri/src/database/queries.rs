use crate::database::connection::execute_query;
use crate::protocol::messages::LightConfig;
use rusqlite::{Connection, OptionalExtension, params};
use std::sync::{Arc, Mutex};

// Settings queries
pub fn get_setting(
    conn: &Arc<Mutex<Connection>>,
    key: &str,
) -> Result<Option<String>, rusqlite::Error> {
    execute_query(conn, |c| {
        c.query_row(
            "SELECT value FROM my_settings WHERE key = ?1",
            params![key],
            |row| row.get(0),
        )
        .optional()
    })
}

pub fn set_setting(
    conn: &Arc<Mutex<Connection>>,
    key: &str,
    value: &str,
) -> Result<(), rusqlite::Error> {
    execute_query(conn, |c| {
        c.execute(
            "INSERT OR REPLACE INTO my_settings (key, value) VALUES (?1, ?2)",
            params![key, value],
        )?;
        Ok(())
    })
}

// Light config queries
pub fn get_all_lights(conn: &Arc<Mutex<Connection>>) -> Result<Vec<LightConfig>, rusqlite::Error> {
    execute_query(conn, |c| {
        let mut stmt = c.prepare(
            "SELECT id, color, name, enabled, priority, updated_at, updated_by 
             FROM light_config 
             ORDER BY priority ASC",
        )?;

        let lights = stmt
            .query_map([], |row| {
                Ok(LightConfig {
                    id: row.get(0)?,
                    color: row.get(1)?,
                    name: row.get(2)?,
                    enabled: row.get(3)?,
                    priority: row.get(4)?,
                    updated_at: row.get(5)?,
                    updated_by: row.get(6)?,
                })
            })?
            .collect::<Result<Vec<_>, _>>()?;

        Ok(lights)
    })
}

pub fn upsert_light(
    conn: &Arc<Mutex<Connection>>,
    light: &LightConfig,
) -> Result<(), rusqlite::Error> {
    execute_query(conn, |c| {
        c.execute(
            "INSERT OR REPLACE INTO light_config 
             (id, color, name, enabled, priority, updated_at, updated_by) 
             VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)",
            params![
                light.id,
                light.color,
                light.name,
                light.enabled,
                light.priority,
                light.updated_at,
                light.updated_by,
            ],
        )?;
        Ok(())
    })
}

pub fn delete_light(conn: &Arc<Mutex<Connection>>, id: &str) -> Result<(), rusqlite::Error> {
    execute_query(conn, |c| {
        c.execute("DELETE FROM light_config WHERE id = ?1", params![id])?;
        Ok(())
    })
}
