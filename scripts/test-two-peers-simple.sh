#!/bin/bash

# Simple script to test two peers by running the built binary twice

PEER1_NAME="${1:-Alice}"
PEER2_NAME="${2:-Bob}"

cd "$(dirname "$0")/.."

echo "Building application (this may take a while)..."
cargo build --manifest-path src-tauri/Cargo.toml 2>&1 | tail -10

BINARY="./src-tauri/target/debug/lighten-up"

if [ ! -f "$BINARY" ]; then
    echo "Error: Binary not found at $BINARY"
    exit 1
fi

# Create separate data directories
DATA_DIR1="/tmp/lighten-up-peer1"
DATA_DIR2="/tmp/lighten-up-peer2"

rm -rf "$DATA_DIR1" "$DATA_DIR2"
mkdir -p "$DATA_DIR1" "$DATA_DIR2"

echo ""
echo "========================================="
echo "Starting Peer 1: $PEER1_NAME"
echo "Data: $DATA_DIR1"
echo "========================================="
LIGHTEN_UP_PEER_NAME="$PEER1_NAME" LIGHTEN_UP_DATA_DIR="$DATA_DIR1" "$BINARY" > /tmp/peer1.log 2>&1 &
PEER1_PID=$!

sleep 3

echo ""
echo "========================================="
echo "Starting Peer 2: $PEER2_NAME"  
echo "Data: $DATA_DIR2"
echo "========================================="
LIGHTEN_UP_PEER_NAME="$PEER2_NAME" LIGHTEN_UP_DATA_DIR="$DATA_DIR2" "$BINARY" > /tmp/peer2.log 2>&1 &
PEER2_PID=$!

echo ""
echo "Both peers started!"
echo "Peer 1 ($PEER1_NAME) PID: $PEER1_PID"
echo "Peer 2 ($PEER2_NAME) PID: $PEER2_PID"
echo ""
echo "Logs:"
echo "  Peer 1: tail -f /tmp/peer1.log"
echo "  Peer 2: tail -f /tmp/peer2.log"
echo ""
echo "Press Ctrl+C to stop both peers..."

# Trap Ctrl+C to kill both processes
trap "echo ''; echo 'Stopping peers...'; kill $PEER1_PID $PEER2_PID 2>/dev/null; sleep 1; echo 'Stopped'; exit" INT

# Wait
wait
