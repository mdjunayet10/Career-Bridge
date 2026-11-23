#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-demo}"
cd "$ROOT_DIR/frontend"

case "$MODE" in
  demo)
    CONFIG="config/demo.json"
    ;;
  firebase)
    CONFIG="config/firebase.local.json"
    if [[ ! -f "$CONFIG" ]]; then
      echo "Missing frontend/config/firebase.local.json" >&2
      exit 1
    fi
    ;;
  *)
    echo "Usage: scripts/build_web.sh [demo|firebase]" >&2
    exit 1
    ;;
esac

echo "Building Career Bridge from: $ROOT_DIR"
RELEASE="$(sed -n 's/^version: //p' pubspec.yaml)"
echo "Expected release: $RELEASE"

if ! grep -Fq "Continue with Google" \
  lib/features/auth/presentation/widgets/google_sign_in_button.dart; then
  echo "Source verification failed: shared Google button is missing." >&2
  exit 1
fi

if [[ ! -f assets/logos/google_g.png ]]; then
  echo "Source verification failed: Google logo asset is missing." >&2
  exit 1
fi

if [[ "$MODE" == "firebase" ]]; then
  python3 -c 'import json, pathlib; c=json.loads(pathlib.Path("config/firebase.local.json").read_text()); assert c.get("ALLOW_DEMO_FALLBACK") is False, "Firebase production builds must not fall back to demo mode"; assert c.get("SHOW_DEMO_ACCESS") is True, "Release should include explicit demo access"; print("Verified Firebase production configuration without demo fallback.")'
fi

flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter build web --release \
  --no-wasm-dry-run \
  --pwa-strategy=none \
  --dart-define-from-file="$CONFIG"

cat > build/web/release.json <<JSON
{
  "version": "$RELEASE",
  "googleSignInButtons": true,
  "landingSampleFill": true,
  "hostingSite": "careerbridgebd"
}
JSON

echo "Release build created at frontend/build/web"
