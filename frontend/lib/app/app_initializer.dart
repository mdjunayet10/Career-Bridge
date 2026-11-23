import 'dart:async';
import 'package:flutter/foundation.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/public_portal/controllers/public_portal_controller.dart';

abstract final class AppInitializer {
  static Future<void> initialize() async {
    await AuthController.instance.initialize();
    if (kIsWeb) {
      await PublicPortalController.instance.initialize();
    } else {
      // Public listings cannot hold the native login screen hostage offline.
      unawaited(PublicPortalController.instance
          .initialize()
          .catchError((Object _) {}));
    }
  }
}
