#!/usr/bin/env bash
# Signet — launches the local signing app in your browser.
cd "$(dirname "$0")"
PORT=8000
echo "Signet running at:  http://localhost:$PORT"
echo "(Ctrl+C to stop)"
( sleep 1; xdg-open "http://localhost:$PORT" >/dev/null 2>&1 || true ) &
python3 -m http.server $PORT
