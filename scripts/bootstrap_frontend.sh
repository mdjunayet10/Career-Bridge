#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/frontend"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not installed or not available in PATH." >&2
  echo "Install Flutter, run 'flutter doctor', then rerun this script." >&2
  exit 1
fi

cd "$FRONTEND_DIR"
BACKUP_DIR="$(mktemp -d)"
BACKUP_ARCHIVE="$BACKUP_DIR/career_bridge_custom.tar"
CUSTOM_PATHS=(lib assets test web config pubspec.yaml analysis_options.yaml)

cleanup() {
  rm -rf "$BACKUP_DIR"
}
trap cleanup EXIT

echo "Backing up Career Bridge source files..."
tar -cf "$BACKUP_ARCHIVE" "${CUSTOM_PATHS[@]}"

restore_custom_files() {
  rm -rf lib assets test web config
  rm -f pubspec.yaml analysis_options.yaml README.md
  tar -xf "$BACKUP_ARCHIVE"
}

if ! flutter create . \
  --project-name career_bridge \
  --org com.careerbridge \
  --platforms=android,ios,web; then
  echo "Flutter platform generation failed. Restoring source files..." >&2
  restore_custom_files
  exit 1
fi

restore_custom_files
flutter pub get

echo
printf '%s\n' "Frontend platform wrappers are ready." \
  "Next: $ROOT_DIR/scripts/run_demo.sh"
