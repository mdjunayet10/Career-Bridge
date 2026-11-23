import 'package:career_bridge/core/enums/application_status.dart';
import 'package:career_bridge/features/applications/data/models/application_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('application keeps an understandable job snapshot after listing removal',
      () {
    final application = ApplicationModel(
      id: 'application-1',
      jobId: 'job-1',
      applicantUid: 'candidate-1',
      status: ApplicationStatus.shortlisted,
      coverLetter:
          'A sufficiently detailed cover letter for the sample application.',
      jobTitle: 'Flutter Developer',
      companyId: 'novatech-bangladesh',
      companyName: 'NovaTech Bangladesh',
      jobLocation: 'Dhaka',
      jobEmploymentType: 'Full-time',
      jobSalaryLabel: '৳45k–70k / month',
      createdAt: DateTime(2026, 8, 6),
      updatedAt: DateTime(2026, 8, 6),
    );

    final snapshot = application.toJobSnapshot();

    expect(snapshot.id, 'job-1');
    expect(snapshot.title, 'Flutter Developer');
    expect(snapshot.companyId, 'novatech-bangladesh');
    expect(snapshot.companyName, 'NovaTech Bangladesh');
    expect(snapshot.location, 'Dhaka');
    expect(snapshot.salaryLabel, '৳45k–70k / month');
    expect(snapshot.deadlineLabel, 'Listing no longer public');
  });
}
