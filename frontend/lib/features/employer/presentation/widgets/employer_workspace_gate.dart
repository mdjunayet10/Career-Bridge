import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/workspace_state.dart';
import '../../controllers/employer_workspace_controller.dart';

class EmployerWorkspaceGate extends StatefulWidget {
  const EmployerWorkspaceGate({required this.builder, super.key});

  final Widget Function(
    BuildContext context,
    EmployerWorkspaceController controller,
  ) builder;

  @override
  State<EmployerWorkspaceGate> createState() => _EmployerWorkspaceGateState();
}

class _EmployerWorkspaceGateState extends State<EmployerWorkspaceGate> {
  final controller = EmployerWorkspaceController.instance;

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
        if (controller.isLoading && !controller.isLoaded) {
          return const WorkspaceLoadingState(
            accent: AppColors.purple,
            label: 'Loading the employer workspace…',
          );
        }
        if (!controller.isLoaded) {
          return WorkspaceErrorState(
            title: 'Could not load the employer workspace',
            message: controller.errorMessage ?? 'Please try again.',
            accent: AppColors.purple,
            icon: Icons.apartment_outlined,
            onRetry: controller.refresh,
          );
        }
        return widget.builder(context, controller);
      },
    );
  }
}
