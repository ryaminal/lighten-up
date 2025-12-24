#!/bin/bash
# Test the UI with comprehensive logging

echo "=== Lighten Up UI Test ==="
echo ""
echo "State locations:"
echo "  Database: /tmp/lighten-up.db"
echo "  Store:    ~/.local/share/com.cadams.lighten-up/store.json"
echo "  Logs:     ~/.local/share/com.cadams.lighten-up/logs/"
echo ""
echo "To clear state before testing, run: ./scripts/clear-state.sh"
echo ""
echo "Starting application..."
echo "==================================="
echo ""

# Run the app
./src-tauri/target/release/lighten-up "$@"
