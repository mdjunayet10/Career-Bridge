import 'package:career_bridge/core/enums/user_role.dart';
import 'package:career_bridge/core/enums/employer_job_status.dart';
import 'package:career_bridge/core/errors/auth_failure.dart';
import 'package:career_bridge/features/auth/data/repositories/demo_auth_repository.dart';
import 'package:career_bridge/features/employer/data/repositories/demo_employer_workspace_repository.dart';
import 'package:career_bridge/features/job_seeker/data/repositories/demo_job_seeker_workspace_repository.dart';
import 'package:career_bridge/features/public_portal/data/repositories/demo_public_portal_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const seekerEmails = [
  'jobseeker@careerbridge.demo',
  'designer@careerbridge.demo',
  'analyst@careerbridge.demo',
  'accountant@careerbridge.demo',
  'marketer@careerbridge.demo',
  'civil@careerbridge.demo',
  'support@careerbridge.demo',
  'hr@careerbridge.demo',
  'writer@careerbridge.demo',
  'qa@careerbridge.demo',
  'operations@careerbridge.demo',
  'energy@careerbridge.demo',
  'backend@careerbridge.demo',
  'teacher@careerbridge.demo',
  'nurse@careerbridge.demo',
  'researcher@careerbridge.demo',
  'sales@careerbridge.demo',
  'graphic@careerbridge.demo',
  'food@careerbridge.demo',
  'electrical@careerbridge.demo',
];

const employerEmails = [
  'employer@careerbridge.demo',
  'pending@careerbridge.demo',
  'bengal@careerbridge.demo',
  'summit@careerbridge.demo',
  'greengrid@careerbridge.demo',
  'carenest@careerbridge.demo',
  'pixel@careerbridge.demo',
  'ledger@careerbridge.demo',
  'story@careerbridge.demo',
  'people@careerbridge.demo',
  'build@careerbridge.demo',
  'harbor@careerbridge.demo',
];

void main() {
  test('all 20 seeker accounts open distinct fictional career workspaces',
      () async {
    final auth = DemoAuthRepository();
    final repository = DemoJobSeekerWorkspaceRepository();
    final headlines = <String>{};
    final owners = <String>{};
    for (final email in seekerEmails) {
      final user = await auth.signIn(email: email, password: 'Demo123!');
      expect(user.role, UserRole.jobSeeker);
      final workspace = await repository.load(
          uid: user.uid, name: user.name, email: user.email);
      owners.add(workspace.profile.uid);
      headlines.add(workspace.profile.headline);
      expect(workspace.profile.about.toLowerCase(), contains('demo'));
      expect(workspace.applications, isNotEmpty);
      expect(workspace.applications.every((a) => a.applicantUid == user.uid),
          isTrue);
      expect(workspace.cvProfile.ownerUid, user.uid);
      expect(workspace.cvProfile.professionalSummary.toLowerCase(),
          contains('demo'));
    }
    expect(owners, hasLength(20));
    expect(headlines, hasLength(20));
  });

  test('all 12 employer accounts own their sample company and jobs', () async {
    final auth = DemoAuthRepository();
    final repository = DemoEmployerWorkspaceRepository();
    final public = await const DemoPublicPortalRepository().load();
    final companies = <String>{};
    for (final email in employerEmails) {
      final user = await auth.signIn(email: email, password: 'Demo123!');
      expect(user.role, UserRole.employer);
      final workspace = await repository.load(
          uid: user.uid,
          companyName: user.companyName!,
          contactName: user.name,
          email: user.email);
      companies.add(workspace.company.id);
      expect(workspace.company.name, contains('(Demo)'));
      expect(workspace.company.ownerUid, user.uid);
      expect(workspace.jobs, isNotEmpty);
      expect(
          workspace.jobs.every((j) =>
              j.companyId == workspace.company.id && j.employerUid == user.uid),
          isTrue);
      expect(
          workspace.applications.every((a) =>
              a.companyId == workspace.company.id &&
              workspace.jobs.any((j) => j.id == a.jobId)),
          isTrue);
      expect(public.companies.any((c) => c.id == workspace.company.id), isTrue);
      for (final job in workspace.jobs
          .where((j) => j.status == EmployerJobStatus.published)) {
        expect(
            public.jobs.any(
                (j) => j.id == job.id && j.companyId == workspace.company.id),
            isTrue,
            reason:
                '${user.email}: published job ${job.id} belongs to its demo company');
      }
    }
    expect(companies, hasLength(12));
  });

  test('removed admin credentials cannot create a demo session', () async {
    await expectLater(
        DemoAuthRepository()
            .signIn(email: 'admin@careerbridge.demo', password: 'Admin123!'),
        throwsA(isA<AuthFailure>()));
  });

  test('unlisted users start empty and demo changes stay with their owner',
      () async {
    final repository = DemoJobSeekerWorkspaceRepository();
    final first = await repository.load(
        uid: 'demo-job-seeker', name: 'Ayan (Demo)', email: seekerEmails.first);
    await repository
        .saveProfile(first.profile.copyWith(about: 'Changed locally'));
    final second = await repository.load(
        uid: 'demo-seeker-designer',
        name: 'Mira (Demo)',
        email: seekerEmails[1]);
    final real = await repository.load(
        uid: 'real-user', name: 'Real user', email: 'person@example.com');
    expect(second.profile.about, isNot('Changed locally'));
    expect(real.applications, isEmpty);
    expect(real.savedJobIds, isEmpty);
    expect(real.profile.skills, isEmpty);
    expect(real.cvProfile.projects, isEmpty);
  });
}
