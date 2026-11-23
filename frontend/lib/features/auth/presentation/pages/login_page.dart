import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/auth_failure.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_form_fields.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/auth_shell.dart';
import '../widgets/demo_access_panel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.expectedRole, this.redirectRoute});

  final UserRole? expectedRole;
  final String? redirectRoute;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late UserRole _selectedRole;
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.expectedRole == UserRole.employer
        ? UserRole.employer
        : UserRole.jobSeeker;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final user = await AuthController.instance.signIn(
        email: _emailController.text,
        password: _passwordController.text,
        expectedRole: _selectedRole,
      );
      if (!mounted) return;
      final route =
          widget.redirectRoute ?? AuthController.instance.homeRouteFor(user);
      Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
    } catch (error) {
      if (!mounted) return;
      setState(() =>
          _error = error is AuthFailure ? error.message : error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitGoogle() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await AuthController.instance.signInWithGoogle(
        expectedRole: _selectedRole,
      );
      if (!mounted) return;

      final user = result.user;
      if (user != null) {
        final route =
            widget.redirectRoute ?? AuthController.instance.homeRouteFor(user);
        Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
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

  void _useDemo(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final employer = _selectedRole == UserRole.employer;
    return AuthShell(
      eyebrow: employer ? 'Employer access' : 'Welcome back',
      title: employer
          ? 'Continue managing your hiring.'
          : 'Continue your career journey.',
      subtitle: employer
          ? 'Sign in to post jobs, review applicants, and manage your company workspace.'
          : 'Sign in to discover relevant jobs, track applications, and continue building your profile.',
      accent: employer ? AppColors.purple : AppColors.blue,
      maxFormWidth: 560,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.expectedRole == null) ...[
                _RoleSelector(
                  selected: _selectedRole,
                  onChanged: (role) => setState(() {
                    _selectedRole = role;
                    _error = null;
                  }),
                ),
                const SizedBox(height: 20),
              ],
              AuthErrorBanner(message: _error),
              AuthTextField(
                controller: _emailController,
                label: employer ? 'Work email' : 'Email address',
                hint: employer ? 'you@company.com' : 'you@example.com',
                icon: Icons.mail_outline_rounded,
                validator: emailValidator,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 15),
              AuthPasswordField(
                controller: _passwordController,
                validator: (value) => requiredValidator(value, 'Password'),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.forgotPassword),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_submitting) ...[
                      const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                        child: Text(
                            employer ? 'Sign in to Employer Portal' : 'Sign in',
                            textAlign: TextAlign.center)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _AuthDivider(),
              const SizedBox(height: 18),
              GoogleSignInButton(
                key: const ValueKey('login-google-sign-in'),
                onPressed: _submitting ? null : _submitGoogle,
              ),
              const SizedBox(height: 18),
              DemoAccessPanel(role: _selectedRole, onUseCredentials: _useDemo),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  Text(
                    employer
                        ? 'Need a company account?'
                        : 'New to Career Bridge?',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      employer
                          ? AppRoutes.employerRegister
                          : AppRoutes.jobSeekerRegister,
                    ),
                    child: Text(
                      employer ? 'Register company' : 'Create account',
                    ),
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

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.selected, required this.onChanged});

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.input,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleOption(
              label: 'Job Seeker',
              icon: Icons.person_search_outlined,
              selected: selected == UserRole.jobSeeker,
              accent: AppColors.blue,
              onTap: () => onChanged(UserRole.jobSeeker),
            ),
          ),
          Expanded(
            child: _RoleOption(
              label: 'Employer',
              icon: Icons.business_center_outlined,
              selected: selected == UserRole.employer,
              accent: AppColors.purple,
              onTap: () => onChanged(UserRole.employer),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 150;
        final roleIcon = Icon(
          icon,
          size: 19,
          color: selected ? accent : AppColors.textMuted,
        );
        final roleLabel = Text(
          label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 12 : null,
            height: compact ? 1.2 : null,
            letterSpacing: compact ? 0 : null,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? AppColors.textPrimary : AppColors.textMuted,
          ),
        );
        return Semantics(
          label: label,
          button: true,
          selected: selected,
          onTap: onTap,
          excludeSemantics: true,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(11),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              constraints: const BoxConstraints(minHeight: 48),
              padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 12, vertical: compact ? 10 : 13),
              decoration: BoxDecoration(
                color: selected ? AppColors.cardHover : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                    color:
                        selected ? AppColors.borderStrong : Colors.transparent),
              ),
              child: compact
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        roleIcon,
                        const SizedBox(height: 6),
                        roleLabel,
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        roleIcon,
                        const SizedBox(width: 8),
                        Flexible(child: roleLabel),
                      ],
                    ),
            ),
          ),
        );
      },
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
