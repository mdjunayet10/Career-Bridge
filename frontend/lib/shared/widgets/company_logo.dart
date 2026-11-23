import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../features/file_storage/presentation/widgets/stored_file_image.dart';
import '../../features/companies/controllers/company_logo_registry.dart';

/// Displays the single logo associated with a company profile.
///
/// A job never owns a separate logo. The widget resolves the current logo from
/// the shared company-logo registry using [companyId]. Employer/admin previews
/// can pass an explicit [logoFileId] while the public catalog is refreshing. Demo companies
/// fall back to local symbol-only assets; missing logos use a neutral icon.
class CompanyLogo extends StatelessWidget {
  const CompanyLogo({
    required this.companyId,
    required this.companyName,
    this.logoFileId = '',
    this.size = 54,
    this.borderRadius = 16,
    this.padding = 5,
    super.key,
  });

  final String companyId;
  final String companyName;
  final String logoFileId;
  final double size;
  final double borderRadius;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CompanyLogoRegistry.instance,
      builder: (context, _) {
        final registeredLogoId =
            CompanyLogoRegistry.instance.logoFileIdFor(companyId);
        final resolvedLogoId =
            logoFileId.trim().isNotEmpty ? logoFileId.trim() : registeredLogoId;
        final radius = BorderRadius.circular(borderRadius);
        final innerRadius = BorderRadius.circular(
          (borderRadius - padding).clamp(8, borderRadius).toDouble(),
        );
        final fallback = _BundledCompanyLogo(
          companyId: companyId,
          borderRadius: innerRadius,
        );

        return Semantics(
          label: '$companyName logo',
          image: true,
          child: Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(padding),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: radius,
              border: Border.all(
                color: Colors.white.withValues(alpha: .13),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .22),
                  blurRadius: 20,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: StoredFileImage(
              fileId: resolvedLogoId,
              fit: BoxFit.contain,
              borderRadius: innerRadius,
              fallback: fallback,
            ),
          ),
        );
      },
    );
  }
}

class _BundledCompanyLogo extends StatelessWidget {
  const _BundledCompanyLogo({
    required this.companyId,
    required this.borderRadius,
  });

  final String companyId;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    if (companyId.trim().isEmpty) return const _GenericCompanyMark();
    final assetId = companyId == 'demo-novatech-bangladesh'
        ? 'novatech-bangladesh'
        : companyId;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        'assets/company_logos/$assetId.png',
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) =>
            const _GenericCompanyMark(),
      ),
    );
  }
}

class _GenericCompanyMark extends StatelessWidget {
  const _GenericCompanyMark();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blueStrong, AppColors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.apartment_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
