import 'package:flutter/material.dart';

import '../../../../app/config/app_environment.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../data/demo_account_catalog.dart';

class DemoAccessPanel extends StatefulWidget {
  const DemoAccessPanel({
    required this.role,
    required this.onUseCredentials,
    super.key,
  });

  final UserRole role;
  final void Function(String email, String password) onUseCredentials;

  @override
  State<DemoAccessPanel> createState() => _DemoAccessPanelState();
}

class _DemoAccessPanelState extends State<DemoAccessPanel> {
  String? _selectedUid;

  @override
  void didUpdateWidget(covariant DemoAccessPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) _selectedUid = null;
  }

  @override
  Widget build(BuildContext context) {
    if (!AppEnvironment.showDemoAccess || widget.role == UserRole.admin) {
      return const SizedBox.shrink();
    }
    final accounts = DemoAccountCatalog.forRole(widget.role);
    final selected = accounts.firstWhere(
      (account) => account.uid == _selectedUid,
      orElse: () => accounts.first,
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blueStrong.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.blue.withValues(alpha: .22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${accounts.length} ${widget.role.label.toLowerCase()} demos',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
          const SizedBox(height: 3),
          const Text(
            'Fictional accounts · sample data only',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            key: ValueKey('demo-account-${widget.role.name}'),
            initialValue: selected.uid,
            isExpanded: true,
            menuMaxHeight: 280,
            decoration: const InputDecoration(
              labelText: 'Choose a demo account',
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
            items: [
              for (final account in accounts)
                DropdownMenuItem(
                  value: account.uid,
                  child: Text(
                    widget.role == UserRole.employer
                        ? '${account.companyName}${account.isPending ? ' · Pending' : ''}'
                        : '${account.name} · ${account.roleTitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
            onChanged: (uid) => setState(() => _selectedUid = uid),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  selected.email,
                  style:
                      const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => widget.onUseCredentials(
                    selected.email, DemoAccountCatalog.password),
                child: const Text('Use'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
