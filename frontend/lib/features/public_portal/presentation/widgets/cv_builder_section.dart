import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/section_container.dart';

class CvBuilderSection extends StatelessWidget {
  const CvBuilderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 72),
      child: Container(
        padding: const EdgeInsets.all(34),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.blueStrong.withValues(alpha: .22),
              AppColors.purple.withValues(alpha: .16),
              AppColors.card,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.blue.withValues(alpha: .28)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 820;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CAREER BRIDGE CV BUILDER',
                    style: TextStyle(
                        color: AppColors.cyan,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 12)),
                const SizedBox(height: 14),
                Text('Create a professional CV without leaving the platform.',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800, height: 1.22)),
                const SizedBox(height: 14),
                const Text(
                  'Fill your profile once to create your CV automatically. Add education, projects, achievements, references, and relevant skills from any background. One page is recommended; longer CVs are supported.',
                  style: TextStyle(color: AppColors.textMuted, height: 1.65),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.jobSeekerCvBuilder,
                  ),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Build my CV'),
                ),
              ],
            );

            final preview = Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: .28),
                      blurRadius: 30,
                      offset: const Offset(0, 16)),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MD. JUNAYET HOSSAIN',
                      style: TextStyle(
                          color: Color(0xFF152238),
                          fontWeight: FontWeight.w900,
                          fontSize: 18)),
                  SizedBox(height: 4),
                  Text('Professional headline',
                      style: TextStyle(
                          color: Color(0xFF2F75E0),
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 15),
                  _CvLine(width: 1),
                  SizedBox(height: 8),
                  _CvLine(width: .82),
                  SizedBox(height: 8),
                  _CvLine(width: .92),
                  SizedBox(height: 18),
                  Text('EDUCATION',
                      style: TextStyle(
                          color: Color(0xFF152238),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 1)),
                  SizedBox(height: 10),
                  _CvLine(width: .9),
                  SizedBox(height: 8),
                  _CvLine(width: .72),
                ],
              ),
            );

            if (!desktop) {
              return Column(
                children: [copy, const SizedBox(height: 34), preview],
              );
            }

            return Row(
              children: [
                Expanded(flex: 6, child: copy),
                const SizedBox(width: 60),
                Expanded(
                    flex: 4,
                    child: Transform.rotate(angle: .025, child: preview)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CvLine extends StatelessWidget {
  const _CvLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: width,
      child: Container(
          height: 6,
          decoration: BoxDecoration(
              color: const Color(0xFFDDE4EE),
              borderRadius: BorderRadius.circular(99))),
    );
  }
}
