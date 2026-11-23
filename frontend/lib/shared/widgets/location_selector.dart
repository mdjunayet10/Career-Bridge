import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

abstract final class JobLocations {
  static const values = <String>[
    '',
    'Dhaka',
    'Chattogram',
    'Sylhet',
    'Rajshahi',
    'Khulna',
    'Barishal',
    'Rangpur',
    'Mymensingh',
    'Gazipur',
    'Remote',
  ];

  static String normalize(String value) {
    final trimmed = value.trim();
    if (trimmed.toLowerCase() == 'chittagong') return 'Chattogram';
    for (final location in values) {
      if (location.toLowerCase() == trimmed.toLowerCase()) return location;
    }
    return '';
  }

  static String label(String value) =>
      value.trim().isEmpty ? 'All locations' : value.trim();
}

class LocationSelector extends StatelessWidget {
  const LocationSelector({
    required this.value,
    required this.onChanged,
    this.height = 56,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final normalized = JobLocations.normalize(value);

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.input,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: AppColors.textMuted,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: normalized,
                isExpanded: true,
                borderRadius: BorderRadius.circular(16),
                dropdownColor: AppColors.panel,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted,
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: normalized.isEmpty
                          ? AppColors.textSubtle
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                items: [
                  for (final location in JobLocations.values)
                    DropdownMenuItem<String>(
                      value: location,
                      child: Text(
                        JobLocations.label(location),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (selected) => onChanged(selected ?? ''),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
