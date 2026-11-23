import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_initializer.dart';
import 'app/mobile_bootstrap.dart';
import 'app/startup_error_app.dart';
import 'app/web_url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureWebUrlStrategy();
  if (!kIsWeb) {
    runApp(const CareerBridgeBootstrap());
    return;
  }

  Object? startupError;
  StackTrace? startupStackTrace;
  try {
    await AppInitializer.initialize();
  } catch (error, stackTrace) {
    startupError = error;
    startupStackTrace = stackTrace;
  }

  if (startupError != null) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: startupError,
        stack: startupStackTrace,
        library: 'Career Bridge startup',
      ),
    );
    runApp(CareerBridgeStartupErrorApp(error: startupError));
    return;
  }

  if (kDebugMode) {
    debugPrint('Career Bridge initialized successfully.');
  }
  runApp(const CareerBridgeApp());
}
