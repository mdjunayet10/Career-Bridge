import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../cv_builder/data/models/cv_profile_model.dart';
import '../../../cv_builder/presentation/widgets/cv_details_editor.dart';
import '../../../cv_builder/services/profile_cv_sync_service.dart';
import '../../../file_storage/presentation/widgets/stored_file_image.dart';
import '../../controllers/job_seeker_workspace_controller.dart';
import '../../data/models/job_seeker_profile_model.dart';
import '../widgets/job_seeker_navigation.dart';
import '../widgets/job_seeker_workspace_gate.dart';

class JobSeekerProfilePage extends StatelessWidget {
  const JobSeekerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      role: UserRole.jobSeeker,
      title: 'Career profile',
      subtitle:
          'Keep your professional information complete for stronger job recommendations.',
      items: JobSeekerNavigation.items,
      selectedIndex: 3,
      body: JobSeekerWorkspaceGate(
        builder: (context, controller) => _ProfileForm(
          key: ValueKey(controller.profile!.uid),
          controller: controller,
          profile: controller.profile!,
        ),
      ),
    );
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm(
      {required this.controller, required this.profile, super.key});

  final JobSeekerWorkspaceController controller;
  final JobSeekerProfileModel profile;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _headline;
  late final TextEditingController _phone;
  late final TextEditingController _location;
  late final TextEditingController _about;
  late final TextEditingController _experienceYears;
  late final TextEditingController _skills;
  late final TextEditingController _preferredRoles;
  late final TextEditingController _preferredLocations;
  late final TextEditingController _workModes;
  late final TextEditingController _portfolio;
  late final TextEditingController _linkedIn;
  late CvProfileModel _cvDetails;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _name = TextEditingController(text: profile.fullName);
    _email = TextEditingController(text: profile.email);
    _headline = TextEditingController(text: profile.headline);
    _phone = TextEditingController(text: profile.phone);
    _location = TextEditingController(text: profile.location);
    _about = TextEditingController(text: profile.about);
    _experienceYears =
        TextEditingController(text: '${profile.experienceYears}');
    _skills = TextEditingController(text: profile.skills.join(', '));
    _preferredRoles =
        TextEditingController(text: profile.preferredRoles.join(', '));
    _preferredLocations =
        TextEditingController(text: profile.preferredLocations.join(', '));
    _workModes = TextEditingController(text: profile.workModes.join(', '));
    _portfolio = TextEditingController(text: profile.portfolioUrl);
    _linkedIn = TextEditingController(text: profile.linkedInUrl);
    _cvDetails = ProfileCvSyncService.sync(
      profile: profile,
      currentCv: widget.controller.cvProfile!,
      previousProfile: profile,
    );
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _headline,
      _phone,
      _location,
      _about,
      _experienceYears,
      _skills,
      _preferredRoles,
      _preferredLocations,
      _workModes,
      _portfolio,
      _linkedIn,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfilePhotoCard(
            profile: widget.controller.profile ?? widget.profile,
            controller: widget.controller,
          ),
          const SizedBox(height: 16),
          _CompletionCard(profile: widget.controller.profile ?? widget.profile),
          const SizedBox(height: 14),
          const _AutoCvNotice(),
          const SizedBox(height: 20),
          _FormSection(
            title: 'Professional identity',
            description:
                'This information appears to employers when you apply.',
            child: _ResponsiveFields(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: _required,
                ),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Contact email'),
                  validator: (value) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                          .hasMatch(value?.trim() ?? '')
                      ? null
                      : 'Enter a valid email address',
                ),
                TextFormField(
                    controller: _headline,
                    decoration: const InputDecoration(
                        labelText: 'Professional headline'),
                    validator: _required),
                TextFormField(
                    controller: _phone,
                    decoration:
                        const InputDecoration(labelText: 'Phone number'),
                    validator: _required),
                TextFormField(
                    controller: _location,
                    decoration: const InputDecoration(labelText: 'Location'),
                    validator: _required),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FormSection(
            title: 'About and background',
            description:
                'Summarize your value, education, and practical experience.',
            child: Column(
              children: [
                TextFormField(
                  controller: _about,
                  maxLines: 5,
                  maxLength: 600,
                  decoration:
                      const InputDecoration(labelText: 'Professional summary'),
                  validator: _required,
                ),
                const SizedBox(height: 14),
                _ResponsiveFields(
                  children: [
                    TextFormField(
                      controller: _experienceYears,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Years of experience'),
                      validator: (value) => int.tryParse(value ?? '') == null
                          ? 'Enter a valid number'
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FormSection(
            title: 'Skills and preferences',
            description: 'Use commas to separate multiple values.',
            child: _ResponsiveFields(
              children: [
                TextFormField(
                    controller: _skills,
                    decoration: const InputDecoration(
                        labelText: 'Additional skills',
                        hintText: 'Communication, Research, Leadership')),
                TextFormField(
                    controller: _preferredRoles,
                    decoration:
                        const InputDecoration(labelText: 'Preferred roles')),
                TextFormField(
                    controller: _preferredLocations,
                    decoration: const InputDecoration(
                        labelText: 'Preferred locations')),
                TextFormField(
                    controller: _workModes,
                    decoration: const InputDecoration(
                        labelText: 'Work modes', hintText: 'Remote, Hybrid')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FormSection(
            title: 'Professional links',
            description: 'Portfolio links help employers validate your work.',
            child: _ResponsiveFields(
              children: [
                TextFormField(
                    controller: _portfolio,
                    decoration:
                        const InputDecoration(labelText: 'Portfolio URL')),
                TextFormField(
                    controller: _linkedIn,
                    decoration:
                        const InputDecoration(labelText: 'LinkedIn URL')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CvDetailsEditor(
            profile: _cvDetails,
            onChanged: (value) => setState(() => _cvDetails = value),
          ),
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: widget.controller.isSaving ? null : _save,
              icon: widget.controller.isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: const Text('Save profile'),
            ),
          ),
        ],
      ),
    );
  }

  String? _required(String? value) =>
      value?.trim().isEmpty == true ? 'This field is required' : null;

  List<String> _split(TextEditingController controller) => controller.text
      .split(',')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList(growable: false);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final details = ProfileCvSyncService.normalizeDetails(_cvDetails);
    final updated = (widget.controller.profile ?? widget.profile).copyWith(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      headline: _headline.text.trim(),
      phone: _phone.text.trim(),
      location: _location.text.trim(),
      about: _about.text.trim(),
      hasCvDetails: true,
      education: details.education,
      technicalLanguages: details.technicalLanguages,
      frameworks: details.frameworks,
      toolsAndPlatforms: details.toolsAndPlatforms,
      projects: details.projects,
      experience: details.experience,
      hasCvExperience: true,
      achievements: details.achievements,
      references: details.references,
      experienceYears: int.tryParse(_experienceYears.text.trim()) ?? 0,
      skills: _split(_skills),
      preferredRoles: _split(_preferredRoles),
      preferredLocations: _split(_preferredLocations),
      workModes: _split(_workModes),
      portfolioUrl: _portfolio.text.trim(),
      linkedInUrl: _linkedIn.text.trim(),
      updatedAt: DateTime.now(),
    );
    try {
      await widget.controller.saveProfile(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profile saved. Your CV and job recommendations were updated automatically.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                widget.controller.errorMessage ?? 'Could not save profile.')));
      }
    }
  }
}

class _AutoCvNotice extends StatelessWidget {
  const _AutoCvNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blue.withValues(alpha: .2)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final copy = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto CV + smart job matching',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Save your profile to create or update your CV automatically, including education, skills, projects, experience, achievements, references, and your photo. One page is recommended, but longer CVs are supported. Your background and preferences also improve job matching.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final action = OutlinedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.jobSeekerCvBuilder),
            icon: const Icon(Icons.description_outlined, size: 17),
            label: const Text('View CV'),
          );

          if (constraints.maxWidth < 680) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [copy, const SizedBox(height: 12), action],
            );
          }
          return Row(
            children: [
              Expanded(child: copy),
              const SizedBox(width: 18),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _ProfilePhotoCard extends StatelessWidget {
  const _ProfilePhotoCard({required this.profile, required this.controller});

  final JobSeekerProfileModel profile;
  final JobSeekerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final initial = profile.fullName.trim().isEmpty
        ? 'J'
        : profile.fullName.trim()[0].toUpperCase();
    final fallback = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.blueStrong, AppColors.purple]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(initial,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
    );
    final image = SizedBox(
      width: 86,
      height: 86,
      child: StoredFileImage(
        fileId: profile.profileImageFileId,
        fallback: fallback,
        borderRadius: BorderRadius.circular(24),
      ),
    );
    const details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profile photo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        SizedBox(height: 6),
        Text(
          'JPG, PNG, or WebP. The app compresses the image before storing it in Firestore. Maximum final size: 2 MB.',
          style:
              TextStyle(color: AppColors.textMuted, height: 1.5, fontSize: 11),
        ),
      ],
    );
    final button = OutlinedButton.icon(
      onPressed: controller.isSaving ? null : () => _upload(context),
      icon: const Icon(Icons.photo_camera_outlined),
      label: Text(profile.profileImageFileId.isEmpty ? 'Add photo' : 'Replace'),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 620) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  image,
                  const SizedBox(width: 16),
                  const Expanded(child: details)
                ]),
                const SizedBox(height: 16),
                button,
              ],
            );
          }
          return Row(
            children: [
              image,
              const SizedBox(width: 18),
              const Expanded(child: details),
              const SizedBox(width: 14),
              button,
            ],
          );
        },
      ),
    );
  }

  Future<void> _upload(BuildContext context) async {
    try {
      final changed = await controller.uploadProfileImage();
      if (changed && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo compressed and saved.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.profile});

  final JobSeekerProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.blueStrong.withValues(alpha: .16),
          AppColors.purple.withValues(alpha: .08)
        ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blue.withValues(alpha: .25)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                    value: profile.completion,
                    strokeWidth: 6,
                    backgroundColor: AppColors.borderMuted),
                Center(
                    child: Text('${profile.completionPercent}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 11))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Profile strength',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 5),
              Text(
                  profile.incompleteFields.isEmpty
                      ? 'All profile details are complete.'
                      : 'Still needed: ${profile.incompleteFields.join(', ')}.',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11, height: 1.45)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection(
      {required this.title, required this.description, required this.child});

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: AppColors.borderMuted)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 5),
        Text(description,
            style: const TextStyle(color: AppColors.textSubtle, fontSize: 11)),
        const SizedBox(height: 18),
        child,
      ]),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 2 : 1;
        final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final child in children) SizedBox(width: width, child: child)
          ],
        );
      },
    );
  }
}
