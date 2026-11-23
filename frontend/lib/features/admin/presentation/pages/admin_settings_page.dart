import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../controllers/admin_workspace_controller.dart';
import '../../data/models/platform_settings_model.dart';
import '../widgets/admin_navigation.dart';
import '../widgets/admin_page_components.dart';
import '../widgets/admin_workspace_gate.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final formKey = GlobalKey<FormState>();
  final platformNameController = TextEditingController();
  final supportEmailController = TextEditingController();
  bool initialized = false;
  bool employerReviewRequired = true;
  bool jobReviewRequired = true;
  bool maintenanceMode = false;
  bool allowJobSeekerRegistration = true;
  bool allowEmployerRegistration = true;

  @override
  void dispose() {
    platformNameController.dispose();
    supportEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminWorkspaceGate(
      builder: (context, controller) {
        final settings = controller.settings!;
        if (!initialized) {
          initialized = true;
          platformNameController.text = settings.platformName;
          supportEmailController.text = settings.supportEmail;
          employerReviewRequired = settings.employerReviewRequired;
          jobReviewRequired = settings.jobReviewRequired;
          maintenanceMode = settings.maintenanceMode;
          allowJobSeekerRegistration = settings.allowJobSeekerRegistration;
          allowEmployerRegistration = settings.allowEmployerRegistration;
        }

        return DashboardShell(
          role: UserRole.admin,
          title: 'Platform settings',
          subtitle:
              'Manage moderation defaults and public registration controls. Security Rules remain the final authorization layer.',
          items: AdminNavigation.items,
          selectedIndex: 7,
          accent: AppColors.red,
          body: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final desktop = constraints.maxWidth >= 900;
                    final identity = _IdentitySettings(
                      platformNameController: platformNameController,
                      supportEmailController: supportEmailController,
                    );
                    final moderation = _ModerationSettings(
                      employerReviewRequired: employerReviewRequired,
                      jobReviewRequired: jobReviewRequired,
                      onEmployerReview: (value) =>
                          setState(() => employerReviewRequired = value),
                      onJobReview: (value) =>
                          setState(() => jobReviewRequired = value),
                    );
                    if (desktop) {
                      return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: identity),
                            const SizedBox(width: 16),
                            Expanded(child: moderation)
                          ]);
                    }
                    return Column(children: [
                      identity,
                      const SizedBox(height: 16),
                      moderation
                    ]);
                  },
                ),
                const SizedBox(height: 16),
                _AccessSettings(
                  maintenanceMode: maintenanceMode,
                  allowJobSeekerRegistration: allowJobSeekerRegistration,
                  allowEmployerRegistration: allowEmployerRegistration,
                  onMaintenance: (value) =>
                      setState(() => maintenanceMode = value),
                  onJobSeeker: (value) =>
                      setState(() => allowJobSeekerRegistration = value),
                  onEmployer: (value) =>
                      setState(() => allowEmployerRegistration = value),
                ),
                const SizedBox(height: 16),
                AdminSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.security_rounded, color: AppColors.red),
                      const SizedBox(height: 12),
                      const Text(
                        'Admin routes are hidden from public navigation, but route secrecy is not security. Firebase Authentication, users/{uid}.role == "admin", account activity checks, and Firestore Security Rules protect every Admin read and write.',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.55,
                            fontSize: 11),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: controller.isSaving
                            ? null
                            : () => _save(context, controller, settings),
                        icon: controller.isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save_outlined),
                        label: const Text('Save settings'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save(
    BuildContext context,
    AdminWorkspaceController controller,
    PlatformSettingsModel current,
  ) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (maintenanceMode) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Enable maintenance mode?'),
          content: const Text(
              'This setting is intended for planned maintenance messaging. It does not replace Security Rules or Firebase service availability.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Continue')),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    final updated = current.copyWith(
      platformName: platformNameController.text.trim(),
      supportEmail: supportEmailController.text.trim(),
      employerReviewRequired: employerReviewRequired,
      jobReviewRequired: jobReviewRequired,
      maintenanceMode: maintenanceMode,
      allowJobSeekerRegistration: allowJobSeekerRegistration,
      allowEmployerRegistration: allowEmployerRegistration,
    );
    try {
      await controller.saveSettings(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Platform settings saved.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _IdentitySettings extends StatelessWidget {
  const _IdentitySettings(
      {required this.platformNameController,
      required this.supportEmailController});

  final TextEditingController platformNameController;
  final TextEditingController supportEmailController;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform identity',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          TextFormField(
              controller: platformNameController,
              decoration: const InputDecoration(labelText: 'Platform name'),
              validator: (value) => value == null || value.trim().length < 3
                  ? 'Enter a platform name.'
                  : null),
          const SizedBox(height: 12),
          TextFormField(
              controller: supportEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Support email'),
              validator: (value) => value == null || !value.contains('@')
                  ? 'Enter a valid email.'
                  : null),
        ],
      ),
    );
  }
}

class _ModerationSettings extends StatelessWidget {
  const _ModerationSettings(
      {required this.employerReviewRequired,
      required this.jobReviewRequired,
      required this.onEmployerReview,
      required this.onJobReview});

  final bool employerReviewRequired;
  final bool jobReviewRequired;
  final ValueChanged<bool> onEmployerReview;
  final ValueChanged<bool> onJobReview;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Moderation defaults',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: employerReviewRequired,
              onChanged: onEmployerReview,
              title: const Text('Require Employer verification'),
              subtitle: const Text(
                  'New Employers remain pending until an Admin decision.')),
          SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: jobReviewRequired,
              onChanged: onJobReview,
              title: const Text('Require job approval'),
              subtitle: const Text(
                  'Submitted jobs stay hidden until content review.')),
        ],
      ),
    );
  }
}

class _AccessSettings extends StatelessWidget {
  const _AccessSettings(
      {required this.maintenanceMode,
      required this.allowJobSeekerRegistration,
      required this.allowEmployerRegistration,
      required this.onMaintenance,
      required this.onJobSeeker,
      required this.onEmployer});

  final bool maintenanceMode;
  final bool allowJobSeekerRegistration;
  final bool allowEmployerRegistration;
  final ValueChanged<bool> onMaintenance;
  final ValueChanged<bool> onJobSeeker;
  final ValueChanged<bool> onEmployer;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Public access controls',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: allowJobSeekerRegistration,
              onChanged: onJobSeeker,
              title: const Text('Allow Job Seeker registration')),
          SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: allowEmployerRegistration,
              onChanged: onEmployer,
              title: const Text('Allow Employer registration')),
          SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: maintenanceMode,
              onChanged: onMaintenance,
              activeThumbColor: AppColors.red,
              title: const Text('Maintenance mode'),
              subtitle: const Text(
                  'Show planned-maintenance messaging in the application shell.')),
        ],
      ),
    );
  }
}
