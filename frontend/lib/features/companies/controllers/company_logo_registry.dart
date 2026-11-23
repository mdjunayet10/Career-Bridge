import 'package:flutter/foundation.dart';

import '../data/models/company_model.dart';

/// Single source of truth for company-profile logo file references.
///
/// Jobs and applications keep only a company ID. They never own a separate
/// logo. When an employer replaces the company logo, this registry updates all
/// listening logo widgets immediately.
class CompanyLogoRegistry extends ChangeNotifier {
  CompanyLogoRegistry._();

  static final CompanyLogoRegistry instance = CompanyLogoRegistry._();

  final Map<String, String> _logoFileIds = <String, String>{};

  String logoFileIdFor(String companyId) {
    return _logoFileIds[companyId.trim()] ?? '';
  }

  void replaceFromCompanies(Iterable<CompanyModel> companies) {
    final next = <String, String>{
      for (final company in companies)
        if (company.id.trim().isNotEmpty &&
            company.logoFileId.trim().isNotEmpty)
          company.id.trim(): company.logoFileId.trim(),
    };
    if (mapEquals(_logoFileIds, next)) return;
    _logoFileIds
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  void setLogo(String companyId, String logoFileId) {
    final id = companyId.trim();
    if (id.isEmpty) return;
    final value = logoFileId.trim();
    if (value.isEmpty) {
      if (_logoFileIds.remove(id) != null) notifyListeners();
      return;
    }
    if (_logoFileIds[id] == value) return;
    _logoFileIds[id] = value;
    notifyListeners();
  }

  void clear() {
    if (_logoFileIds.isEmpty) return;
    _logoFileIds.clear();
    notifyListeners();
  }
}
