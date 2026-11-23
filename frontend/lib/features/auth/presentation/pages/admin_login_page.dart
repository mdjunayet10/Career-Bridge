import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/auth_failure.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_form_fields.dart';
import '../widgets/auth_shell.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key, this.redirectRoute});

  final String? redirectRoute;

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
      await AuthController.instance.signIn(
        email: _email.text,
        password: _password.text,
        expectedRole: UserRole.admin,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        widget.redirectRoute ?? AppRoutes.adminDashboard,
        (_) => false,
      );
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
      eyebrow: 'Restricted access',
      title: 'Career Bridge administration.',
      subtitle:
          'This portal is not linked from the public website. Only manually provisioned administrator accounts can continue.',
      accent: AppColors.red,
      portalLabel: 'ADMIN CONTROL PANEL',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthErrorBanner(message: _error),
            AuthTextField(
              controller: _email,
              label: 'Administrator email',
              hint: 'admin@careerbridge.com',
              icon: Icons.admin_panel_settings_outlined,
              validator: emailValidator,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 15),
            AuthPasswordField(
              controller: _password,
              validator: (value) => requiredValidator(value, 'Password'),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(backgroundColor: AppColors.red),
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.lock_open_rounded),
              label: const Text('Enter Admin Panel'),
            ),
            const SizedBox(height: 18),
            const Text(
              'Access attempts are protected by Firebase Authentication, Firestore role checks, and admin-only Security Rules.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSubtle, height: 1.5, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
