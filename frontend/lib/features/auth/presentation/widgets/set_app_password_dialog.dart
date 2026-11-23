import 'package:flutter/material.dart';
import '../../../../core/errors/auth_failure.dart';
import '../../../../core/services/account_password_service.dart';
import 'auth_form_fields.dart';

class SetAppPasswordDialog extends StatefulWidget {
  const SetAppPasswordDialog({super.key, required this.service});
  final AccountPasswordService service;
  @override
  State<SetAppPasswordDialog> createState() => _SetAppPasswordDialogState();
}

class _SetAppPasswordDialogState extends State<SetAppPasswordDialog> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.service.addPassword(_password.text);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is AuthFailure
            ? error.message
            : 'Could not set the password. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_saving,
        child: AlertDialog(
          title: const Text('Set app password'),
          content: SingleChildScrollView(
            child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                        'Choose a Career Bridge password to sign in with your email on another device. Google sign-in will also keep working. Use a different password from your Google account.'),
                    const SizedBox(height: 20),
                    AuthPasswordField(
                        controller: _password,
                        label: 'New app password',
                        hint: 'At least 8 characters',
                        validator: passwordValidator),
                    const SizedBox(height: 16),
                    AuthPasswordField(
                        controller: _confirm,
                        label: 'Confirm password',
                        hint: 'Repeat your new password',
                        validator: (value) => value == _password.text
                            ? null
                            : 'Passwords do not match.'),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ],
                  ],
                )),
          ),
          actions: [
            TextButton(
                onPressed: _saving ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving…' : 'Set password')),
          ],
        ),
      );
}
