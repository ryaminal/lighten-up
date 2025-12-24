#!/bin/bash
# Simple test to check if app starts and responds

echo "Testing Lighten Up UI..."
echo ""
echo "1. Starting app in background..."
./src-tauri/target/release/lighten-up &
APP_PID=$!

echo "   App PID: $APP_PID"
echo ""
echo "2. Waiting 3 seconds for app to initialize..."
sleep 3

echo ""
echo "3. App should now be running. Test steps:"
echo "   a) Check that the window opened"
echo "   b) Open DevTools (F12 or right-click > Inspect)"
echo "   c) Go to Console tab"
echo "   d) Click a color button (like 'Green')"
echo "   e) Watch the console for logs"
echo ""
echo "4. Check backend logs in another terminal:"
echo "   tail -f ~/.local/share/com.cadams.lighten-up/logs/lighten-up.log | grep -E '(COMMAND|set_light_color|update_and_persist|forward_event)'"
echo ""
echo "Press Ctrl+C to stop monitoring, then kill app with: kill $APP_PID"
echo ""
echo "Monitoring logs..."
tail -f ~/.local/share/com.cadams.lighten-up/logs/lighten-up.log | grep -E "(COMMAND|set_light_color|update_and_persist|forward_event|MyStateChanged)"
