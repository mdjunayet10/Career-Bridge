import 'package:career_bridge/core/enums/application_status.dart';
import 'package:career_bridge/features/auth/data/repositories/demo_auth_repository.dart';
import 'package:career_bridge/features/demo/data/demo_application_store.dart';
import 'package:career_bridge/features/employer/data/repositories/demo_employer_workspace_repository.dart';
import 'package:career_bridge/features/job_seeker/data/repositories/demo_job_seeker_workspace_repository.dart';
import 'package:career_bridge/features/public_portal/data/repositories/demo_public_portal_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'demo apply appears to employer, decision and withdrawal return to seeker locally',
      () async {
    DemoApplicationStore.instance.clear();
    final auth = DemoAuthRepository();
    final seeker = await auth.signIn(
        email: 'jobseeker@careerbridge.demo', password: 'Demo123!');
    final employer = await auth.signIn(
        email: 'employer@careerbridge.demo', password: 'Demo123!');
    final seekers = DemoJobSeekerWorkspaceRepository();
    final employers = DemoEmployerWorkspaceRepository();
    final profile = await seekers.load(
        uid: seeker.uid, name: seeker.name, email: seeker.email);
    final public = await const DemoPublicPortalRepository().load();
    final job = public.jobs.firstWhere((job) =>
        job.companyId == 'demo-novatech-bangladesh' &&
        !profile.applications.any((a) => a.jobId == job.id));
    final application = await seekers.submitApplication(
        uid: seeker.uid,
        job: job,
        coverLetter: 'Demo application for a complete sample hiring workflow.',
        cvProfile: null,
        applicantProfile: profile.profile);
    Future<dynamic> loadEmployer() => employers.load(
        uid: employer.uid,
        companyName: employer.companyName ?? '',
        contactName: employer.name,
        email: employer.email);
    final received = await loadEmployer();
    expect(received.applications.any((dynamic a) => a.id == application.id),
        isTrue);
    await employers.updateApplication(
        application: application, status: ApplicationStatus.shortlisted);
    final updated = await seekers.load(
        uid: seeker.uid, name: seeker.name, email: seeker.email);
    expect(
        updated.applications.firstWhere((a) => a.id == application.id).status,
        ApplicationStatus.shortlisted);
    expect(
        updated.notifications.any((n) =>
            n.applicationId == application.id &&
            n.title.contains('Shortlisted')),
        isTrue);
    await seekers.withdrawApplication(
        updated.applications.firstWhere((a) => a.id == application.id));
    final withdrawn = await loadEmployer();
    expect(
        withdrawn.applications
            .firstWhere((dynamic a) => a.id == application.id)
            .status,
        ApplicationStatus.withdrawn);
    await expectLater(
        employers.updateApplication(
            application: application, status: ApplicationStatus.hired),
        throwsStateError);
    DemoApplicationStore.instance.clear();
  });
}
