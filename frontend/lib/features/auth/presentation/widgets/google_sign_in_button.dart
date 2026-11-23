import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.onPressed,
    super.key,
    this.label = 'Continue with Google',
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.input,
          disabledForegroundColor: AppColors.textSubtle,
          disabledBackgroundColor: AppColors.input,
          side: const BorderSide(
            color: AppColors.borderStrong,
            width: 1.25,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.15,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 22),
                child: Image.asset(
                  'assets/logos/google_g.png',
                  width: 30,
                  height: 30,
                  filterQuality: FilterQuality.high,
                  semanticLabel: 'Google',
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 68),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
