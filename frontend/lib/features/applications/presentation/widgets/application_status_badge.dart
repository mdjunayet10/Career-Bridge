import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/application_status.dart';

class ApplicationStatusBadge extends StatelessWidget {
  const ApplicationStatusBadge({required this.status, super.key});

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ApplicationStatus.applied => AppColors.blue,
      ApplicationStatus.reviewed => AppColors.cyan,
      ApplicationStatus.shortlisted => AppColors.purple,
      ApplicationStatus.interview => AppColors.yellow,
      ApplicationStatus.hired => AppColors.green,
      ApplicationStatus.rejected => AppColors.red,
      ApplicationStatus.withdrawn => AppColors.textSubtle,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Text(
        status.label,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}
