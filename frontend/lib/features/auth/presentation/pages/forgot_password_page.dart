import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/auth_failure.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_form_fields.dart';
import '../widgets/auth_shell.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  String? _error;
  bool _submitting = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
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
      await AuthController.instance.sendPasswordReset(_email.text);
      if (!mounted) return;
      setState(() => _sent = true);
    } catch (error) {
      if (!mounted) return;
      setState(() =>
          _error = error is AuthFailure ? error.message : error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      eyebrow: 'Account recovery',
      title: _sent ? 'Check your inbox.' : 'Reset your password.',
      subtitle: _sent
          ? 'A password reset link has been requested for ${_email.text.trim()}.'
          : 'Enter the email connected to your Career Bridge account. Firebase Authentication will send the reset link.',
      child: _sent
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppColors.green.withValues(alpha: .30)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mark_email_read_outlined,
                          color: AppColors.green),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          AuthController.instance.usesFirebase
                              ? 'Open the password reset email and follow the secure link. Then return here to sign in with your new app password.'
                              : 'Sample account only: no real email is sent and demo passwords stay unchanged.',
                          style: const TextStyle(
                              color: AppColors.textSecondary, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
                  child: const Text('Return to sign in'),
                ),
              ],
            )
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthErrorBanner(message: _error),
                  AuthTextField(
                    controller: _email,
                    label: 'Email address',
                    hint: 'you@example.com',
                    icon: Icons.mail_outline_rounded,
                    validator: emailValidator,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Send reset link'),
                  ),
                ],
              ),
            ),
    );
  }
}
