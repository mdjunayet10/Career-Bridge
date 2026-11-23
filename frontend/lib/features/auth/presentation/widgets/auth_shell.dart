import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../controllers/auth_controller.dart';

class AuthShell extends StatefulWidget {
  const AuthShell({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
    this.accent = AppColors.blue,
    this.portalLabel,
    this.maxFormWidth = 560,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;
  final Color accent;
  final String? portalLabel;
  final double maxFormWidth;

  @override
  State<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<AuthShell> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= Breakpoints.desktop;
            final compactHeight = constraints.maxHeight < 780;
            final formPane = _FormPane(
              scrollController: _scrollController,
              desktop: desktop,
              compactHeight: compactHeight,
              eyebrow: widget.eyebrow,
              title: widget.title,
              subtitle: widget.subtitle,
              accent: widget.accent,
              portalLabel: widget.portalLabel,
              maxFormWidth: widget.maxFormWidth,
              child: widget.child,
            );

            if (!desktop) return formPane;

            return Row(
              children: [
                Expanded(
                  flex: 10,
                  child: _AuthVisual(
                    accent: widget.accent,
                    compactHeight: compactHeight,
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.page,
                      border: Border(
                        left: BorderSide(color: AppColors.borderMuted),
                      ),
                    ),
                    child: formPane,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FormPane extends StatelessWidget {
  const _FormPane({
    required this.scrollController,
    required this.desktop,
    required this.compactHeight,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.portalLabel,
    required this.maxFormWidth,
    required this.child,
  });

  final ScrollController scrollController;
  final bool desktop;
  final bool compactHeight;
  final String eyebrow;
  final String title;
  final String subtitle;
  final Color accent;
  final String? portalLabel;
  final double maxFormWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: desktop,
      child: SingleChildScrollView(
        controller: scrollController,
        padding: EdgeInsets.fromLTRB(
          desktop ? 44 : 18,
          compactHeight ? 22 : (desktop ? 34 : 20),
          desktop ? 44 : 18,
          42,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxFormWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AuthTopBar(desktop: desktop),
                SizedBox(height: compactHeight ? 24 : 34),
                if (portalLabel != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .11),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: accent.withValues(alpha: .27),
                        ),
                      ),
                      child: Text(
                        portalLabel!,
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                          letterSpacing: .7,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 17),
                ],
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: desktop ? 31 : 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -.65,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        height: 1.55,
                      ),
                ),
                SizedBox(height: compactHeight ? 22 : 28),
                if (AuthController.instance.initializationNotice != null) ...[
                  _InitializationNotice(
                    message: AuthController.instance.initializationNotice!,
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  padding: EdgeInsets.all(maxFormWidth > 650 ? 24 : 22),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .18),
                        blurRadius: 34,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTopBar extends StatelessWidget {
  const _AuthTopBar({required this.desktop});

  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.outlined(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          },
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded, size: 19),
        ),
        const Spacer(),
        if (!desktop)
          InkWell(
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (_) => false,
            ),
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/logos/career_bridge_nav_logo.png',
              width: 126,
              filterQuality: FilterQuality.high,
            ),
          ),
      ],
    );
  }
}

class _AuthVisual extends StatelessWidget {
  const _AuthVisual({
    required this.accent,
    required this.compactHeight,
  });

  final Color accent;
  final bool compactHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.page,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.borderMuted),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: .18),
            AppColors.page,
            AppColors.purple.withValues(alpha: .11),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: .09),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: .18),
                    blurRadius: 110,
                    spreadRadius: 18,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: -100,
            bottom: -130,
            child: Container(
              width: 330,
              height: 330,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyan.withValues(alpha: .055),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compactHeight ? 38 : 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/logos/career_bridge_nav_logo.png',
                  width: compactHeight ? 154 : 178,
                  filterQuality: FilterQuality.high,
                ),
                const Spacer(),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: accent.withValues(alpha: .32),
                    ),
                  ),
                  child: Icon(Icons.route_rounded, color: accent, size: 28),
                ),
                const SizedBox(height: 22),
                Text(
                  'One platform.\nA clearer career journey.',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: compactHeight ? 34 : 42,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                        letterSpacing: -1.25,
                      ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Job seekers discover opportunities. Employers build teams. Administrators keep the platform trusted.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    height: 1.6,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 27),
                const Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _TrustChip(
                      icon: Icons.verified_user_outlined,
                      label: 'Protected roles',
                    ),
                    _TrustChip(
                      icon: Icons.apartment_rounded,
                      label: 'Verified companies',
                    ),
                    _TrustChip(
                      icon: Icons.lock_outline_rounded,
                      label: 'Secure access',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _InitializationNotice extends StatelessWidget {
  const _InitializationNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.yellow.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.yellow.withValues(alpha: .30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.yellow,
            size: 20,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
