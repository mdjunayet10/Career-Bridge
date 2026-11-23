import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
    super.key,
    this.action,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.35,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMuted,
                      height: 1.65,
                    ),
              ),
            ),
          ],
        );

        if (compact || action == null) return copy;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: copy),
            const SizedBox(width: 24),
            action!,
          ],
        );
      },
    );
  }
}
