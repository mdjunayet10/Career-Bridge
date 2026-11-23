import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../../shared/widgets/company_logo.dart';
import '../../controllers/admin_workspace_controller.dart';
import '../../data/models/admin_company_review_model.dart';
import '../widgets/admin_navigation.dart';
import '../widgets/admin_page_components.dart';
import '../widgets/admin_status_badge.dart';
import '../widgets/admin_workspace_gate.dart';

class CompanyManagementPage extends StatefulWidget {
  const CompanyManagementPage({super.key});

  @override
  State<CompanyManagementPage> createState() => _CompanyManagementPageState();
}

class _CompanyManagementPageState extends State<CompanyManagementPage> {
  final searchController = TextEditingController();
  bool? activeFilter;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminWorkspaceGate(
      builder: (context, controller) {
        final query = searchController.text.trim().toLowerCase();
        final companies = controller.companies.where((company) {
          final matchesQuery = query.isEmpty ||
              company.companyName.toLowerCase().contains(query) ||
              company.industry.toLowerCase().contains(query) ||
              company.email.toLowerCase().contains(query);
          final matchesStatus =
              activeFilter == null || company.isActive == activeFilter;
          return matchesQuery && matchesStatus;
        }).toList();

        return DashboardShell(
          role: UserRole.admin,
          title: 'Company management',
          subtitle:
              'Manage approved and pending company records, public visibility, and platform access.',
          items: AdminNavigation.items,
          selectedIndex: 4,
          accent: AppColors.red,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${controller.companies.length} companies in ${controller.isDemoPreview ? 'demo preview' : 'live records'} · ${controller.approvedCompanyCount} approved · ${controller.pendingEmployerCount} pending',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final search = TextField(
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                        hintText: 'Search company, industry, or email',
                        prefixIcon: Icon(Icons.search_rounded)),
                  );
                  final filter = DropdownButtonFormField<bool?>(
                    isExpanded: true,
                    initialValue: activeFilter,
                    decoration:
                        const InputDecoration(labelText: 'Company status'),
                    items: const [
                      DropdownMenuItem<bool?>(
                          value: null, child: Text('All companies')),
                      DropdownMenuItem<bool?>(
                          value: true, child: Text('Active')),
                      DropdownMenuItem<bool?>(
                          value: false, child: Text('Suspended')),
                    ],
                    onChanged: (value) => setState(() => activeFilter = value),
                  );
                  if (constraints.maxWidth >= 760) {
                    return Row(children: [
                      Expanded(child: search),
                      const SizedBox(width: 12),
                      SizedBox(width: 220, child: filter)
                    ]);
                  }
                  return Column(
                      children: [search, const SizedBox(height: 12), filter]);
                },
              ),
              const SizedBox(height: 18),
              if (companies.isEmpty)
                const AdminEmptyState(
                    title: 'No companies match this view',
                    message:
                        'Try another company name, industry, or account status.',
                    icon: Icons.apartment_outlined)
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 980 ? 2 : 1;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 16) / columns;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final company in companies)
                          SizedBox(
                            width: width,
                            child: _CompanyCard(
                              company: company,
                              saving: controller.isSaving,
                              jobCount: controller.jobs
                                  .where((job) =>
                                      job.companyId == company.companyId)
                                  .length,
                              onToggle: () =>
                                  _toggle(context, controller, company),
                              onVerification: () =>
                                  Navigator.pushReplacementNamed(context,
                                      AppRoutes.adminEmployerVerification),
                            ),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggle(
    BuildContext context,
    AdminWorkspaceController controller,
    AdminCompanyReviewModel company,
  ) async {
    final activating = !company.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(activating ? 'Reactivate company?' : 'Suspend company?'),
        content: Text(
          activating
              ? '${company.companyName} and its Employer account will regain protected access.'
              : '${company.companyName} and its Employer account will be blocked from protected features.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
            style: activating
                ? null
                : FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(activating ? 'Reactivate' : 'Suspend'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await controller.setCompanyActive(company, activating);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                activating ? 'Company reactivated.' : 'Company suspended.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard(
      {required this.company,
      required this.saving,
      required this.jobCount,
      required this.onToggle,
      required this.onVerification});

  final AdminCompanyReviewModel company;
  final bool saving;
  final int jobCount;
  final VoidCallback onToggle;
  final VoidCallback onVerification;

  @override
  Widget build(BuildContext context) {
    final statusColor = company.isActive ? AppColors.green : AppColors.red;
    return AdminSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyLogo(
                  companyId: company.companyId,
                  companyName: company.companyName,
                  logoFileId: company.logoFileId,
                  size: 52,
                  borderRadius: 15),
              const SizedBox(width: 13),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(company.companyName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${company.industry} · ${company.companySize}',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 10))
                  ])),
              AdminStatusBadge.verification(company.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            Icon(Icons.circle, size: 9, color: statusColor),
            const SizedBox(width: 7),
            Text(company.isActive ? 'Company active' : 'Company suspended',
                style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 10)),
            const Spacer(),
            Text('$jobCount job${jobCount == 1 ? '' : 's'}',
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 10))
          ]),
          const SizedBox(height: 11),
          Text(company.email,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 5),
          Text(company.address,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          const SizedBox(height: 16),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton(
                    onPressed: onVerification,
                    child: const Text('Verification record')),
                FilledButton.tonalIcon(
                    onPressed: saving ? null : onToggle,
                    icon: Icon(
                        company.isActive
                            ? Icons.block_outlined
                            : Icons.restart_alt_rounded,
                        size: 18),
                    label: Text(company.isActive ? 'Suspend' : 'Reactivate'))
              ]),
        ],
      ),
    );
  }
}
