import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/employer_verification_status.dart';
import '../../data/models/platform_report_model.dart';

class AdminStatusBadge extends StatelessWidget {
  const AdminStatusBadge({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  factory AdminStatusBadge.verification(EmployerVerificationStatus status) {
    final color = switch (status) {
      EmployerVerificationStatus.notRequired => AppColors.textMuted,
      EmployerVerificationStatus.pending => AppColors.yellow,
      EmployerVerificationStatus.approved => AppColors.green,
      EmployerVerificationStatus.rejected => AppColors.red,
    };
    final label = switch (status) {
      EmployerVerificationStatus.notRequired => 'Not required',
      EmployerVerificationStatus.pending => 'Pending',
      EmployerVerificationStatus.approved => 'Approved',
      EmployerVerificationStatus.rejected => 'Rejected',
    };
    return AdminStatusBadge(label: label, color: color);
  }

  factory AdminStatusBadge.report(PlatformReportStatus status) {
    final color = switch (status) {
      PlatformReportStatus.open => AppColors.red,
      PlatformReportStatus.inReview => AppColors.yellow,
      PlatformReportStatus.resolved => AppColors.green,
      PlatformReportStatus.dismissed => AppColors.textMuted,
    };
    return AdminStatusBadge(label: status.label, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .26)),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}
