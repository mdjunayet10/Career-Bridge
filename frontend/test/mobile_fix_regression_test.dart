import 'package:flutter_test/flutter_test.dart';
import 'package:career_bridge/core/services/cv_pdf_service.dart';
import 'package:career_bridge/features/auth/data/repositories/demo_auth_repository.dart';
import 'package:career_bridge/features/job_seeker/data/repositories/demo_job_seeker_workspace_repository.dart';
import 'package:career_bridge/features/cv_builder/data/models/cv_profile_model.dart';
import 'package:career_bridge/features/jobs/data/jobs_demo_data.dart';
import 'package:career_bridge/features/companies/data/companies_demo_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('demo profile reports missing details and exports coherent CV sections', () async {
    final auth = DemoAuthRepository();
    final user = await auth.signIn(
        email: 'jobseeker@careerbridge.demo', password: 'Demo123!');
    expect(user.name, 'Ayan Rahman (Demo)');
    final snapshot = await DemoJobSeekerWorkspaceRepository()
        .load(uid: user.uid, name: user.name, email: user.email);
    expect(snapshot.profile.completionPercent, lessThan(100));
    expect(snapshot.profile.incompleteFields, contains('Profile photo'));
    expect(snapshot.cvProfile.fullName, user.name);
    expect(snapshot.cvProfile.education, isNotEmpty);
    expect(snapshot.cvProfile.projects, isNotEmpty);
    expect(snapshot.cvProfile.experience, isNotEmpty);
    expect(snapshot.cvProfile.achievements, isNotEmpty);
    expect(snapshot.cvProfile.references, isNotEmpty);
    for (final section in CvSection.values) {
      expect(snapshot.cvProfile.isSectionVisible(section), isTrue);
    }
    // This actually exercises the production PDF renderer and asset fonts.
    final bytes = await CvPdfService.instance.buildPdf(snapshot.cvProfile);
    expect(bytes.length, greaterThan(1000));
    expect(bytes.length, lessThanOrEqualTo(2 * 1024 * 1024));
  });
  test('demo jobs point to known demo companies', () {
    final companies = {for (final c in CompaniesDemoData.companies) c.id};
    for (final job
        in JobsDemoData.jobs.where((j) => j.id.startsWith('demo-'))) {
      expect(companies, contains(job.companyId));
      expect(job.title, contains('(Demo)'));
    }
  });
}
