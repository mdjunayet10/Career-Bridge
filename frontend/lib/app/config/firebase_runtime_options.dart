import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract final class FirebaseRuntimeOptions {
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _messagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');

  static const _webApiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
  static const _webAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const _measurementId =
      String.fromEnvironment('FIREBASE_MEASUREMENT_ID');

  static const _androidApiKey =
      String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
  static const _androidAppId =
      String.fromEnvironment('FIREBASE_ANDROID_APP_ID');

  static const _iosApiKey = String.fromEnvironment('FIREBASE_IOS_API_KEY');
  static const _iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
  static const _iosBundleId = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

  static FirebaseOptions get currentPlatform {
    _require('FIREBASE_PROJECT_ID', _projectId);
    _require('FIREBASE_MESSAGING_SENDER_ID', _messagingSenderId);

    if (kIsWeb) {
      _require('FIREBASE_WEB_API_KEY', _webApiKey);
      _require('FIREBASE_WEB_APP_ID', _webAppId);
      return FirebaseOptions(
        apiKey: _webApiKey,
        appId: _webAppId,
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        authDomain: _optional(_authDomain),
        measurementId: _optional(_measurementId),
      );
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _android,
      TargetPlatform.iOS => _ios,
      TargetPlatform.macOS => _ios,
      _ => throw StateError(
          'Firebase mode is configured for Career Bridge Web, Android, and iOS only.',
        ),
    };
  }

  static FirebaseOptions get _android {
    _require('FIREBASE_ANDROID_API_KEY', _androidApiKey);
    _require('FIREBASE_ANDROID_APP_ID', _androidAppId);
    return const FirebaseOptions(
      apiKey: _androidApiKey,
      appId: _androidAppId,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
    );
  }

  static FirebaseOptions get _ios {
    _require('FIREBASE_IOS_API_KEY', _iosApiKey);
    _require('FIREBASE_IOS_APP_ID', _iosAppId);
    return FirebaseOptions(
      apiKey: _iosApiKey,
      appId: _iosAppId,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      iosBundleId: _optional(_iosBundleId),
    );
  }

  static void _require(String key, String value) {
    if (value.trim().isEmpty || value.contains('REPLACE_')) {
      throw StateError(
        '$key is missing. Copy frontend/config/firebase.example.json to '
        'frontend/config/firebase.local.json and replace every placeholder.',
      );
    }
  }

  static String? _optional(String value) =>
      value.trim().isEmpty || value.contains('REPLACE_') ? null : value.trim();
}
