import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/config/app_mode.dart';
import '../../../../core/services/mobile_push_service.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/controllers/auth_controller.dart';

class StartupIntroPage extends StatefulWidget {
  const StartupIntroPage({super.key});
  @override
  State<StartupIntroPage> createState() => _StartupIntroPageState();
}

class _StartupIntroPageState extends State<StartupIntroPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800));
  Timer? _introTimer;
  bool _started = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.value = 1;
    } else {
      _animation.forward();
    }
    _introTimer = Timer(const Duration(seconds: 2), _finish);
  }

  void _finish() {
    if (!mounted) return;
    final auth = AuthController.instance;
    Navigator.pushReplacementNamed(
        context,
        AppMode.adminOnly
            ? AppRoutes.adminLogin
            : auth.currentUser == null
                ? AppRoutes.home
                : auth.homeRouteFor(auth.currentUser!));
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => MobilePushService.instance.markNavigatorReady());
  }

  @override
  void dispose() {
    _introTimer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                final reveal = Curves.easeOutCubic
                    .transform((_animation.value / .45).clamp(0.0, 1.0));
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Opacity(
                      opacity: reveal,
                      child: Transform.scale(
                        scale: .88 + .12 * reveal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          decoration: BoxDecoration(
                            gradient: RadialGradient(colors: [
                              AppColors.blue.withValues(alpha: .13 * reveal),
                              AppColors.background.withValues(alpha: 0),
                            ]),
                          ),
                          child: Image.asset(
                              'assets/logos/career_bridge_nav_logo.png',
                              width: 240),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Opacity(
                      opacity: reveal,
                      child: const Text(
                        AppMode.adminOnly
                            ? 'ADMINISTRATION'
                            : 'Your next chapter starts here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: AppMode.adminOnly ? 12 : 14,
                          letterSpacing: AppMode.adminOnly ? 3 : .2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        value: _animation.value,
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: AppColors.borderMuted,
                        color: AppColors.blue,
                      ),
                    ),
                  ]),
                );
              },
            ),
          ),
        ),
      );
}
