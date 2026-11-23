import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class JobFilterPanel extends StatelessWidget {
  const JobFilterPanel({
    required this.categories,
    required this.employmentTypes,
    required this.workModes,
    required this.experienceLevels,
    required this.selectedCategory,
    required this.selectedEmploymentType,
    required this.selectedWorkMode,
    required this.selectedExperience,
    required this.onCategoryChanged,
    required this.onEmploymentTypeChanged,
    required this.onWorkModeChanged,
    required this.onExperienceChanged,
    required this.onClear,
    super.key,
  });

  final List<String> categories;
  final List<String> employmentTypes;
  final List<String> workModes;
  final List<String> experienceLevels;
  final String? selectedCategory;
  final String? selectedEmploymentType;
  final String? selectedWorkMode;
  final String? selectedExperience;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onEmploymentTypeChanged;
  final ValueChanged<String?> onWorkModeChanged;
  final ValueChanged<String?> onExperienceChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Filters',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(onPressed: onClear, child: const Text('Clear all')),
            ],
          ),
          const SizedBox(height: 12),
          _FilterGroup(
            title: 'Category',
            values: categories,
            selectedValue: selectedCategory,
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: 22),
          _FilterGroup(
            title: 'Job type',
            values: employmentTypes,
            selectedValue: selectedEmploymentType,
            onChanged: onEmploymentTypeChanged,
          ),
          const SizedBox(height: 22),
          _FilterGroup(
            title: 'Work style',
            values: workModes,
            selectedValue: selectedWorkMode,
            onChanged: onWorkModeChanged,
          ),
          const SizedBox(height: 22),
          _FilterGroup(
            title: 'Experience',
            values: experienceLevels,
            selectedValue: selectedExperience,
            onChanged: onExperienceChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({
    required this.title,
    required this.values,
    required this.selectedValue,
    required this.onChanged,
  });

  final String title;
  final List<String> values;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        for (final value in values)
          InkWell(
            onTap: () => onChanged(selectedValue == value ? null : value),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: selectedValue == value
                          ? AppColors.blueStrong
                          : AppColors.input,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: selectedValue == value
                            ? AppColors.blue
                            : AppColors.borderStrong,
                      ),
                    ),
                    child: selectedValue == value
                        ? const Icon(Icons.check_rounded,
                            size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
