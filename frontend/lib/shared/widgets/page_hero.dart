import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'section_container.dart';

class PageHero extends StatelessWidget {
  const PageHero({
    required this.eyebrow,
    required this.title,
    required this.description,
    super.key,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.page,
        border: const Border(
          bottom: BorderSide(color: AppColors.borderMuted),
        ),
        gradient: LinearGradient(
          colors: [
            AppColors.page,
            AppColors.blueStrong.withValues(alpha: .055),
            AppColors.page,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SectionContainer(
        padding: const EdgeInsets.fromLTRB(24, 42, 24, 40),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.cyan,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 11),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: compact ? 32 : 42,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                        letterSpacing: -1.05,
                      ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textMuted,
                          height: 1.58,
                          fontSize: compact ? 14 : 15,
                        ),
                  ),
                ),
              ],
            );

            if (trailing == null) return copy;

            return compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      copy,
                      const SizedBox(height: 22),
                      trailing!,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: copy),
                      const SizedBox(width: 34),
                      Flexible(child: trailing!),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
