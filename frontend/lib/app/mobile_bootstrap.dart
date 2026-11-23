import 'package:flutter/material.dart';
import 'app.dart';
import 'app_initializer.dart';
import 'startup_error_app.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';

/// Draw branding immediately while Firebase restores the saved session.
class CareerBridgeBootstrap extends StatefulWidget {
  const CareerBridgeBootstrap({super.key, this.initialize});
  final Future<void> Function()? initialize;
  @override
  State<CareerBridgeBootstrap> createState() => _CareerBridgeBootstrapState();
}

class _CareerBridgeBootstrapState extends State<CareerBridgeBootstrap> {
  late final Future<void> _startup =
      (widget.initialize ?? AppInitializer.initialize)();
  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
      future: _startup,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CareerBridgeStartupErrorApp(error: snapshot.error!);
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const CareerBridgeApp();
        }
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            home: Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                  child: Center(
                      child: Padding(
                          padding: const EdgeInsets.all(32),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Image.asset(
                                'assets/logos/career_bridge_nav_logo.png',
                                width: 240),
                            const SizedBox(height: 24),
                            Semantics(
                                label: 'Opening Career Bridge',
                                child: const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))),
                          ])))),
            ));
      });
}
