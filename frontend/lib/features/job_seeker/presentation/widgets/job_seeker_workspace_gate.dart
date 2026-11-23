import 'package:flutter/material.dart';

import '../../../../shared/widgets/workspace_state.dart';
import '../../controllers/job_seeker_workspace_controller.dart';

class JobSeekerWorkspaceGate extends StatefulWidget {
  const JobSeekerWorkspaceGate({required this.builder, super.key});

  final Widget Function(
    BuildContext context,
    JobSeekerWorkspaceController controller,
  ) builder;

  @override
  State<JobSeekerWorkspaceGate> createState() => _JobSeekerWorkspaceGateState();
}

class _JobSeekerWorkspaceGateState extends State<JobSeekerWorkspaceGate> {
  final controller = JobSeekerWorkspaceController.instance;

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
            label: 'Loading your career workspace…',
          );
        }
        if (!controller.isLoaded) {
          return WorkspaceErrorState(
            title: 'Could not load your workspace',
            message: controller.errorMessage ?? 'Please try again.',
            onRetry: controller.refresh,
          );
        }
        return widget.builder(context, controller);
      },
    );
  }
}
