import 'package:career_bridge/features/companies/controllers/company_logo_registry.dart';
import 'package:career_bridge/features/companies/data/models/company_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final registry = CompanyLogoRegistry.instance;

  setUp(registry.clear);
  tearDown(registry.clear);

  test('company profile is the single source for logo references', () {
    registry.replaceFromCompanies(const [
      CompanyModel(
        id: 'company-1',
        name: 'Company One',
        industry: 'Technology',
        location: 'Dhaka',
        size: '11–50 employees',
        founded: '2024',
        description: 'A demo company.',
        specialties: ['Flutter'],
        openings: 2,
        logoFileId: 'logo-file-1',
      ),
    ]);

    expect(registry.logoFileIdFor('company-1'), 'logo-file-1');
    expect(registry.logoFileIdFor('missing-company'), isEmpty);
  });

  test('replacing a company logo updates the shared reference', () {
    registry.setLogo('company-1', 'logo-file-1');
    registry.setLogo('company-1', 'logo-file-2');

    expect(registry.logoFileIdFor('company-1'), 'logo-file-2');
  });
}
