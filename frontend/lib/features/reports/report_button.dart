import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/router/app_routes.dart';
import '../auth/controllers/auth_controller.dart';
import 'report_service.dart';

class ReportButton extends StatelessWidget {
  const ReportButton(
      {required this.targetType,
      required this.targetId,
      required this.targetLabel,
      required this.isSample,
      super.key});
  final String targetType;
  final String targetId;
  final String targetLabel;
  final bool isSample;

  @override
  Widget build(BuildContext context) => TextButton.icon(
        icon: const Icon(Icons.flag_outlined, size: 18),
        label: Text(targetType == 'job' ? 'Report Job' : 'Report Company'),
        onPressed: () async {
          final auth = AuthController.instance;
          if (auth.currentUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Sign in to submit a report.'),
              action: SnackBarAction(
                  label: 'Sign in',
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.login)),
            ));
            return;
          }
          if (isSample || !auth.usesFirebase) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Demo sample only. Reports for sample content are not sent to Firebase.')));
            return;
          }
          final result = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (_) => ReportDialog(
                  targetType: targetType,
                  targetLabel: targetLabel,
                  submit: (reason, details) => ReportService.submit(
                      targetType: targetType,
                      targetId: targetId,
                      targetLabel: targetLabel,
                      reason: reason,
                      details: details)));
          if (context.mounted && result != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(result
                    ? 'Report submitted. Our Admin team will review it.'
                    : 'You already reported this content. Our Admin team has your report.')));
          }
        },
      );
}

class ReportDialog extends StatefulWidget {
  const ReportDialog(
      {required this.targetType,
      required this.targetLabel,
      required this.submit,
      super.key});
  final String targetType;
  final String targetLabel;
  final Future<bool> Function(String reason, String details) submit;
  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final description = TextEditingController();
  String? reason;
  String? error;
  bool submitting = false;
  @override
  void dispose() {
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !submitting,
        child: AlertDialog(
          scrollable: true,
          title: Text(
              widget.targetType == 'job' ? 'Report Job' : 'Report Company'),
          content: SizedBox(
              width: 460,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(widget.targetLabel),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: reason,
                      decoration:
                          const InputDecoration(labelText: 'Report reason'),
                      items: reportReasons
                          .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: submitting
                          ? null
                          : (value) => setState(() => reason = value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                        controller: description,
                        enabled: !submitting,
                        minLines: 3,
                        maxLines: 6,
                        maxLength: 2000,
                        decoration: const InputDecoration(
                            labelText: 'Description (optional)')),
                    if (error != null)
                      Text(error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                  ])),
          actions: [
            TextButton(
                onPressed: submitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: submitting
                    ? null
                    : () async {
                        if (reason == null) {
                          setState(() => error = 'Select a report reason.');
                          return;
                        }
                        setState(() {
                          submitting = true;
                          error = null;
                        });
                        try {
                          final created =
                              await widget.submit(reason!, description.text);
                          if (context.mounted) {
                            setState(() => submitting = false);
                            Navigator.pop(context, created);
                          }
                        } catch (failure) {
                          if (!mounted) return;
                          setState(() {
                            submitting = false;
                            error = failure is FirebaseException &&
                                    failure.code == 'permission-denied'
                                ? 'Reporting is unavailable for this content or account. Check that you are signed in to an active account.'
                                : 'Could not submit report. Check your connection and try again.';
                          });
                        }
                      },
                child: Text(submitting ? 'Submitting…' : 'Submit report')),
          ],
        ),
      );
}
