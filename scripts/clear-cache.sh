#!/bin/bash
# Clear Vite and SvelteKit caches to fix PostCSS errors

echo "Stopping dev server..."
pkill -f "vite dev" 2>/dev/null || true

echo "Clearing caches..."
rm -rf node_modules/.vite .svelte-kit

echo "Caches cleared! You can restart the dev server now."
