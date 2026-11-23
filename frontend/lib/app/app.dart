import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../features/public_portal/presentation/pages/startup_intro_page.dart';
import '../core/services/mobile_push_service.dart';
import 'config/app_mode.dart';
import 'router/app_router.dart';
import 'router/app_routes.dart';
import 'theme/app_theme.dart';

class CareerBridgeApp extends StatefulWidget {
  const CareerBridgeApp({super.key});
  @override
  State<CareerBridgeApp> createState() => _CareerBridgeAppState();
}

class _CareerBridgeAppState extends State<CareerBridgeApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MobilePushService.instance.attach();
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
        MobilePushService.instance.markNavigatorReady();
      }
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: AppMode.adminOnly ? 'Career Bridge Admin' : 'Career Bridge',
        debugShowCheckedModeBanner: false,
        navigatorKey: careerBridgeNavigatorKey,
        theme: AppTheme.dark,
        initialRoute: AppMode.adminOnly ? AppRoutes.adminLogin : AppRoutes.home,
        onGenerateInitialRoutes: (initialRoute) => !kIsWeb &&
                defaultTargetPlatform == TargetPlatform.android
            ? [
                MaterialPageRoute<void>(
                    settings: const RouteSettings(name: '/startup-intro'),
                    builder: (_) => const StartupIntroPage())
              ]
            : [AppRouter.onGenerateRoute(RouteSettings(name: initialRoute))],
        onGenerateRoute: AppRouter.onGenerateRoute,
      );
}
