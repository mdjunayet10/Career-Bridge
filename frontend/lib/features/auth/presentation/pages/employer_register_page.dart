import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/auth_failure.dart';
import '../../../public_portal/controllers/public_portal_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_form_fields.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/auth_shell.dart';
import '../widgets/registration_unavailable.dart';

class EmployerRegisterPage extends StatefulWidget {
  const EmployerRegisterPage({super.key, this.googleAccount});

  final GoogleAccountDraft? googleAccount;

  @override
  State<EmployerRegisterPage> createState() => _EmployerRegisterPageState();
}

class _EmployerRegisterPageState extends State<EmployerRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _contactName = TextEditingController();
  final _companyName = TextEditingController();
  final _industry = TextEditingController();
  final _tradeLicense = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _companySize = '11–50 employees';
  bool _acceptedTerms = false;
  bool _submitting = false;
  String? _error;

  bool get _usesGoogleAccount => widget.googleAccount != null;

  @override
  void initState() {
    super.initState();
    final googleAccount = widget.googleAccount;
    if (googleAccount != null) {
      _contactName.text = googleAccount.name;
      _email.text = googleAccount.email;
    }
  }

  @override
  void dispose() {
    _contactName.dispose();
    _companyName.dispose();
    _industry.dispose();
    _tradeLicense.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submitGoogle() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await AuthController.instance.signInWithGoogle(
        expectedRole: UserRole.employer,
      );
      if (!mounted) return;

      final user = result.user;
      if (user != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AuthController.instance.homeRouteFor(user),
          (_) => false,
        );
        return;
      }

      final pendingEmployer = result.pendingEmployerAccount;
      if (pendingEmployer != null) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.employerRegister,
          arguments: pendingEmployer,
        );
        return;
      }

      setState(() {
        _error = 'The Google sign-in flow could not be completed.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is AuthFailure ? error.message : error.toString();
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      setState(() {
        _error =
            'Accept the employer terms to submit your company registration.';
      });
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final user = _usesGoogleAccount
          ? await AuthController.instance.registerGoogleEmployer(
              GoogleEmployerRegistrationData(
                uid: widget.googleAccount!.uid,
                contactName: _contactName.text,
                companyName: _companyName.text,
                industry: _industry.text,
                companySize: _companySize,
                tradeLicenseNumber: _tradeLicense.text,
                email: _email.text,
              ),
            )
          : await AuthController.instance.registerEmployer(
              EmployerRegistrationData(
                contactName: _contactName.text,
                companyName: _companyName.text,
                industry: _industry.text,
                companySize: _companySize,
                tradeLicenseNumber: _tradeLicense.text,
                email: _email.text,
                password: _password.text,
              ),
            );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AuthController.instance.homeRouteFor(user),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is AuthFailure ? error.message : error.toString();
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = PublicPortalController.instance.settings;
    if (!settings.allowEmployerRegistration) {
      return RegistrationUnavailable(
        accountType: 'Employer',
        supportEmail: settings.supportEmail,
        employer: true,
      );
    }

    return AuthShell(
      eyebrow: 'Company registration',
      title: 'Set up your Employer workspace.',
      subtitle: _usesGoogleAccount
          ? 'Your Google identity is verified. Add the company details required for administrator review.'
          : 'Add the hiring contact and company verification details. An administrator will review the profile before jobs can be published.',
      accent: AppColors.purple,
      portalLabel: 'EMPLOYER PORTAL',
      maxFormWidth: 780,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthErrorBanner(message: _error),
              if (!_usesGoogleAccount) ...[
                GoogleSignInButton(
                  key: const ValueKey('employer-google-sign-in'),
                  onPressed: _submitting ? null : _submitGoogle,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Use your Google account for identity, then complete the company verification details below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 10.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                const _AuthDivider(),
                const SizedBox(height: 18),
              ],
              if (_usesGoogleAccount) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.blue.withValues(alpha: .24),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.blue,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          'Google account connected: ${widget.googleAccount!.email}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const _FormSectionHeader(
                icon: Icons.apartment_rounded,
                title: 'Company information',
                description:
                    'Use the registered organisation details that an administrator can verify.',
              ),
              const SizedBox(height: 16),
              _ResponsiveFieldPair(
                first: AuthTextField(
                  controller: _companyName,
                  label: 'Company name',
                  hint: 'Registered company name',
                  icon: Icons.apartment_rounded,
                  validator: (value) =>
                      requiredValidator(value, 'Company name'),
                  textInputAction: TextInputAction.next,
                ),
                second: AuthTextField(
                  controller: _industry,
                  label: 'Industry',
                  hint: 'Technology, Finance, Education…',
                  icon: Icons.category_outlined,
                  validator: (value) => requiredValidator(value, 'Industry'),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 14),
              _ResponsiveFieldPair(
                first: DropdownButtonFormField<String>(
                  initialValue: _companySize,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Company size',
                    prefixIcon: Icon(Icons.groups_outlined),
                  ),
                  items: const [
                    '1–10 employees',
                    '11–50 employees',
                    '51–200 employees',
                    '201–500 employees',
                    '500+ employees',
                  ]
                      .map(
                        (value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _companySize = value ?? _companySize);
                  },
                ),
                second: AuthTextField(
                  controller: _tradeLicense,
                  label: 'Trade license number',
                  hint: 'License or verification reference',
                  icon: Icons.verified_user_outlined,
                  validator: (value) =>
                      requiredValidator(value, 'Trade license number'),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 22),
              const _FormSectionHeader(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Hiring contact and account',
                description:
                    'This person will manage jobs and applicants after verification.',
              ),
              const SizedBox(height: 16),
              _ResponsiveFieldPair(
                first: AuthTextField(
                  controller: _contactName,
                  label: 'Contact person',
                  hint: 'Full name',
                  icon: Icons.badge_outlined,
                  validator: (value) =>
                      requiredValidator(value, 'Contact person'),
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                ),
                second: AuthTextField(
                  controller: _email,
                  label: 'Work email',
                  hint: 'hiring@company.com',
                  icon: Icons.alternate_email_rounded,
                  validator: emailValidator,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  readOnly: _usesGoogleAccount,
                ),
              ),
              if (!_usesGoogleAccount) ...[
                const SizedBox(height: 14),
                AuthPasswordField(
                  controller: _password,
                  validator: passwordValidator,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                const _PasswordHint(),
              ],
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.input,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: AppColors.borderMuted),
                ),
                child: CheckboxListTile(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() => _acceptedTerms = value ?? false);
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'I confirm that I am authorised to represent this company and agree to the employer terms.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11.5,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  minimumSize: const Size.fromHeight(54),
                ),
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _usesGoogleAccount
                            ? Icons.login_rounded
                            : Icons.verified_user_outlined,
                      ),
                label: Text(
                  _submitting
                      ? 'Submitting…'
                      : _usesGoogleAccount
                          ? 'Complete Google company registration'
                          : 'Submit company registration',
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  const Text(
                    'Already registered?',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.employerLogin,
                    ),
                    child: const Text('Employer sign in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponsiveFieldPair extends StatelessWidget {
  const _ResponsiveFieldPair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              first,
              const SizedBox(height: 14),
              second,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 14),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _FormSectionHeader extends StatelessWidget {
  const _FormSectionHeader({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: AppColors.purple.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.purple.withValues(alpha: .22),
            ),
          ),
          child: Icon(icon, size: 20, color: AppColors.purple),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PasswordHint extends StatelessWidget {
  const _PasswordHint();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 15,
          color: AppColors.textSubtle,
        ),
        SizedBox(width: 7),
        Expanded(
          child: Text(
            'Use at least 8 characters with one uppercase letter and one number.',
            style: TextStyle(
              color: AppColors.textSubtle,
              fontSize: 10.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthDivider extends StatelessWidget {
  const _AuthDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.textSubtle,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}
