#!/bin/bash

# Test script with clean logs
# Usage: ./scripts/test-with-logs.sh

echo "=========================================="
echo "Starting Lighten Up"
echo "=========================================="
echo ""
echo "Open DevTools (F12) and check the Console tab"
echo "Click a color button and watch the logs"
echo ""
echo "Press Ctrl+C to stop"
echo ""
echo "=========================================="
echo ""

./src-tauri/target/release/lighten-up
