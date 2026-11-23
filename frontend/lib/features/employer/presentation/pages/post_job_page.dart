import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/employer_job_status.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../controllers/employer_workspace_controller.dart';
import '../../data/models/employer_job_model.dart';
import '../widgets/employer_navigation.dart';
import '../widgets/employer_workspace_gate.dart';

class PostJobPage extends StatelessWidget {
  const PostJobPage({super.key, this.jobId});

  final String? jobId;

  @override
  Widget build(BuildContext context) {
    return EmployerWorkspaceGate(
      builder: (context, controller) {
        final initialJob = jobId == null ? null : controller.jobById(jobId!);
        final missing = jobId != null && initialJob == null;
        final editing = initialJob != null;
        return DashboardShell(
          role: UserRole.employer,
          title:
              missing ? 'Job not found' : (editing ? 'Edit job' : 'Post a job'),
          subtitle: missing
              ? 'This job does not belong to the current employer workspace.'
              : editing
                  ? 'Update the role and submit changes for admin review.'
                  : 'Create a clear, complete opportunity for Career Bridge job seekers.',
          items: EmployerNavigation.items,
          selectedIndex: 1,
          accent: AppColors.purple,
          body: missing
              ? const _MissingJob()
              : _JobForm(controller: controller, initialJob: initialJob),
        );
      },
    );
  }
}

class _JobForm extends StatefulWidget {
  const _JobForm({required this.controller, this.initialJob});

  final EmployerWorkspaceController controller;
  final EmployerJobModel? initialJob;

  @override
  State<_JobForm> createState() => _JobFormState();
}

