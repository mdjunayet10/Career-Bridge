import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../../shared/widgets/workspace_state.dart';
import '../../controllers/admin_workspace_controller.dart';

class AdminWorkspaceGate extends StatefulWidget {
  const AdminWorkspaceGate({required this.builder, super.key});

  final Widget Function(
    BuildContext context,
    AdminWorkspaceController controller,
  ) builder;

  @override
  State<AdminWorkspaceGate> createState() => _AdminWorkspaceGateState();
}

class _AdminWorkspaceGateState extends State<AdminWorkspaceGate> {
  final controller = AdminWorkspaceController.instance;

  @override
  void initState() {
    super.initState();
    controller.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Scaffold(
            body: WorkspaceLoadingState(
              accent: AppColors.red,
              label: 'Loading the protected admin workspace…',
            ),
          );
        }
        if (!controller.isLoaded) {
          return Scaffold(
            body: WorkspaceErrorState(
              title: 'Could not load the Admin workspace',
              message: controller.errorMessage ?? 'Please try again.',
              accent: AppColors.red,
              icon: Icons.admin_panel_settings_outlined,
              onRetry: controller.refresh,
            ),
          );
        }
        if (!AuthController.instance.usesFirebase) {
          return widget.builder(context, controller);
        }
        return Column(
          children: [
            Material(
              color: controller.isDemoPreview ? AppColors.card : AppColors.page,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        controller.isDemoPreview
                            ? Icons.science_outlined
                            : Icons.cloud_done_outlined,
                        color: AppColors.cyan,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.isDemoPreview
                              ? 'READ-ONLY DEMO · 20 seekers · 12 companies · 20 public jobs'
                              : 'LIVE FIREBASE · Actual registered records only',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Demo', style: TextStyle(fontSize: 11)),
                      Switch.adaptive(
                        value: controller.isDemoPreview,
                        onChanged: controller.isLoading
                            ? null
                            : (value) => controller.setDemoPreview(value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: widget.builder(context, controller)),
          ],
        );
      },
    );
  }
}
