import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../shared/widgets/company_logo.dart';
import '../../../../shared/widgets/hover_card.dart';
import '../../data/models/job_model.dart';
import 'job_meta_chip.dart';

class PublicJobCard extends StatelessWidget {
  const PublicJobCard({
    required this.job,
    super.key,
    this.isSaved = false,
    this.onSave,
    this.compact = false,
    this.matchScore,
  });

  final JobModel job;
  final bool isSaved;
  final ValueChanged<bool>? onSave;
  final bool compact;
  final int? matchScore;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.jobDetails(job.id)),
      padding: EdgeInsets.all(compact ? 18 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyLogo(
                companyId: job.companyId,
                companyName: job.companyName,
                size: compact ? 46 : 54,
                borderRadius: compact ? 13 : 16,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            job.companyName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (job.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded,
                              size: 16, color: AppColors.green),
                        ],
                        if (job.isSample) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.yellow.withValues(alpha: .10),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.yellow.withValues(alpha: .30),
                              ),
                            ),
                            child: const Text(
                              'SAMPLE',
                              style: TextStyle(
                                color: AppColors.yellow,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      job.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: compact ? 17 : 20,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onSave == null ? null : () => onSave!(!isSaved),
                tooltip: isSaved ? 'Remove saved job' : 'Save job',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved ? AppColors.blue : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (matchScore != null && matchScore! > 0)
                JobMetaChip(
                  icon: Icons.auto_awesome_rounded,
                  label: '$matchScore% CV match',
                  highlight: true,
                ),
              JobMetaChip(
                  icon: Icons.location_on_outlined, label: job.location),
              JobMetaChip(
                  icon: Icons.work_outline_rounded, label: job.employmentType),
              JobMetaChip(
                icon: job.workMode == 'Remote'
                    ? Icons.wifi_rounded
                    : Icons.apartment_rounded,
                label: job.workMode,
                highlight: job.workMode == 'Remote',
              ),
              JobMetaChip(icon: Icons.timeline_rounded, label: job.experience),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  job.salaryLabel,
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                job.postedLabel,
                style:
                    const TextStyle(color: AppColors.textSubtle, fontSize: 11),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.event_outlined,
                    size: 16, color: AppColors.textSubtle),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Apply by ${job.deadlineLabel}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
                  ),
                ),
                Text(
                  job.isSample ? 'Try demo job' : 'View details',
                  style: TextStyle(
                    color: job.isSample ? AppColors.textMuted : AppColors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (!job.isSample) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 17, color: AppColors.blue),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
