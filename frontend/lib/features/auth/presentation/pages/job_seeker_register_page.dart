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

class JobSeekerRegisterPage extends StatefulWidget {
  const JobSeekerRegisterPage({super.key});

  @override
  State<JobSeekerRegisterPage> createState() => _JobSeekerRegisterPageState();
}

class _JobSeekerRegisterPageState extends State<JobSeekerRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _acceptedTerms = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submitGoogle() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await AuthController.instance.signInWithGoogle(
        expectedRole: UserRole.jobSeeker,
      );
      if (!mounted) return;

      final user = result.user;
      if (user == null) {
        setState(() {
          _error = 'The Google account could not be connected.';
        });
        return;
      }

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

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      setState(() {
        _error = 'Accept the Terms and Privacy Policy to create your account.';
      });
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final user = await AuthController.instance.registerJobSeeker(
        JobSeekerRegistrationData(
          name: _name.text,
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
    if (!settings.allowJobSeekerRegistration) {
      return RegistrationUnavailable(
        accountType: 'Job Seeker',
        supportEmail: settings.supportEmail,
      );
    }

    return AuthShell(
      eyebrow: 'Job Seeker registration',
      title: 'Create your career workspace.',
      subtitle:
          'Save opportunities, build a structured CV, and follow every application from one secure account.',
      maxFormWidth: 650,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthErrorBanner(message: _error),
              GoogleSignInButton(
                key: const ValueKey('job-seeker-google-sign-in'),
                onPressed: _submitting ? null : _submitGoogle,
              ),
              const SizedBox(height: 8),
              const Text(
                'By continuing with Google, you agree to the Terms of Service and Privacy Policy.',
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
              const _SectionLabel(
                icon: Icons.person_outline_rounded,
                title: 'Account details',
                description:
                    'Use an email address you can access for future account recovery.',
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _name,
                label: 'Full name',
                hint: 'Your full name',
                icon: Icons.person_outline_rounded,
                validator: (value) => requiredValidator(value, 'Full name'),
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _email,
                label: 'Email address',
                hint: 'you@example.com',
                icon: Icons.mail_outline_rounded,
                validator: emailValidator,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final sideBySide = constraints.maxWidth >= 560;
                  final password = AuthPasswordField(
                    controller: _password,
                    validator: passwordValidator,
                    textInputAction: TextInputAction.next,
                  );
                  final confirmation = AuthPasswordField(
                    controller: _confirmPassword,
                    label: 'Confirm password',
                    hint: 'Enter the password again',
                    validator: (value) {
                      final required =
                          requiredValidator(value, 'Password confirmation');
                      if (required != null) return required;
                      if (value != _password.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  );

                  if (!sideBySide) {
                    return Column(
                      children: [
                        password,
                        const SizedBox(height: 14),
                        confirmation,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: password),
                      const SizedBox(width: 14),
                      Expanded(child: confirmation),
                    ],
                  );
                },
              ),
              const SizedBox(height: 9),
              const Row(
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
              ),
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
                    'I agree to the Terms of Service and Privacy Policy.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                ),
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_alt_1_rounded),
                label: Text(
                  _submitting
                      ? 'Creating account…'
                      : 'Create Job Seeker account',
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
                      AppRoutes.login,
                    ),
                    child: const Text('Sign in'),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
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
            color: AppColors.blueStrong.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.blue.withValues(alpha: .22),
            ),
          ),
          child: Icon(icon, size: 20, color: AppColors.blue),
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
