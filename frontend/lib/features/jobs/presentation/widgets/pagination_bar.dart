import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    required this.currentPage,
    required this.pageCount,
    required this.onPageChanged,
    super.key,
  });

  final int currentPage;
  final int pageCount;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _PageButton(
          icon: Icons.chevron_left_rounded,
          enabled: currentPage > 1,
          onTap: () => onPageChanged(currentPage - 1),
        ),
        for (var page = 1; page <= pageCount; page++)
          _PageButton(
            label: '$page',
            selected: page == currentPage,
            onTap: () => onPageChanged(page),
          ),
        _PageButton(
          icon: Icons.chevron_right_rounded,
          enabled: currentPage < pageCount,
          onTap: () => onPageChanged(currentPage + 1),
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.onTap,
    this.label,
    this.icon,
    this.selected = false,
    this.enabled = true,
  });

  final VoidCallback onTap;
  final String? label;
  final IconData? icon;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Material(
        color: selected ? AppColors.blueStrong : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.blue : AppColors.border,
              ),
            ),
            child: icon != null
                ? Icon(
                    icon,
                    color: enabled
                        ? AppColors.textSecondary
                        : AppColors.textSubtle,
                  )
                : Text(
                    label!,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
