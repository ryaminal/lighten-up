#!/bin/bash
# Complete test with clear instructions

echo "=================================="
echo "  Lighten Up - Complete UI Test"
echo "=================================="
echo ""
echo "INSTRUCTIONS:"
echo "1. The app will start in a moment"
echo "2. When the window opens:"
echo "   - Right-click anywhere and select 'Inspect' (or press F12)"
echo "   - Click the 'Console' tab"
echo "   - Leave DevTools open"
echo "3. Click any color button (Green, Red, Yellow, etc.)"
echo "4. Watch BOTH:"
echo "   - Browser console (in DevTools)"
echo "   - This terminal (backend logs)"
echo ""
echo "What to look for:"
echo "   Frontend logs: 'handleColorChange called', 'Calling setLightColor'"  
echo "   Backend logs:  'COMMAND set_light_color CALLED', 'COMPLETED'"
echo ""
echo "If you see frontend logs but NO backend logs:"
echo "   → The command isn't reaching Rust (IPC issue)"
echo ""
echo "If you see NO frontend logs at all:"
echo "   → JavaScript might be frozen or event not firing"
echo ""
echo "Press ENTER to start the app..."
read

echo ""
echo "Starting application..."
echo "=================================="
echo ""

# Run in background and get PID
./src-tauri/target/release/lighten-up &
APP_PID=$!

echo "App started (PID: $APP_PID)"
echo ""
echo "Backend logs will appear below:"
echo "--------------------------------"
echo ""

# Monitor logs with grep filtering
tail -f ~/.local/share/com.cadams.lighten-up/logs/lighten-up.log 2>/dev/null | grep --line-buffered -E "(COMMAND|set_light_color|forward_event|MyStateChanged|ERROR|WARN)" &
TAIL_PID=$!

# Wait for user to test
echo ""
echo "Press Ctrl+C when done testing..."
wait $TAIL_PID

# Cleanup
kill $APP_PID 2>/dev/null
kill $TAIL_PID 2>/dev/null
