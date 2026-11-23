import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../../shared/widgets/company_logo.dart';
import '../../controllers/employer_workspace_controller.dart';
import '../../data/models/company_profile_model.dart';
import '../widgets/employer_navigation.dart';
import '../widgets/employer_workspace_gate.dart';

class CompanyProfilePage extends StatelessWidget {
  const CompanyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return EmployerWorkspaceGate(
      builder: (context, controller) => DashboardShell(
        role: UserRole.employer,
        title: 'Company profile',
        subtitle:
            'Maintain the public information job seekers use to evaluate your company.',
        items: EmployerNavigation.items,
        selectedIndex: 3,
        accent: AppColors.purple,
        body: _CompanyProfileForm(
            controller: controller, initial: controller.company!),
      ),
    );
  }
}

class _CompanyProfileForm extends StatefulWidget {
  const _CompanyProfileForm({required this.controller, required this.initial});

  final EmployerWorkspaceController controller;
  final CompanyProfileModel initial;

  @override
  State<_CompanyProfileForm> createState() => _CompanyProfileFormState();
}

class _CompanyProfileFormState extends State<_CompanyProfileForm> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController industryController;
  late final TextEditingController sizeController;
  late final TextEditingController websiteController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  late final TextEditingController descriptionController;
  late final TextEditingController tradeLicenseController;

  @override
  void initState() {
    super.initState();
    final value = widget.initial;
    nameController = TextEditingController(text: value.name);
    industryController = TextEditingController(text: value.industry);
    sizeController = TextEditingController(text: value.companySize);
    websiteController = TextEditingController(text: value.website);
    emailController = TextEditingController(text: value.email);
    phoneController = TextEditingController(text: value.phone);
    addressController = TextEditingController(text: value.address);
    descriptionController = TextEditingController(text: value.description);
    tradeLicenseController =
        TextEditingController(text: value.tradeLicenseNumber);
  }

  @override
  void dispose() {
    for (final controller in [
      nameController,
      industryController,
      sizeController,
      websiteController,
      emailController,
      phoneController,
      addressController,
      descriptionController,
      tradeLicenseController,
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
          _VerificationBanner(
              company: widget.controller.company ?? widget.initial),
          const SizedBox(height: 16),
          _CompanyLogoCard(
            company: widget.controller.company ?? widget.initial,
            controller: widget.controller,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final form = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileSection(
                    title: 'Company identity',
                    subtitle:
                        'Core information shown on your public company profile and job listings.',
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                              labelText: 'Company name *'),
                          validator: _required,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        _ResponsivePair(
                          first: TextFormField(
                            controller: industryController,
                            decoration:
                                const InputDecoration(labelText: 'Industry *'),
                            validator: _required,
                          ),
                          second: TextFormField(
                            controller: sizeController,
                            decoration: const InputDecoration(
                                labelText: 'Company size *',
                                hintText: '51–200 employees'),
                            validator: _required,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: descriptionController,
                          minLines: 5,
                          maxLines: 8,
                          decoration: const InputDecoration(
                              labelText: 'Company description *'),
                          validator: (value) => (value?.trim().length ?? 0) < 50
                              ? 'Write at least 50 characters.'
                              : null,
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ProfileSection(
                    title: 'Contact and location',
                    subtitle:
                        'Keep public contact details accurate and professional.',
                    child: Column(
                      children: [
                        _ResponsivePair(
                          first: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                                labelText: 'Company email *'),
                            validator: _email,
                          ),
                          second: TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration:
                                const InputDecoration(labelText: 'Phone *'),
                            validator: _required,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: websiteController,
                          keyboardType: TextInputType.url,
                          decoration: const InputDecoration(
                              labelText: 'Website',
                              hintText: 'https://company.com'),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: addressController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                              labelText: 'Company address *'),
                          validator: _required,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ProfileSection(
                    title: 'Verification information',
                    subtitle:
                        'The trade license number is visible only to authorized administrators.',
                    child: TextFormField(
                      controller: tradeLicenseController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Trade license number',
                        suffixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                    ),
                  ),
                ],
              );
              final preview = _CompanyPreview(
                companyId: (widget.controller.company ?? widget.initial).id,
                name: nameController.text,
                industry: industryController.text,
                description: descriptionController.text,
                completion: _completion(),
                logoFileId:
                    (widget.controller.company ?? widget.initial).logoFileId,
              );
              if (!wide) {
                return Column(
                    children: [preview, const SizedBox(height: 20), form]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: form),
                  const SizedBox(width: 20),
                  Expanded(flex: 3, child: preview),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: widget.controller.isSaving ? null : _save,
            icon: widget.controller.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            label: const Text('Save company profile'),
          ),
        ],
      ),
    );
  }

  int _completion() {
    final values = [
      nameController.text,
      industryController.text,
      sizeController.text,
      websiteController.text,
      emailController.text,
      phoneController.text,
      addressController.text,
      descriptionController.text,
      tradeLicenseController.text,
    ];
    return ((values.where((value) => value.trim().isNotEmpty).length /
                values.length) *
            100)
        .round();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;

  String? _email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'This field is required.';
    if (!text.contains('@') || !text.contains('.')) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!formKey.currentState!.validate()) return;
    final updated = widget.initial.copyWith(
      name: nameController.text.trim(),
      industry: industryController.text.trim(),
      companySize: sizeController.text.trim(),
      website: websiteController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      description: descriptionController.text.trim(),
      tradeLicenseNumber: tradeLicenseController.text.trim(),
      updatedAt: DateTime.now(),
    );
    try {
      await widget.controller.saveCompany(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Company profile updated.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _CompanyLogoCard extends StatelessWidget {
  const _CompanyLogoCard({required this.company, required this.controller});

  final CompanyProfileModel company;
  final EmployerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final image = CompanyLogo(
      companyId: company.id,
      companyName:
          company.name.trim().isEmpty ? 'Company' : company.name.trim(),
      logoFileId: company.logoFileId,
      size: 82,
      borderRadius: 22,
      padding: 6,
    );
    const details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Company logo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        SizedBox(height: 6),
        Text(
          'Upload the logo once. Career Bridge reuses the same company-profile logo on every job card, company page, dashboard, and review screen.',
          style:
              TextStyle(color: AppColors.textMuted, height: 1.5, fontSize: 11),
        ),
      ],
    );
    final button = OutlinedButton.icon(
      onPressed: controller.isSaving ? null : () => _upload(context),
      icon: const Icon(Icons.add_photo_alternate_outlined),
      label: Text(company.logoFileId.isEmpty ? 'Add logo' : 'Replace logo'),
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
              const SizedBox(width: 18),
              button,
            ],
          );
        },
      ),
    );
  }

  Future<void> _upload(BuildContext context) async {
    try {
      final changed = await controller.uploadCompanyLogo();
      if (context.mounted && changed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company logo updated everywhere it is used.'),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }
}

class _ResponsivePair extends StatelessWidget {
  const _ResponsivePair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 560) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 14),
              Expanded(child: second),
            ],
          );
        }
        return Column(
          children: [first, const SizedBox(height: 14), second],
        );
      },
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  const _VerificationBanner({required this.company});

  final CompanyProfileModel company;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.green.withValues(alpha: .24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: AppColors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verified company',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${company.name} is approved. Sensitive ownership and verification fields cannot be changed from the public employer form.',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    height: 1.45,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection(
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
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
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

class _CompanyPreview extends StatelessWidget {
  const _CompanyPreview({
    required this.companyId,
    required this.name,
    required this.industry,
    required this.description,
    required this.completion,
    required this.logoFileId,
  });

  final String companyId;
  final String name;
  final String industry;
  final String description;
  final int completion;
  final String logoFileId;

  @override
  Widget build(BuildContext context) {
    final resolvedName = name.trim().isEmpty ? 'Company name' : name.trim();
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.purple.withValues(alpha: .25)),
        boxShadow: [
          BoxShadow(
              color: AppColors.purple.withValues(alpha: .06),
              blurRadius: 30,
              spreadRadius: 2)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Public preview',
              style: TextStyle(
                  color: AppColors.textSubtle,
                  fontSize: 10,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          CompanyLogo(
            companyId: companyId,
            companyName: resolvedName,
            logoFileId: logoFileId,
            size: 62,
            borderRadius: 18,
            padding: 5,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: Text(resolvedName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 18))),
              const Icon(Icons.verified_rounded,
                  color: AppColors.green, size: 19),
            ],
          ),
          const SizedBox(height: 6),
          Text(industry.trim().isEmpty ? 'Industry' : industry.trim(),
              style: const TextStyle(
                  color: AppColors.purple,
                  fontWeight: FontWeight.w700,
                  fontSize: 11)),
          const SizedBox(height: 16),
          Text(
            description.trim().isEmpty
                ? 'Add a clear company description to help candidates understand your mission and culture.'
                : description.trim(),
            maxLines: 7,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppColors.textMuted, height: 1.55, fontSize: 11),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: completion / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.input,
                    color: AppColors.green,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('$completion%',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.green,
                      fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Profile completeness',
              style: TextStyle(color: AppColors.textSubtle, fontSize: 9)),
        ],
      ),
    );
  }
}
