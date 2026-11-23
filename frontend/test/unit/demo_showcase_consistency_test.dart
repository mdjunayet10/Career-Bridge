import 'package:career_bridge/core/enums/employer_job_status.dart';
import 'package:career_bridge/core/enums/user_role.dart';
import 'package:career_bridge/features/auth/data/demo_account_catalog.dart';
import 'package:career_bridge/features/admin/data/repositories/demo_admin_workspace_repository.dart';
import 'package:career_bridge/features/employer/data/repositories/demo_employer_workspace_repository.dart';
import 'package:career_bridge/features/public_portal/data/repositories/demo_public_portal_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fictional records share the same company, owner and job identities', () async {
    final public = await const DemoPublicPortalRepository().load();
    final admin = await DemoAdminWorkspaceRepository().load();
    final seekers = DemoAccountCatalog.forRole(UserRole.jobSeeker);
    final employers = DemoAccountCatalog.forRole(UserRole.employer);
    expect(seekers, hasLength(20));
    expect(employers, hasLength(12));
    expect(public.companies, hasLength(12));
    expect(public.jobs, hasLength(20));
    expect(admin.users, hasLength(32));
    expect(admin.companies, hasLength(12));
    expect(admin.jobs, hasLength(38));
    expect(admin.jobs.where((j) => j.status == EmployerJobStatus.pending),
        hasLength(14));
    expect(admin.jobs.where((j) => j.status == EmployerJobStatus.draft),
        hasLength(3));
    expect(admin.jobs.where((j) => j.status == EmployerJobStatus.closed),
        hasLength(1));
    expect(admin.jobs.where((j) => j.status == EmployerJobStatus.published),
        hasLength(20));

    final publicCompanyIds = public.companies.map((c) => c.id).toSet();
    final adminCompanyIds = admin.companies.map((c) => c.companyId).toSet();
    expect(adminCompanyIds, publicCompanyIds);
    final publicJobIds = public.jobs.map((j) => j.id).toSet();
    final adminPublishedJobIds = admin.jobs
        .where((j) => j.status == EmployerJobStatus.published)
        .map((j) => j.id)
        .toSet();
    expect(adminPublishedJobIds, publicJobIds);
    expect(public.jobs.every((j) => publicCompanyIds.contains(j.companyId)), isTrue);
    expect(public.jobs.every((j) => j.isSample && !j.isVerified), isTrue);
    expect(public.jobs.every((j) => j.companyId != 'demo-orbit-labs'), isTrue);
    expect(admin.jobs.any((j) => j.companyId == 'demo-orbit-labs' &&
          j.status == EmployerJobStatus.pending), isTrue);

    final repository = DemoEmployerWorkspaceRepository();
    for (final employer in employers) {
      final workspace = await repository.load(
          uid: employer.uid, companyName: employer.companyName,
          contactName: employer.name, email: employer.email);
      final employerPublished = workspace.jobs
          .where((j) => j.status == EmployerJobStatus.published)
          .map((j) => j.id).toSet();
      expect(employerPublished,
          admin.jobs.where((j) => j.employerUid == employer.uid &&
            j.status == EmployerJobStatus.published).map((j) => j.id).toSet());
      expect(workspace.jobs.every((j) => admin.jobs.any((a) => a.id == j.id &&
          a.companyId == j.companyId && a.status == j.status)), isTrue);
    }
  });
}
