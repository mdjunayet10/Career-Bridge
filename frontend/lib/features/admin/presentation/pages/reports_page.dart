import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../controllers/admin_workspace_controller.dart';
import '../../data/models/platform_report_model.dart';
import '../widgets/admin_navigation.dart';
import '../widgets/admin_page_components.dart';
import '../widgets/admin_status_badge.dart';
import '../widgets/admin_workspace_gate.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final searchController = TextEditingController();
  PlatformReportStatus? statusFilter;

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
        final reports = controller.reports.where((report) {
          final matchesQuery = query.isEmpty ||
              report.targetLabel.toLowerCase().contains(query) ||
              report.reason.toLowerCase().contains(query) ||
              report.reporterName.toLowerCase().contains(query) ||
              report.targetType.toLowerCase().contains(query);
          final matchesStatus =
              statusFilter == null || report.status == statusFilter;
          return matchesQuery && matchesStatus;
        }).toList();

        return DashboardShell(
          role: UserRole.admin,
          title: 'Reports and safety',
          subtitle:
              'Investigate user-submitted concerns and preserve an auditable resolution trail.',
          items: AdminNavigation.items,
          selectedIndex: 5,
          accent: AppColors.red,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final search = TextField(
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                        hintText: 'Search reports, targets, or reporters',
                        prefixIcon: Icon(Icons.search_rounded)),
                  );
                  final filter = DropdownButtonFormField<PlatformReportStatus?>(
                    isExpanded: true,
                    initialValue: statusFilter,
                    decoration:
                        const InputDecoration(labelText: 'Report status'),
                    items: [
                      const DropdownMenuItem<PlatformReportStatus?>(
                          value: null, child: Text('All reports')),
                      ...PlatformReportStatus.values.map((status) =>
                          DropdownMenuItem<PlatformReportStatus?>(
                              value: status, child: Text(status.label))),
                    ],
                    onChanged: (value) => setState(() => statusFilter = value),
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
              if (reports.isEmpty)
                const AdminEmptyState(
                    title: 'No reports match this view',
                    message: 'Try another keyword or safety-review status.',
                    icon: Icons.flag_outlined)
              else
                Column(
                  children: [
                    for (final report in reports) ...[
                      _ReportCard(
                          report: report,
                          saving: controller.isSaving,
                          onUpdate: (status) =>
                              _update(context, controller, report, status)),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _update(
    BuildContext context,
    AdminWorkspaceController controller,
    PlatformReportModel report,
    PlatformReportStatus status,
  ) async {
    final note = await showAdminNoteDialog(
      context,
      title: '${status.label} report?',
      message:
          'Update “${report.targetLabel}” and keep a concise record of the decision.',
      confirmLabel: status.label,
      noteRequired: status.isClosed,
      initialValue: status == PlatformReportStatus.inReview
          ? 'Report assigned for Admin review.'
          : '',
      confirmColor: status == PlatformReportStatus.dismissed
          ? AppColors.textMuted
          : status == PlatformReportStatus.resolved
              ? AppColors.green
              : AppColors.yellow,
    );
    if (note == null) return;
    try {
      await controller.updateReport(report: report, status: status, note: note);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Report marked ${status.label.toLowerCase()}.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard(
      {required this.report, required this.saving, required this.onUpdate});

  final PlatformReportModel report;
  final bool saving;
  final ValueChanged<PlatformReportStatus> onUpdate;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.flag_outlined, color: AppColors.red)),
              const SizedBox(height: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(report.targetLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 15)),
                const SizedBox(height: 4),
                Text('${report.targetType.toUpperCase()} · ${report.reason}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 10))
              ]),
              const SizedBox(height: 8),
              AdminStatusBadge.report(report.status),
            ],
          ),
          const SizedBox(height: 15),
          Text(
              report.details.isEmpty
                  ? 'No description provided.'
                  : report.details,
              style: const TextStyle(
                  color: AppColors.textSecondary, height: 1.55, fontSize: 11)),
          const SizedBox(height: 13),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _Meta(
                  icon: Icons.person_outline_rounded,
                  text: report.reporterName),
              _Meta(
                  icon: Icons.schedule_outlined,
                  text: compactDateTime(report.createdAt)),
              _Meta(icon: Icons.tag_rounded, text: report.targetId),
            ],
          ),
          if (report.resolutionNote?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 13),
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.green.withValues(alpha: .2))),
                child: Text('Resolution: ${report.resolutionNote}',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        height: 1.45))),
          ],
          if (!report.status.isClosed) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (report.status == PlatformReportStatus.open)
                  OutlinedButton.icon(
                      onPressed: saving
                          ? null
                          : () => onUpdate(PlatformReportStatus.inReview),
                      icon: const Icon(Icons.visibility_outlined, size: 17),
                      label: const Text('Start review')),
                FilledButton.icon(
                    onPressed: saving
                        ? null
                        : () => onUpdate(PlatformReportStatus.resolved),
                    icon: const Icon(Icons.check_circle_outline_rounded,
                        size: 17),
                    label: const Text('Resolve')),
                TextButton(
                    onPressed: saving
                        ? null
                        : () => onUpdate(PlatformReportStatus.dismissed),
                    child: const Text('Dismiss')),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 15, color: AppColors.textSubtle),
      const SizedBox(width: 6),
      Flexible(
          child: Text(text,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 9)))
    ]);
  }
}
