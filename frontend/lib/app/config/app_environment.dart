import 'package:flutter/foundation.dart';

abstract final class AppEnvironment {
  static const name = String.fromEnvironment(
    'APP_ENVIRONMENT',
    defaultValue: 'demo',
  );

  static const useFirebase = bool.fromEnvironment(
    'USE_FIREBASE_AUTH',
    defaultValue: kReleaseMode,
  );

  static const allowDemoFallback = bool.fromEnvironment(
    'ALLOW_DEMO_FALLBACK',
    defaultValue: !kReleaseMode,
  );

  static const showDemoAccess = bool.fromEnvironment(
    'SHOW_DEMO_ACCESS',
    defaultValue: true,
  );

  static bool get isProduction => name.toLowerCase() == 'production';
}
