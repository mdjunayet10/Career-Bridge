import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    super.key,
    this.note,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMuted),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -28,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: .06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: accent.withValues(alpha: .18),
                      ),
                    ),
                    child: Icon(icon, color: accent, size: 21),
                  ),
                  const Spacer(),
                  if (note != null)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          note!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.8,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
