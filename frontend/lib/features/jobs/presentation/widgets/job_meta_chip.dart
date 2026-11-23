import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class JobMetaChip extends StatelessWidget {
  const JobMetaChip({
    required this.icon,
    required this.label,
    super.key,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.blueStrong.withValues(alpha: .12)
            : AppColors.background.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: highlight
              ? AppColors.blue.withValues(alpha: .34)
              : AppColors.borderMuted,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: highlight ? AppColors.blue : AppColors.textSubtle,
          ),
          const SizedBox(width: 6),
          Flexible(
              child: Text(
            label,
            style: TextStyle(
              color: highlight ? AppColors.textSecondary : AppColors.textMuted,
              fontSize: 11,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          )),
        ],
      ),
    );
  }
}
