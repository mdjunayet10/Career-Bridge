import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class WorkspaceLoadingState extends StatelessWidget {
  const WorkspaceLoadingState({
    super.key,
    this.accent = AppColors.blue,
    this.label = 'Loading workspace…',
  });

  final Color accent;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
        label: label,
        liveRegion: true,
        child: Center(
          child: SizedBox(
              width: 24,
              height: 24,
              child:
                  CircularProgressIndicator(strokeWidth: 2.5, color: accent)),
        ));
  }
}

class WorkspaceErrorState extends StatelessWidget {
  const WorkspaceErrorState({
    required this.title,
    required this.message,
    required this.onRetry,
    super.key,
    this.icon = Icons.cloud_off_rounded,
    this.accent = AppColors.blue,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withValues(alpha: .2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .12),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 30, color: accent),
            ),
            const SizedBox(height: 17),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
