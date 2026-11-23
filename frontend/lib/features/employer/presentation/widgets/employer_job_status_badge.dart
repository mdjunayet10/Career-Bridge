import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/employer_job_status.dart';

class EmployerJobStatusBadge extends StatelessWidget {
  const EmployerJobStatusBadge({required this.status, super.key});

  final EmployerJobStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      EmployerJobStatus.draft => AppColors.textMuted,
      EmployerJobStatus.pending => AppColors.yellow,
      EmployerJobStatus.published => AppColors.green,
      EmployerJobStatus.rejected => AppColors.red,
      EmployerJobStatus.closed => AppColors.textSubtle,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Text(
        status.label,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}
