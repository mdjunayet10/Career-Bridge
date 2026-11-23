import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/company_logo.dart';
import '../../../../shared/widgets/hover_card.dart';
import '../../data/models/company_model.dart';

class CompanyCard extends StatelessWidget {
  const CompanyCard({required this.company, super.key});

  final CompanyModel company;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      padding: const EdgeInsets.all(22),
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.companyDetails(company.id),
      ),
      child: SizedBox(
        height: 344,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CompanyLogo(
                  companyId: company.id,
                  companyName: company.name,
                  logoFileId: company.logoFileId,
                  size: 66,
                  borderRadius: 18,
                ),
                const Spacer(),
                if (company.isVerified)
                  const Tooltip(
                    message: 'Verified employer',
                    child: Icon(
                      Icons.verified_rounded,
                      size: 21,
                      color: AppColors.green,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 19),
            Text(
              company.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.25,
                  ),
            ),
            const SizedBox(height: 7),
            Text(
              company.industry,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CompanyFact(
                  icon: Icons.location_on_outlined,
                  label: company.location,
                ),
                _CompanyFact(
                  icon: Icons.groups_2_outlined,
                  label: company.size,
                ),
              ],
            ),
            const Spacer(),
            const SizedBox(height: 18),
            Container(
              height: 1,
              color: AppColors.borderMuted,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cyan,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '${company.openings} open position${company.openings == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Text(
                  'View company',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 7),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.blue,
                  size: 17,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyFact extends StatelessWidget {
  const _CompanyFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.input,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSubtle),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
