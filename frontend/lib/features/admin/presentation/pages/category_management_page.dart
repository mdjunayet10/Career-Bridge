import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../controllers/admin_workspace_controller.dart';
import '../../data/models/job_category_admin_model.dart';
import '../widgets/admin_navigation.dart';
import '../widgets/admin_page_components.dart';
import '../widgets/admin_workspace_gate.dart';

class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminWorkspaceGate(
      builder: (context, controller) => DashboardShell(
        role: UserRole.admin,
        title: 'Job categories',
        subtitle:
            'Control the career paths visible across search filters, landing-page discovery, and job forms.',
        items: AdminNavigation.items,
        selectedIndex: 6,
        accent: AppColors.red,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${controller.activeCategoryCount} active categories · ${controller.categories.length} total',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                FilledButton.icon(
                  onPressed: controller.isSaving
                      ? null
                      : () => _edit(context, controller),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add category'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (controller.categories.isEmpty)
              const AdminEmptyState(
                title: 'No categories yet',
                message:
                    'Create the first career path used by public job discovery.',
                icon: Icons.category_outlined,
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 980
                      ? 3
                      : constraints.maxWidth >= 650
                          ? 2
                          : 1;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 14) / columns;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      for (final category in controller.categories)
                        SizedBox(
                          width: width,
                          child: _CategoryCard(
                            category: category,
                            saving: controller.isSaving,
                            onEdit: () => _edit(context, controller, category),
                            onToggle: () => controller.saveCategory(
                              category.copyWith(
                                isActive: !category.isActive,
                                updatedAt: DateTime.now(),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    AdminWorkspaceController controller, [
    JobCategoryAdminModel? existing,
  ]) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');
    final iconController =
        TextEditingController(text: existing?.iconName ?? 'work_outline');
    final orderController = TextEditingController(
        text: '${existing?.sortOrder ?? controller.categories.length + 1}');
    final formKey = GlobalKey<FormState>();
    var active = existing?.isActive ?? true;

    final saved = await showDialog<JobCategoryAdminModel>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title:
              Text(existing == null ? 'Add job category' : 'Edit job category'),
          content: SizedBox(
            width: MediaQuery.sizeOf(context).width < 650
                ? MediaQuery.sizeOf(context).width * .75
                : 540,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Category name'),
                      validator: (value) =>
                          value == null || value.trim().length < 2
                              ? 'Enter a category name.'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      minLines: 2,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      validator: (value) =>
                          value == null || value.trim().length < 12
                              ? 'Add a clearer description.'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: iconController,
                            decoration:
                                const InputDecoration(labelText: 'Icon'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: orderController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Sort order'),
                            validator: (value) =>
                                int.tryParse(value ?? '') == null
                                    ? 'Enter a number.'
                                    : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: active,
                      onChanged: (value) => setState(() => active = value),
                      title: const Text('Visible in public discovery'),
                      subtitle: const Text(
                          'Inactive categories remain in Admin history but are hidden publicly.'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.pop(
                  dialogContext,
                  JobCategoryAdminModel(
                    id: existing?.id ?? '',
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    iconName: iconController.text.trim().isEmpty
                        ? 'work_outline'
                        : iconController.text.trim(),
                    isActive: active,
                    sortOrder: int.parse(orderController.text.trim()),
                    updatedAt: DateTime.now(),
                  ),
                );
              },
              child: const Text('Save category'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    descriptionController.dispose();
    iconController.dispose();
    orderController.dispose();
    if (saved == null) return;
    try {
      await controller.saveCategory(saved);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Category saved.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard(
      {required this.category,
      required this.saving,
      required this.onEdit,
      required this.onToggle});

  final JobCategoryAdminModel category;
  final bool saving;
  final VoidCallback onEdit;
  final Future<JobCategoryAdminModel> Function() onToggle;

  @override
  Widget build(BuildContext context) {
    final color = category.isActive ? AppColors.cyan : AppColors.textSubtle;
    return AdminSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(13)),
                child:
                    Icon(_iconFor(category.iconName), color: color, size: 21),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(999)),
                child: Text(category.isActive ? 'Active' : 'Hidden',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 9)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(category.name,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 7),
          Text(category.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.textMuted, height: 1.45, fontSize: 10)),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('Order ${category.sortOrder}',
                  style: const TextStyle(
                      color: AppColors.textSubtle, fontSize: 9)),
              const Spacer(),
              IconButton(
                  onPressed: saving ? null : () async => onToggle(),
                  tooltip:
                      category.isActive ? 'Hide category' : 'Activate category',
                  icon: Icon(
                      category.isActive
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 19)),
              IconButton(
                  onPressed: saving ? null : onEdit,
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined, size: 19)),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String value) => switch (value) {
        'memory' => Icons.memory_rounded,
        'palette' => Icons.palette_outlined,
        'business_center' => Icons.business_center_outlined,
        'campaign' => Icons.campaign_outlined,
        'school' => Icons.school_outlined,
        'support_agent' => Icons.support_agent_outlined,
        _ => Icons.work_outline_rounded,
      };
}
