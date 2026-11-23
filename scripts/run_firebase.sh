#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVICE="${1:-}"
CONFIG_FILE="$ROOT_DIR/frontend/config/firebase.local.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Missing frontend/config/firebase.local.json" >&2
  echo "Copy firebase.example.json, replace every placeholder, and try again." >&2
  exit 1
fi

if [[ -z "$DEVICE" ]]; then
  if [[ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]]; then
    DEVICE="chrome"
  else
    DEVICE="web-server"
    echo "Chrome was not detected. Starting Flutter web-server instead."
  fi
fi

cd "$ROOT_DIR/frontend"
flutter pub get
flutter run -d "$DEVICE" --dart-define-from-file=config/firebase.local.json
