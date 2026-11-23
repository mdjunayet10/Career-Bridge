#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${JAVA_HOME:-}" ]] || ! "$JAVA_HOME/bin/java" -version >/dev/null 2>&1; then
  if [[ -d "/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home" ]]; then
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home"
    export PATH="$JAVA_HOME/bin:$PATH"
  elif /usr/libexec/java_home -v 21 >/dev/null 2>&1; then
    export JAVA_HOME="$(/usr/libexec/java_home -v 21)"
    export PATH="$JAVA_HOME/bin:$PATH"
  fi
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT/frontend"
MODE="${1:-release}"
FLUTTER="${FLUTTER_BIN:-flutter}"
VERSION="$(sed -n 's/^version: \([^+]*\).*/\1/p' pubspec.yaml)"
mkdir -p "$ROOT/output/apk"
python3 "$ROOT/scripts/prepare_android_config.py"
"$FLUTTER" pub get
for PORTAL in user admin; do
  FLAGS=(--dart-define=ADMIN_APP=false)
  if [[ "$PORTAL" == admin ]]; then FLAGS=(--dart-define=ADMIN_APP=true); fi
  "$FLUTTER" build apk "--$MODE" --flavor "$PORTAL" --target-platform android-arm,android-arm64,android-x64 \
    --dart-define-from-file=config/firebase.local.json "${FLAGS[@]}"
  cp "build/app/outputs/flutter-apk/app-$PORTAL-$MODE.apk" "$ROOT/output/apk/Career-Bridge-$PORTAL-$VERSION-$MODE-universal.apk"
  if [[ "$PORTAL" == "user" ]]; then
    cp "build/app/outputs/flutter-apk/app-$PORTAL-$MODE.apk" "$ROOT/output/apk/Career-Bridge-User-$VERSION.apk"
  else
    cp "build/app/outputs/flutter-apk/app-$PORTAL-$MODE.apk" "$ROOT/output/apk/Career-Bridge-Admin-$VERSION.apk"
  fi
  if [[ "$PORTAL" == "user" ]]; then NAME=User; else NAME=Admin; fi
  cp "build/app/outputs/flutter-apk/app-$PORTAL-$MODE.apk" "$ROOT/output/apk/Career-Bridge-$NAME-Latest.apk"
done
