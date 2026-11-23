import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/animations/typing_text.dart';
import '../../../../shared/widgets/company_logo.dart';
import '../../../../shared/widgets/location_filter_chips.dart';
import '../../../../shared/widgets/section_container.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 78, 24, 76),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 960;
              final copy = _HeroCopy(desktop: desktop);
              const preview = _DashboardPreview();
              return desktop
                  ? Row(
                      children: [
                        Expanded(flex: 11, child: copy),
                        const SizedBox(width: 54),
                        const Expanded(flex: 9, child: preview),
                      ],
                    )
                  : Column(
                      children: [
                        copy,
                        const SizedBox(height: 44),
                        preview,
                      ],
                    );
            },
          ),
        ),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.desktop});

  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final headlineStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
          fontSize: desktop ? 58 : 42,
          fontWeight: FontWeight.w800,
          height: 1.08,
          letterSpacing: -1.8,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.blueStrong.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.blue.withValues(alpha: .28)),
          ),
          child: Text(
            'BUILT FOR CAREERS IN BANGLADESH',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Find the work that', style: headlineStyle),
        const SizedBox(height: 4),
        SizedBox(
          height: desktop ? 132 : 104,
          child: TypingText(
            values: const [
              'moves your future forward.',
              'matches your ambition.',
              'connects you to opportunity.',
            ],
            style: headlineStyle?.copyWith(color: AppColors.blue) ??
                const TextStyle(),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            'Discover verified opportunities, compare salary ranges, build a professional CV, and manage every application from one focused platform.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textMuted,
                  height: 1.65,
                ),
          ),
        ),
        const SizedBox(height: 30),
        const _SearchPanel(),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            _KeywordChip('Flutter Developer'),
            _KeywordChip('UI/UX Designer'),
            _KeywordChip('Remote Jobs'),
            _KeywordChip('Internship'),
          ],
        ),
      ],
    );
  }
}

class _SearchPanel extends StatefulWidget {
  const _SearchPanel();

  @override
  State<_SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<_SearchPanel> {
  final TextEditingController _queryController = TextEditingController();
  String _location = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _search() {
    final params = <String, String>{};
    if (_queryController.text.trim().isNotEmpty) {
      params['q'] = _queryController.text.trim();
    }
    if (_location.isNotEmpty) {
      params['location'] = _location;
    }
    final uri = Uri(
        path: AppRoutes.jobs, queryParameters: params.isEmpty ? null : params);
    Navigator.pushNamed(context, uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 700;
        final titleField = TextField(
          controller: _queryController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: 'Job title, skill or company',
          ),
        );
        final button = FilledButton.icon(
          onPressed: _search,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.blueStrong,
            foregroundColor: Colors.white,
            minimumSize: const Size(160, 56),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          ),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Search jobs'),
        );

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.panel.withValues(alpha: .92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .28),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (stacked) ...[
                titleField,
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: button),
              ] else
                Row(
                  children: [
                    Expanded(child: titleField),
                    const SizedBox(width: 10),
                    button,
                  ],
                ),
              const SizedBox(height: 12),
              LocationFilterChips(
                selectedLocation: _location,
                onChanged: (value) => setState(() => _location = value),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KeywordChip extends StatelessWidget {
  const _KeywordChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '${AppRoutes.jobs}?q=${Uri.encodeQueryComponent(label)}',
        );
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderMuted),
        ),
        child: Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ),
    );
  }
}

class _DashboardPreview extends StatelessWidget {
  const _DashboardPreview();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
              offset: Offset(0, 28 * (1 - value)), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.card, AppColors.panel.withValues(alpha: .98)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.blue.withValues(alpha: .28)),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueStrong.withValues(alpha: .12),
              blurRadius: 54,
              offset: const Offset(0, 26),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.blueStrong.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.space_dashboard_outlined,
                      color: AppColors.blue),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your career dashboard',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 3),
                      Text('One place for jobs and applications',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const _PreviewJob(
              companyId: 'novatech-bangladesh',
              company: 'NovaTech',
              role: 'Flutter Developer',
              salary: '৳45k–70k',
            ),
            const SizedBox(height: 12),
            const _PreviewJob(
              companyId: 'pixelforge-studio',
              company: 'PixelForge',
              role: 'Product Designer',
              salary: '৳40k–60k',
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Icon(Icons.verified_rounded, size: 18, color: AppColors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Verified employers and clearer job listings',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewJob extends StatelessWidget {
  const _PreviewJob({
    required this.companyId,
    required this.company,
    required this.role,
    required this.salary,
  });

  final String companyId;
  final String company;
  final String role;
  final String salary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: .46),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Row(
        children: [
          CompanyLogo(
            companyId: companyId,
            companyName: company,
            size: 42,
            borderRadius: 13,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(company,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11)),
                const SizedBox(height: 3),
                Text(role, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Text(salary,
              style: const TextStyle(
                  color: AppColors.cyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
