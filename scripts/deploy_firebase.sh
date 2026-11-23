#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIREBASE_DIR="$ROOT_DIR/backend/firebase"
WEB_BUILD_DIR="$ROOT_DIR/frontend/build/web"
HOSTING_PUBLIC_DIR="$FIREBASE_DIR/public"
HOSTING_TARGET="careerbridgebd"
RELEASE="$(sed -n 's/^version: //p' "$ROOT_DIR/frontend/pubspec.yaml")"

echo "============================================================"
echo "Deploying Career Bridge release $RELEASE"
echo "Project folder: $ROOT_DIR"
echo "Live site: https://careerbridgebd.web.app"
echo "============================================================"

if ! command -v firebase >/dev/null 2>&1; then
  echo "Firebase CLI is missing. Install it with: npm install -g firebase-tools" >&2
  exit 1
fi

"$ROOT_DIR/scripts/build_web.sh" firebase

if [[ ! -f "$WEB_BUILD_DIR/main.dart.js" ]]; then
  echo "Missing frontend/build/web/main.dart.js after the web build." >&2
  exit 1
fi

if ! grep -Fq "Continue with Google" "$WEB_BUILD_DIR/main.dart.js"; then
  echo "Bundle verification failed: Google button text is missing." >&2
  exit 1
fi

if [[ ! -f "$WEB_BUILD_DIR/assets/assets/logos/google_g.png" ]]; then
  echo "Bundle verification failed: Google logo asset is missing." >&2
  exit 1
fi

echo "Verified Google Sign-In UI and logo in the production bundle."

# Deploy the verified build directly to the existing site. Avoid copying stale
# assets or relying on a cloud-only .firebaserc file.
cd "$ROOT_DIR"
firebase deploy --project career-bridge-dd01c \
  --config firebase.hosting.local.json --only hosting

echo
echo "Deployment finished. Verify the live release with:"
echo "curl -s 'https://careerbridgebd.web.app/release.json?$(date +%s)'"
echo
echo "Expected: $RELEASE"
