import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class HoverCard extends StatefulWidget {
  const HoverCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(22),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor:
          widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.cardHover : AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered
                  ? AppColors.blue.withValues(alpha: .52)
                  : AppColors.border,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.blueStrong.withValues(alpha: .13),
                      blurRadius: 34,
                      offset: const Offset(0, 16),
                    ),
                  ]
                : const [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
