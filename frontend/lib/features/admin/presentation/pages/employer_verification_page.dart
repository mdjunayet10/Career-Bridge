import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/employer_verification_status.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../../shared/widgets/company_logo.dart';
import '../../controllers/admin_workspace_controller.dart';
import '../../data/models/admin_company_review_model.dart';
import '../widgets/admin_navigation.dart';
import '../widgets/admin_page_components.dart';
import '../widgets/admin_status_badge.dart';
import '../widgets/admin_workspace_gate.dart';

class EmployerVerificationPage extends StatefulWidget {
  const EmployerVerificationPage({super.key});

  @override
  State<EmployerVerificationPage> createState() =>
      _EmployerVerificationPageState();
}

class _EmployerVerificationPageState extends State<EmployerVerificationPage> {
  final searchController = TextEditingController();
  EmployerVerificationStatus? statusFilter = EmployerVerificationStatus.pending;

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
              company.email.toLowerCase().contains(query) ||
              company.tradeLicenseNumber.toLowerCase().contains(query);
          final matchesStatus =
              statusFilter == null || company.status == statusFilter;
          return matchesQuery && matchesStatus;
        }).toList();

        return DashboardShell(
          role: UserRole.admin,
          title: 'Employer verification',
          subtitle:
              'Review company identity, business details, and trade-license evidence before unlocking recruitment tools.',
          items: AdminNavigation.items,
          selectedIndex: 1,
          accent: AppColors.red,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${controller.companies.length} companies · ${controller.approvedCompanyCount} approved · ${controller.pendingEmployerCount} awaiting verification',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              _Toolbar(
                searchController: searchController,
                statusFilter: statusFilter,
                onSearch: (_) => setState(() {}),
                onStatus: (value) => setState(() => statusFilter = value),
              ),
              const SizedBox(height: 18),
              if (companies.isEmpty)
                const AdminEmptyState(
                  title: 'No companies match this view',
                  message: 'Try another search or verification status.',
                  icon: Icons.apartment_outlined,
                )
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
                            child: _CompanyReviewCard(
                              company: company,
                              saving: controller.isSaving,
                              onDetails: () =>
                                  _showDetails(context, controller, company),
                              onApprove: () => _review(
                                context,
                                controller,
                                company,
                                EmployerVerificationStatus.approved,
                              ),
                              onReject: () => _review(
                                context,
                                controller,
                                company,
                                EmployerVerificationStatus.rejected,
                              ),
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

  Future<void> _review(
    BuildContext context,
    AdminWorkspaceController controller,
    AdminCompanyReviewModel company,
    EmployerVerificationStatus status,
  ) async {
    final approving = status == EmployerVerificationStatus.approved;
    final note = await showAdminNoteDialog(
      context,
      title: approving ? 'Approve employer?' : 'Reject employer verification?',
      message: approving
          ? '${company.companyName} will be able to submit jobs for moderation.'
          : '${company.companyName} will receive the decision note and remain unable to publish jobs.',
      confirmLabel: approving ? 'Approve employer' : 'Reject verification',
      noteRequired: !approving,
      initialValue: approving
          ? 'Company identity and submitted business information verified.'
          : '',
      confirmColor: approving ? AppColors.green : AppColors.red,
    );
    if (note == null) return;
    try {
      await controller.reviewEmployer(
          company: company, status: status, note: note);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  approving ? 'Employer approved.' : 'Verification rejected.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _showDetails(
    BuildContext context,
    AdminWorkspaceController controller,
    AdminCompanyReviewModel company,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            CompanyLogo(
              companyId: company.companyId,
              companyName: company.companyName,
              logoFileId: company.logoFileId,
              size: 42,
              borderRadius: 12,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(company.companyName)),
          ],
        ),
        content: SizedBox(
          width: 620,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AdminStatusBadge.verification(company.status),
                      Text(
                          company.isActive
                              ? 'Account active'
                              : 'Account suspended',
                          style: TextStyle(
                              color: company.isActive
                                  ? AppColors.green
                                  : AppColors.red,
                              fontWeight: FontWeight.w800,
                              fontSize: 11))
                    ]),
                const SizedBox(height: 18),
                _Detail(label: 'Industry', value: company.industry),
                _Detail(label: 'Company size', value: company.companySize),
                _Detail(label: 'Business email', value: company.email),
                _Detail(label: 'Website', value: company.website),
                _Detail(label: 'Address', value: company.address),
                _Detail(
                    label: 'Trade licence', value: company.tradeLicenseNumber),
                _Detail(
                    label: 'Submitted',
                    value: compactDateTime(company.submittedAt)),
                if (company.decisionNote?.trim().isNotEmpty == true)
                  _Detail(
                      label: 'Previous decision note',
                      value: company.decisionNote!),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close')),
          if (company.status == EmployerVerificationStatus.pending) ...[
            OutlinedButton(
              onPressed: controller.isSaving
                  ? null
                  : () {
                      Navigator.pop(dialogContext);
                      _review(context, controller, company,
                          EmployerVerificationStatus.rejected);
                    },
              child: const Text('Reject'),
            ),
            FilledButton(
              onPressed: controller.isSaving
                  ? null
                  : () {
                      Navigator.pop(dialogContext);
                      _review(context, controller, company,
                          EmployerVerificationStatus.approved);
                    },
              child: const Text('Approve'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.searchController,
    required this.statusFilter,
    required this.onSearch,
    required this.onStatus,
  });

  final TextEditingController searchController;
  final EmployerVerificationStatus? statusFilter;
  final ValueChanged<String> onSearch;
  final ValueChanged<EmployerVerificationStatus?> onStatus;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final search = TextField(
          controller: searchController,
          onChanged: onSearch,
          decoration: const InputDecoration(
            hintText: 'Search company, industry, email, or trade licence',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        );
        final filter = DropdownButtonFormField<EmployerVerificationStatus?>(
          isExpanded: true,
          initialValue: statusFilter,
          decoration: const InputDecoration(labelText: 'Status'),
          items: [
            const DropdownMenuItem<EmployerVerificationStatus?>(
                value: null, child: Text('All statuses')),
            ...EmployerVerificationStatus.values
                .where((status) =>
                    status != EmployerVerificationStatus.notRequired)
                .map((status) => DropdownMenuItem<EmployerVerificationStatus?>(
                    value: status,
                    child: Text(AdminStatusBadge.verification(status).label))),
          ],
          onChanged: onStatus,
        );
        if (constraints.maxWidth >= 760) {
          return Row(children: [
            Expanded(child: search),
            const SizedBox(width: 12),
            SizedBox(width: 220, child: filter)
          ]);
        }
        return Column(children: [search, const SizedBox(height: 12), filter]);
      },
    );
  }
}