class _JobFormState extends State<_JobForm> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController locationController;
  late final TextEditingController experienceController;
  late final TextEditingController salaryMinController;
  late final TextEditingController salaryMaxController;
  late final TextEditingController descriptionController;
  late final TextEditingController responsibilitiesController;
  late final TextEditingController requirementsController;
  late final TextEditingController skillsController;
  late final TextEditingController benefitsController;

  late String category;
  late String workMode;
  late String employmentType;
  late DateTime deadline;

  bool get readOnly =>
      widget.initialJob?.status == EmployerJobStatus.pending ||
      widget.initialJob?.status == EmployerJobStatus.closed;

  @override
  void initState() {
    super.initState();
    final job = widget.initialJob;
    titleController = TextEditingController(text: job?.title ?? '');
    locationController = TextEditingController(text: job?.location ?? 'Dhaka');
    experienceController =
        TextEditingController(text: job?.experienceLevel ?? '1–3 years');
    salaryMinController =
        TextEditingController(text: job == null ? '' : '${job.salaryMin}');
    salaryMaxController =
        TextEditingController(text: job == null ? '' : '${job.salaryMax}');
    descriptionController = TextEditingController(text: job?.description ?? '');
    responsibilitiesController =
        TextEditingController(text: job?.responsibilities.join('\n') ?? '');
    requirementsController =
        TextEditingController(text: job?.requirements.join('\n') ?? '');
    skillsController =
        TextEditingController(text: job?.skills.join(', ') ?? '');
    benefitsController =
        TextEditingController(text: job?.benefits.join(', ') ?? '');
    category = job?.categoryId ?? 'Technology';
    workMode = job?.workMode ?? 'Hybrid';
    employmentType = job?.employmentType ?? 'Full-time';
    deadline = job?.deadline ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    for (final controller in [
      titleController,
      locationController,
      experienceController,
      salaryMinController,
      salaryMaxController,
      descriptionController,
      responsibilitiesController,
      requirementsController,
      skillsController,
      benefitsController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (readOnly) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.yellow.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.yellow.withValues(alpha: .25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_clock_outlined,
                      color: AppColors.yellow),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.initialJob!.status == EmployerJobStatus.pending
                          ? 'This job is currently under admin review. Editing is temporarily disabled.'
                          : 'This job is closed. Create a new job if you want to reopen recruitment.',
                      style: const TextStyle(
                          color: AppColors.textSecondary, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          _SectionCard(
            title: 'Basic information',
            subtitle:
                'Use a specific title and describe where and how the role works.',
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  readOnly: readOnly,
                  decoration: const InputDecoration(
                      labelText: 'Job title *',
                      hintText: 'e.g. Flutter Developer'),
                  validator: _required,
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 700;
                    final fields = [
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                        items: const [
                          'Technology',
                          'Design',
                          'Business',
                          'Marketing',
                          'Finance',
                          'Engineering',
                          'Other'
                        ]
                            .map((value) => DropdownMenuItem(
                                value: value, child: Text(value)))
                            .toList(),
                        onChanged: readOnly
                            ? null
                            : (value) =>
                                setState(() => category = value ?? category),
                      ),
                      TextFormField(
                        controller: locationController,
                        readOnly: readOnly,
                        decoration: const InputDecoration(
                            labelText: 'Location *', hintText: 'Dhaka'),
                        validator: _required,
                      ),
                    ];
                    return wide
                        ? Row(children: [
                            Expanded(child: fields[0]),
                            const SizedBox(width: 14),
                            Expanded(child: fields[1])
                          ])
                        : Column(children: [
                            fields[0],
                            const SizedBox(height: 14),
                            fields[1]
                          ]);
                  },
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 700;
                    final fields = [
                      DropdownButtonFormField<String>(
                        initialValue: workMode,
                        decoration:
                            const InputDecoration(labelText: 'Work mode'),
                        items: const ['On-site', 'Hybrid', 'Remote']
                            .map((value) => DropdownMenuItem(
                                value: value, child: Text(value)))
                            .toList(),
                        onChanged: readOnly
                            ? null
                            : (value) =>
                                setState(() => workMode = value ?? workMode),
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: employmentType,
                        decoration:
                            const InputDecoration(labelText: 'Employment type'),
                        items: const [
                          'Full-time',
                          'Part-time',
                          'Internship',
                          'Contract'
                        ]
                            .map((value) => DropdownMenuItem(
                                value: value, child: Text(value)))
                            .toList(),
                        onChanged: readOnly
                            ? null
                            : (value) => setState(
                                () => employmentType = value ?? employmentType),
                      ),
                    ];
                    return wide
                        ? Row(children: [
                            Expanded(child: fields[0]),
                            const SizedBox(width: 14),
                            Expanded(child: fields[1])
                          ])
                        : Column(children: [
                            fields[0],
                            const SizedBox(height: 14),
                            fields[1]
                          ]);
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: experienceController,
                  readOnly: readOnly,
                  decoration: const InputDecoration(
                      labelText: 'Experience level *',
                      hintText: 'e.g. 2–3 years'),
                  validator: _required,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Salary and deadline',
            subtitle:
                'Transparent salary information improves candidate quality and trust.',
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 700;
                    final fields = [
                      TextFormField(
                        controller: salaryMinController,
                        readOnly: readOnly,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Minimum monthly salary *',
                            prefixText: '৳ '),
                        validator: _positiveNumber,
                      ),
                      TextFormField(
                        controller: salaryMaxController,
                        readOnly: readOnly,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Maximum monthly salary *',
                            prefixText: '৳ '),
                        validator: _positiveNumber,
                      ),
                    ];
                    return wide
                        ? Row(children: [
                            Expanded(child: fields[0]),
                            const SizedBox(width: 14),
                            Expanded(child: fields[1])
                          ])
                        : Column(children: [
                            fields[0],
                            const SizedBox(height: 14),
                            fields[1]
                          ]);
                  },
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: readOnly ? null : _pickDeadline,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        labelText: 'Application deadline'),
                    child: Row(
                      children: [
                        const Icon(Icons.event_outlined,
                            size: 20, color: AppColors.textMuted),
                        const SizedBox(width: 10),
                        Text(
                            '${deadline.day}/${deadline.month}/${deadline.year}'),
                        const Spacer(),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Role details',
            subtitle:
                'Write concise content. Enter one responsibility or requirement per line.',
            child: Column(
              children: [
                TextFormField(
                  controller: descriptionController,
                  readOnly: readOnly,
                  minLines: 4,
                  maxLines: 7,
                  decoration:
                      const InputDecoration(labelText: 'Job description *'),
                  validator: (value) => (value?.trim().length ?? 0) < 40
                      ? 'Write at least 40 characters.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: responsibilitiesController,
                  readOnly: readOnly,
                  minLines: 4,
                  maxLines: 7,
                  decoration: const InputDecoration(
                      labelText: 'Responsibilities *',
                      hintText: 'One item per line'),
                  validator: _required,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: requirementsController,
                  readOnly: readOnly,
                  minLines: 4,
                  maxLines: 7,
                  decoration: const InputDecoration(
                      labelText: 'Requirements *',
                      hintText: 'One item per line'),
                  validator: _required,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Skills and benefits',
            subtitle: 'Separate skills and benefits with commas.',
            child: Column(
              children: [
                TextFormField(
                  controller: skillsController,
                  readOnly: readOnly,
                  decoration: const InputDecoration(
                      labelText: 'Skills *',
                      hintText: 'Flutter, Dart, Firebase'),
                  validator: _required,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: benefitsController,
                  readOnly: readOnly,
                  decoration: const InputDecoration(
                      labelText: 'Benefits',
                      hintText: 'Festival bonus, Hybrid work'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!readOnly)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (widget.initialJob?.status != EmployerJobStatus.published)
                  OutlinedButton.icon(
                    onPressed:
                        widget.controller.isSaving ? null : () => _save(false),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save draft'),
                  ),
                FilledButton.icon(
                  onPressed:
                      widget.controller.isSaving ? null : () => _save(true),
                  icon: widget.controller.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send_rounded),
                  label: Text(
                      widget.initialJob?.status == EmployerJobStatus.published
                          ? 'Submit changes for review'
                          : 'Submit for review'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;

  String? _positiveNumber(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    return parsed == null || parsed <= 0
        ? 'Enter a valid positive number.'
        : null;
  }

  List<String> _lines(String value) => value
      .split(RegExp(r'[\n,]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);

  Future<void> _pickDeadline() async {
    final result = await showDatePicker(
      context: context,
      initialDate: deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (result != null) setState(() => deadline = result);
  }

  Future<void> _save(bool submitForReview) async {
    if (!formKey.currentState!.validate()) return;
    final minSalary = int.parse(salaryMinController.text.trim());
    final maxSalary = int.parse(salaryMaxController.text.trim());
    if (maxSalary < minSalary) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Maximum salary must be equal to or higher than minimum salary.')),
      );
      return;
    }

    final current = widget.initialJob;
    final now = DateTime.now();
    final job = EmployerJobModel(
      id: current?.id ?? '',
      employerUid: widget.controller.company!.ownerUid,
      companyId: widget.controller.company!.id,
      title: titleController.text.trim(),
      categoryId: category,
      location: locationController.text.trim(),
      workMode: workMode,
      employmentType: employmentType,
      experienceLevel: experienceController.text.trim(),
      salaryMin: minSalary,
      salaryMax: maxSalary,
      salaryPeriod: 'month',
      description: descriptionController.text.trim(),
      responsibilities: _lines(responsibilitiesController.text),
      requirements: _lines(requirementsController.text),
      skills: _lines(skillsController.text),
      benefits: _lines(benefitsController.text),
      deadline: deadline,
      status: current?.status ?? EmployerJobStatus.draft,
      isActive: true,
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
      publishedAt: current?.publishedAt,
      rejectionNote: current?.rejectionNote,
    );

    try {
      await widget.controller.saveJob(job, submitForReview: submitForReview);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(submitForReview
                ? 'Job submitted for admin review.'
                : 'Job draft saved.')),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.employerManageJobs);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _MissingJob extends StatelessWidget {
  const _MissingJob();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(42),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded,
              size: 52, color: AppColors.textSubtle),
          const SizedBox(height: 14),
          const Text('Job not found',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          const SizedBox(height: 6),
          const Text('Return to Manage Jobs and select an available role.',
              style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => Navigator.pushReplacementNamed(
                context, AppRoutes.employerManageJobs),
            child: const Text('Manage jobs'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          const SizedBox(height: 5),
          Text(subtitle,
              style: const TextStyle(
                  color: AppColors.textMuted, height: 1.45, fontSize: 11)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
