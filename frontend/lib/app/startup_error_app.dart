import 'package:flutter/material.dart';

import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class CareerBridgeStartupErrorApp extends StatelessWidget {
  const CareerBridgeStartupErrorApp({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Career Bridge setup required',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.settings_suggest_outlined,
                      color: AppColors.yellow,
                      size: 42,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Career Bridge could not start.',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'The selected runtime configuration is incomplete or invalid. '
                      'For demo mode, run with config/demo.json. For Firebase mode, '
                      'finish config/firebase.local.json first.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.input,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderMuted),
                      ),
                      child: SelectableText(
                        error.toString(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'monospace',
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const SelectableText(
                      'Demo command:\n'
                      'flutter run -d chrome --dart-define-from-file=config/demo.json',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
