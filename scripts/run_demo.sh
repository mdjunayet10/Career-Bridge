#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REQUESTED_DEVICE="${1:-auto}"
WEB_PORT="${WEB_PORT:-7357}"
cd "$ROOT_DIR/frontend"

flutter pub get

DEVICE="$REQUESTED_DEVICE"
if [[ "$REQUESTED_DEVICE" == "auto" ]]; then
  if flutter devices --machine 2>/dev/null | grep -q '"id":"chrome"'; then
    DEVICE="chrome"
  else
    DEVICE="web-server"
  fi
fi

if [[ "$DEVICE" == "web-server" ]]; then
  URL="http://127.0.0.1:${WEB_PORT}"
  echo "Chrome was not detected. Starting Flutter web-server instead."
  echo "The app will open at: $URL"
  (
    for _ in $(seq 1 90); do
      if curl -fsS "$URL" >/dev/null 2>&1; then
        if command -v open >/dev/null 2>&1; then
          open "$URL" >/dev/null 2>&1 || true
        fi
        exit 0
      fi
      sleep 1
    done
  ) &
  exec flutter run \
    -d web-server \
    --web-hostname 127.0.0.1 \
    --web-port "$WEB_PORT" \
    --dart-define-from-file=config/demo.json
fi

exec flutter run -d "$DEVICE" --dart-define-from-file=config/demo.json