class _CompanyReviewCard extends StatelessWidget {
  const _CompanyReviewCard({
    required this.company,
    required this.saving,
    required this.onDetails,
    required this.onApprove,
    required this.onReject,
  });

  final AdminCompanyReviewModel company;
  final bool saving;
  final VoidCallback onDetails;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
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
                size: 50,
                borderRadius: 15,
              ),
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
                            color: AppColors.textMuted, fontSize: 10)),
                  ],
                ),
              ),
              AdminStatusBadge.verification(company.status),
            ],
          ),
          const SizedBox(height: 16),
          _Line(icon: Icons.email_outlined, text: company.email),
          _Line(icon: Icons.location_on_outlined, text: company.address),
          _Line(icon: Icons.badge_outlined, text: company.tradeLicenseNumber),
          _Line(
              icon: Icons.schedule_outlined,
              text: 'Submitted ${compactDateTime(company.submittedAt)}'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton(
                  onPressed: onDetails, child: const Text('Review details')),
              if (company.status == EmployerVerificationStatus.pending) ...[
                IconButton(
                    onPressed: saving ? null : onReject,
                    tooltip: 'Reject',
                    icon:
                        const Icon(Icons.close_rounded, color: AppColors.red)),
                FilledButton.icon(
                  onPressed: saving ? null : onApprove,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Approve'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.textSubtle),
        const SizedBox(width: 9),
        Expanded(
            child: Text(text,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 10)))
      ]),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSubtle,
                fontSize: 10,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(value.isEmpty ? 'Not provided' : value,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4))
      ]),
    );
  }
}
