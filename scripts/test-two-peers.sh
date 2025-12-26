#!/bin/bash

# Script to run two instances of lighten-up for testing

PEER1_NAME="${1:-Peer1}"
PEER2_NAME="${2:-Peer2}"

echo "Starting two instances of lighten-up..."
echo "Peer 1: $PEER1_NAME on port 1420"
echo "Peer 2: $PEER2_NAME on port 1421"
echo ""

# Build first
echo "Building application..."
cd "$(dirname "$0")"
pnpm tauri build --debug 2>&1 | tail -5

# Get the binary path
BINARY="./src-tauri/target/debug/lighten-up"

if [ ! -f "$BINARY" ]; then
    echo "Error: Binary not found at $BINARY"
    exit 1
fi

# Create separate data directories
DATA_DIR1="/tmp/lighten-up-peer1"
DATA_DIR2="/tmp/lighten-up-peer2"

mkdir -p "$DATA_DIR1"
mkdir -p "$DATA_DIR2"

echo ""
echo "Starting Peer 1 ($PEER1_NAME)..."
LIGHTEN_UP_PEER_NAME="$PEER1_NAME" "$BINARY" --data-dir "$DATA_DIR1" &
PEER1_PID=$!

sleep 2

echo "Starting Peer 2 ($PEER2_NAME)..."
LIGHTEN_UP_PEER_NAME="$PEER2_NAME" "$BINARY" --data-dir "$DATA_DIR2" &
PEER2_PID=$!

echo ""
echo "Both peers started!"
echo "Peer 1 PID: $PEER1_PID"
echo "Peer 2 PID: $PEER2_PID"
echo ""
echo "Press Ctrl+C to stop both peers..."

# Trap Ctrl+C to kill both processes
trap "kill $PEER1_PID $PEER2_PID 2>/dev/null; echo 'Stopped both peers'; exit" INT

# Wait for both processes
wait
