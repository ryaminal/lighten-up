#!/usr/bin/env bash
set -euo pipefail

pnpm exec svelte-kit sync
set +e
pnpm tauri build
set -e

rm -rf /tmp/lighten-up-*

./src-tauri/target/release/lighten-up --id alice --name "Alice" --data-dir /tmp/lighten-up-alice &
./src-tauri/target/release/lighten-up --id bob --name "Bob" --data-dir /tmp/lighten-up-alice &
./src-tauri/target/release/lighten-up --id charlie --name "Charlie" --data-dir /tmp/lighten-up-alice &
