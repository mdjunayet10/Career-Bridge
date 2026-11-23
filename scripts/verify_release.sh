#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-demo}"
RUN_RULES_TESTS="${RUN_RULES_TESTS:-0}"

case "$MODE" in
  demo)
    CONFIG_FILE="$ROOT_DIR/frontend/config/demo.json"
    ;;
  firebase)
    CONFIG_FILE="$ROOT_DIR/frontend/config/firebase.local.json"
    if [[ ! -f "$CONFIG_FILE" ]]; then
      echo "Missing frontend/config/firebase.local.json" >&2
      echo "Copy firebase.example.json, replace every placeholder, and retry." >&2
      exit 1
    fi
    ;;
  *)
    echo "Usage: scripts/verify_release.sh [demo|firebase]" >&2
    exit 1
    ;;
esac

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not installed or is not available in PATH." >&2
  echo "Install Flutter stable, run 'flutter doctor', then rerun this script." >&2
  exit 1
fi

mkdir -p "$ROOT_DIR/validation_logs"
LOG_FILE="$ROOT_DIR/validation_logs/verify_${MODE}_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee "$LOG_FILE") 2>&1

echo "Career Bridge release verification"
echo "Mode: $MODE"
echo "Log: $LOG_FILE"
echo

python3 "$ROOT_DIR/scripts/check_project.py"

if [[ ! -f "$ROOT_DIR/frontend/.metadata" || ! -d "$ROOT_DIR/frontend/android" || ! -d "$ROOT_DIR/frontend/ios" ]]; then
  "$ROOT_DIR/scripts/bootstrap_frontend.sh"
fi

cd "$ROOT_DIR/frontend"
flutter --version
flutter doctor -v
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build web --release --dart-define-from-file="$CONFIG_FILE"

if [[ "$RUN_RULES_TESTS" == "1" ]]; then
  if ! command -v node >/dev/null 2>&1 || ! command -v java >/dev/null 2>&1; then
    echo "RUN_RULES_TESTS=1 was requested, but Node.js or Java is missing." >&2
    exit 1
  fi
  cd "$ROOT_DIR/backend/tests/firestore_rules"
  npm install
  npm test
else
  echo
  echo "Firestore emulator tests skipped. Run with RUN_RULES_TESTS=1 to include them."
fi

echo
echo "Verification passed."
echo "Web release: $ROOT_DIR/frontend/build/web"
echo "Log saved to: $LOG_FILE"
