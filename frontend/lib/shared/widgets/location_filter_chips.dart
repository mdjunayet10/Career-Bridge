import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'location_selector.dart';

class LocationFilterChips extends StatelessWidget {
  const LocationFilterChips({
    required this.selectedLocation,
    required this.onChanged,
    this.showLabel = true,
    super.key,
  });

  final String selectedLocation;
  final ValueChanged<String> onChanged;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;

        final content = Wrap(
          alignment: WrapAlignment.start,
          spacing: compact ? 6 : 8,
          runSpacing: compact ? 6 : 8,
          children: [
            for (final location in JobLocations.values)
              _LocationFilterChip(
                label: JobLocations.label(location),
                selected: selectedLocation == location,
                compact: compact,
                onTap: () => onChanged(location),
              ),
          ],
        );

        if (!showLabel) return content;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 7),
                const Text(
                  'Browse by location',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (selectedLocation.isNotEmpty) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: () => onChanged(''),
                    child: const Text('Clear'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            content,
          ],
        );
      },
    );
  }
}

class _LocationFilterChip extends StatelessWidget {
  const _LocationFilterChip({
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 11 : 14,
            vertical: compact ? 7 : 9,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.blueStrong
                : AppColors.input.withValues(alpha: .72),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.blue : AppColors.borderMuted,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textMuted,
              fontSize: compact ? 10.5 : 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
