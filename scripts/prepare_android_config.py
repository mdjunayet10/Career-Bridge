#!/usr/bin/env python3
"""Generate Android public Firebase client config from the local runtime config."""
import json
from pathlib import Path
root = Path(__file__).resolve().parents[1]
config = json.loads((root / 'frontend/config/firebase.local.json').read_text())
target = root / 'frontend/android/app/google-services.json'
if not target.exists():
    target.write_text(json.dumps({
        'project_info': {'project_number': config['FIREBASE_MESSAGING_SENDER_ID'],
                         'project_id': config['FIREBASE_PROJECT_ID']},
        'client': [{'client_info': {'mobilesdk_app_id': config['FIREBASE_ANDROID_APP_ID'],
                                  'android_client_info': {'package_name': 'com.careerbridge.career_bridge'}},
                    'api_key': [{'current_key': config['FIREBASE_ANDROID_API_KEY']}],
                    'oauth_client': ([{'client_id': config['GOOGLE_WEB_CLIENT_ID'], 'client_type': 3}]
                                     if config.get('GOOGLE_WEB_CLIENT_ID') else [])}],
        'configuration_version': '1'
    }, indent=2) + '\n')
    print('Created Android Firebase client configuration.')
