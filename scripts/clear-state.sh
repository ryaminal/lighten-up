#!/bin/bash
# Clear all application state for testing

echo "Clearing Lighten Up application state..."

# Tauri store directory
STORE_DIR="$HOME/.local/share/com.cadams.lighten-up"

echo "Clearing all data: $STORE_DIR"
rm -f "$STORE_DIR/store.json"
rm -f "$STORE_DIR/lighten-up-data.json"

# Clear logs (optional - comment out if you want to keep logs)
echo "Clearing logs: $STORE_DIR/logs/"
rm -f "$STORE_DIR/logs/"*.log

# Old databases (shouldn't exist anymore but just in case)
rm -f /tmp/lighten-up.db
rm -f "$STORE_DIR/lighten-up.db"

echo ""
echo "State cleared! Next run will start fresh with:"
echo "  - New peer ID"
echo "  - Empty peer list"
echo "  - Fresh logs"
echo ""
echo "All state is now stored in: $STORE_DIR"

