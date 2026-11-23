import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/config/app_environment.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/public_portal/controllers/public_portal_controller.dart';
import '../../features/public_portal/presentation/widgets/public_footer.dart';
import '../../features/public_portal/presentation/widgets/public_navbar.dart';

class PublicPageShell extends StatelessWidget {
  const PublicPageShell({
    required this.child,
    super.key,
    this.includeFooter = true,
    this.scrollController,
  });

  final Widget child;
  final bool includeFooter;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final portal = PublicPortalController.instance;
    return AnimatedBuilder(
      animation: portal,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const PublicNavbar(),
                if (AppEnvironment.showDemoAccess &&
                    AuthController.instance.currentUser == null &&
                    AuthController.instance.usesFirebase)
                  Material(
                    color: AppColors.card,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 3),
                      child: Row(
                        children: [
                          Icon(
                            portal.isGuestDemoPreview
                                ? Icons.science_outlined
                                : Icons.cloud_done_outlined,
                            color: AppColors.cyan,
                            size: 17,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              portal.isGuestDemoPreview
                                  ? 'DEMO PREVIEW · 20 sample jobs · 12 fictional companies'
                                  : 'LIVE FIREBASE · Actual published jobs and companies',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const Text('Demo', style: TextStyle(fontSize: 11)),
                          Switch.adaptive(
                            value: portal.isGuestDemoPreview,
                            onChanged: portal.isLoading
                                ? null
                                : (value) => portal.setGuestDemoPreview(value),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (portal.settings.maintenanceMode)
                  const _PlatformNoticeBanner(
                    icon: Icons.construction_rounded,
                    message:
                        'Career Bridge is in maintenance mode. Public browsing remains available, but some account actions may be limited.',
                    color: AppColors.yellow,
                  ),
                if (portal.sourceNotice != null)
                  _PlatformNoticeBanner(
                    icon: Icons.info_outline_rounded,
                    message: portal.sourceNotice!,
                    color: AppColors.cyan,
                  ),
                Expanded(
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: false,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          child,
                          if (includeFooter) const PublicFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlatformNoticeBanner extends StatelessWidget {
  const _PlatformNoticeBanner({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        border: Border(bottom: BorderSide(color: color.withValues(alpha: .22))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
