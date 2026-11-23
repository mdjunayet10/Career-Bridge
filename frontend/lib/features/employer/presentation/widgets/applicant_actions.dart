import 'package:flutter/material.dart';

import '../../../../core/enums/application_status.dart';
import '../../../applications/data/models/application_model.dart';
import '../../controllers/employer_workspace_controller.dart';

class ApplicantActions extends StatefulWidget {
  const ApplicantActions(
      {required this.application, required this.controller, super.key});
  final ApplicationModel application;
  final EmployerWorkspaceController controller;
  @override
  State<ApplicantActions> createState() => _ApplicantActionsState();
}

class _ApplicantActionsState extends State<ApplicantActions> {
  bool busy = false;
  bool saving = false;

  Future<void> update(ApplicationStatus status) async {
    if (busy || widget.controller.isSaving) return;
    final application =
        widget.controller.applicationById(widget.application.id) ??
            widget.application;
    if (application.status.isTerminal) return;
    setState(() => busy = true);
    try {
      DateTime? interviewAt;
      var note = application.employerNote;
      if (status == ApplicationStatus.interview) {
        final decision = await showDialog<_InterviewDecision>(
            context: context,
            builder: (_) => _InterviewDialog(application: application));
        if (decision == null) return;
        interviewAt = decision.at;
        note = decision.note;
      } else if (status == ApplicationStatus.hired ||
          status == ApplicationStatus.rejected) {
        final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
                  title: Text(status == ApplicationStatus.hired
                      ? 'Select candidate?'
                      : 'Mark as not selected?'),
                  content: Text(
                      '${application.applicantName} will be notified about this decision for ${application.jobTitle}.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(status == ApplicationStatus.hired
                            ? 'Select candidate'
                            : 'Not selected')),
                  ],
                ));
        if (confirmed != true) return;
      }
      if (mounted) setState(() => saving = true);
      await widget.controller.updateApplication(
          application: application,
          status: status,
          employerNote: note,
          interviewAt: interviewAt);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(status == ApplicationStatus.hired
                ? 'Candidate selected and notified.'
                : '${status.label}. Candidate notified.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error.toString().replaceFirst('Bad state: ', ''))));
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.application.status;
    if (status.isTerminal) {
      return Text(
          status == ApplicationStatus.withdrawn
              ? 'Withdrawn by candidate'
              : 'Decision recorded',
          style: const TextStyle(fontSize: 11));
    }
    final disabled = busy || widget.controller.isSaving;
    return Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          FilledButton.icon(
              onPressed: disabled || status == ApplicationStatus.shortlisted
                  ? null
                  : () => update(ApplicationStatus.shortlisted),
              icon: const Icon(Icons.star_outline_rounded, size: 18),
              label: const Text('Shortlist')),
          OutlinedButton.icon(
              onPressed:
                  disabled ? null : () => update(ApplicationStatus.interview),
              icon: const Icon(Icons.event_outlined, size: 18),
              label: const Text('Interview')),
          FilledButton.tonalIcon(
              onPressed:
                  disabled ? null : () => update(ApplicationStatus.hired),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Select')),
          PopupMenuButton<ApplicationStatus>(
            enabled: !disabled,
            tooltip: 'More actions',
            onSelected: update,
            itemBuilder: (_) => [
              if (status != ApplicationStatus.reviewed)
                const PopupMenuItem(
                    value: ApplicationStatus.reviewed,
                    child: Text('Mark under review')),
              const PopupMenuItem(
                  value: ApplicationStatus.rejected,
                  child: Text('Not selected')),
            ],
            child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('More'),
                  SizedBox(width: 4),
                  Icon(Icons.expand_more_rounded, size: 18)
                ])),
          ),
          if (saving)
            const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2)),
        ]);
  }
}

class _InterviewDecision {
  const _InterviewDecision(this.at, this.note);
  final DateTime at;
  final String? note;
}

class _InterviewDialog extends StatefulWidget {
  const _InterviewDialog({required this.application});
  final ApplicationModel application;
  @override
  State<_InterviewDialog> createState() => _InterviewDialogState();
}

class _InterviewDialogState extends State<_InterviewDialog> {
  late DateTime schedule;
  late TextEditingController note;
  String? error;
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    schedule = widget.application.interviewAt?.isAfter(now) == true
        ? widget.application.interviewAt!
        : DateTime(now.year, now.month, now.day + 1, 10);
    note = TextEditingController(text: widget.application.employerNote ?? '');
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        scrollable: true,
        title: const Text('Schedule interview'),
        content: SizedBox(
            width: 440,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(widget.application.applicantName),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                          '${schedule.day}/${schedule.month}/${schedule.year}'),
                      onPressed: () async {
                        final date = await showDatePicker(
                            context: context,
                            initialDate: schedule,
                            firstDate: DateUtils.dateOnly(DateTime.now()),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)));
                        if (date != null && mounted) {
                          setState(() => schedule = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              schedule.hour,
                              schedule.minute));
                        }
                      }),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                      icon: const Icon(Icons.schedule),
                      label: Text(
                          TimeOfDay.fromDateTime(schedule).format(context)),
                      onPressed: () async {
                        final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(schedule));
                        if (time != null && mounted) {
                          setState(() => schedule = DateTime(
                              schedule.year,
                              schedule.month,
                              schedule.day,
                              time.hour,
                              time.minute));
                        }
                      }),
                  const SizedBox(height: 14),
                  TextField(
                      controller: note,
                      minLines: 2,
                      maxLines: 4,
                      maxLength: 1000,
                      decoration: const InputDecoration(
                          labelText: 'Message to candidate (optional)',
                          hintText:
                              'Location, meeting link or preparation details')),
                  if (error != null)
                    Text(error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () {
                if (!schedule.isAfter(DateTime.now())) {
                  setState(() => error = 'Choose a future interview time.');
                  return;
                }
                Navigator.pop(
                    context,
                    _InterviewDecision(schedule,
                        note.text.trim().isEmpty ? null : note.text.trim()));
              },
              child: const Text('Schedule & notify')),
        ],
      );
}
