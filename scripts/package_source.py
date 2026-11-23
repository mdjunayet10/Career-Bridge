#!/usr/bin/env python3
"""Create a complete, portable source ZIP without machine caches or private data."""
from pathlib import Path
import fnmatch
import sys
import zipfile

root = Path(__file__).resolve().parents[1]
import re
version = re.search(r'^version:\s*([^+\s]+)', (root / 'frontend/pubspec.yaml').read_text(), re.MULTILINE).group(1)
output = Path(sys.argv[1]).expanduser().resolve() if len(sys.argv) > 1 else root.parent / f'Career-Bridge-Full-Source-{version}.zip'
skip_dirs = {'.firebase', '.git', '.dart_tool', '.gradle', 'node_modules', 'build', 'output', 'private', '__pycache__', 'Pods', '.symlinks', '.idea', '.kotlin', '.cxx', 'ephemeral', '.plugin_symlinks'}
skip_names = {'.DS_Store', 'local.properties', '.flutter-plugins-dependencies', '.flutter-plugins', 'firebase.local.json', 'google-services.json', 'GoogleService-Info.plist', 'key.properties'}
patterns = ['*.log', '*.keystore', '*.jks', '.env', '.env.*', '*service-account*.json', '*firebase-adminsdk-*.json']
with zipfile.ZipFile(output, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
    for path in sorted(root.rglob('*')):
        if not path.is_file():
            continue
        relative = path.relative_to(root)
        if set(relative.parts) & skip_dirs or path.name in skip_names:
            continue
        if any(fnmatch.fnmatch(path.name, pattern) for pattern in patterns) or path.resolve() == output:
            continue
        archive.write(path, Path('Career-Bridge') / relative)
with zipfile.ZipFile(output) as archive:
    bad = archive.testzip()
    if bad:
        raise RuntimeError(f'Archive integrity failure: {bad}')
    names = set(archive.namelist())
    for required in ['frontend/lib/main.dart', 'frontend/pubspec.lock', 'frontend/assets/cv_fonts/lmroman10-regular.ttf',
                     'frontend/assets/fonts/Sora-400.ttf', 'frontend/android/gradlew', 'backend/functions/index.js',
                     'backend/firebase/firestore.rules', 'README_DELIVERY.md']:
        if 'Career-Bridge/' + required not in names:
            raise RuntimeError(f'Missing source component: {required}')
    if any('/private/' in name or '/node_modules/' in name for name in names):
        raise RuntimeError('Private data or dependencies included unexpectedly')
print(f'Verified {len(names)} files: {output} ({output.stat().st_size:,} bytes)')
