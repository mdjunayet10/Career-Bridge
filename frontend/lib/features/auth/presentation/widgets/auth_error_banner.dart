import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({required this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: message == null
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.red.withValues(alpha: .30)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.red, size: 20),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      message!,
                      style: const TextStyle(
                          color: AppColors.textSecondary, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
