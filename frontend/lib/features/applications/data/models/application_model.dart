import '../../../../core/enums/application_status.dart';
import '../../../jobs/data/models/job_model.dart';

class ApplicationModel {
  const ApplicationModel({
    required this.id,
    required this.jobId,
    required this.applicantUid,
    required this.status,
    required this.coverLetter,
    required this.createdAt,
    required this.updatedAt,
    this.cvProfileId,
    this.cvFileId,
    this.employerNote,
    this.interviewAt,
    this.applicantName = '',
    this.applicantEmail = '',
    this.applicantHeadline = '',
    this.applicantLocation = '',
    this.applicantExperienceYears = 0,
    this.applicantSkills = const [],
    this.jobTitle = '',
    this.companyId = '',
    this.companyName = '',
    this.jobLocation = '',
    this.jobEmploymentType = '',
    this.jobSalaryLabel = '',
  });

  final String id;
  final String jobId;
  final String applicantUid;
  final ApplicationStatus status;
  final String coverLetter;
  final String? cvProfileId;
  final String? cvFileId;
  final String? employerNote;
  final DateTime? interviewAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // A privacy-conscious candidate snapshot captured when the application is
  // submitted. Employers can read the application they own without receiving
  // unrestricted access to the applicant's private user/profile documents.
  final String applicantName;
  final String applicantEmail;
  final String applicantHeadline;
  final String applicantLocation;
  final int applicantExperienceYears;
  final List<String> applicantSkills;

  // Immutable job snapshot keeps application history understandable even if
  // the original public listing is later closed or suspended.
  final String jobTitle;
  final String companyId;
  final String companyName;
  final String jobLocation;
  final String jobEmploymentType;
  final String jobSalaryLabel;

  bool get canWithdraw => !status.isTerminal;

  JobModel toJobSnapshot() {
    final resolvedCompany = companyName.trim().isEmpty
        ? 'Career Bridge Employer'
        : companyName.trim();
    return JobModel(
      id: jobId,
      companyId: companyId.trim(),
      companyName: resolvedCompany,
      title: jobTitle.trim().isEmpty ? 'Previous opportunity' : jobTitle.trim(),
      category: 'Application history',
      location: jobLocation.trim().isEmpty ? 'Bangladesh' : jobLocation.trim(),
      workMode: '',
      employmentType: jobEmploymentType.trim().isEmpty
          ? 'Not specified'
          : jobEmploymentType.trim(),
      experience: 'Not available',
      salaryLabel: jobSalaryLabel.trim().isEmpty
          ? 'Salary unavailable'
          : jobSalaryLabel.trim(),
      salaryMax: 0,
      postedLabel: 'Previously published',
      deadlineLabel: 'Listing no longer public',
      openings: 1,
      description: '',
      responsibilities: const [],
      requirements: const [],
      benefits: const [],
      skills: const [],
      isFeatured: false,
      isVerified: true,
    );
  }

  ApplicationModel copyWith({
    ApplicationStatus? status,
    String? employerNote,
    DateTime? interviewAt,
    DateTime? updatedAt,
    bool clearEmployerNote = false,
    bool clearInterviewAt = false,
  }) {
    return ApplicationModel(
      id: id,
      jobId: jobId,
      applicantUid: applicantUid,
      status: status ?? this.status,
      coverLetter: coverLetter,
      cvProfileId: cvProfileId,
      cvFileId: cvFileId,
      employerNote:
          clearEmployerNote ? null : (employerNote ?? this.employerNote),
      interviewAt: clearInterviewAt ? null : (interviewAt ?? this.interviewAt),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      applicantName: applicantName,
      applicantEmail: applicantEmail,
      applicantHeadline: applicantHeadline,
      applicantLocation: applicantLocation,
      applicantExperienceYears: applicantExperienceYears,
      applicantSkills: applicantSkills,
      jobTitle: jobTitle,
      companyId: companyId,
      companyName: companyName,
      jobLocation: jobLocation,
      jobEmploymentType: jobEmploymentType,
      jobSalaryLabel: jobSalaryLabel,
    );
  }

  Map<String, Object?> toFirestore() => {
        'jobId': jobId,
        'applicantUid': applicantUid,
        'status': status.firestoreValue,
        'coverLetter': coverLetter,
        'cvProfileId': cvProfileId,
        'cvFileId': cvFileId,
        'employerNote': employerNote,
        'interviewAt': interviewAt,
        'applicantName': applicantName,
        'applicantEmail': applicantEmail,
        'applicantHeadline': applicantHeadline,
        'applicantLocation': applicantLocation,
        'applicantExperienceYears': applicantExperienceYears,
        'applicantSkills': applicantSkills,
        'jobTitle': jobTitle,
        'companyId': companyId,
        'companyName': companyName,
        'jobLocation': jobLocation,
        'jobEmploymentType': jobEmploymentType,
        'jobSalaryLabel': jobSalaryLabel,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory ApplicationModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ApplicationModel(
      id: id,
      jobId: (data['jobId'] as String?) ?? '',
      applicantUid: (data['applicantUid'] as String?) ?? '',
      status: ApplicationStatus.fromFirestore(data['status'] as String?),
      coverLetter: (data['coverLetter'] as String?) ?? '',
      cvProfileId: data['cvProfileId'] as String?,
      cvFileId: data['cvFileId'] as String?,
      employerNote: data['employerNote'] as String?,
      interviewAt: _readNullableDate(data['interviewAt']),
      applicantName:
          (data['applicantName'] as String?) ?? 'Career Bridge candidate',
      applicantEmail: (data['applicantEmail'] as String?) ?? '',
      applicantHeadline: (data['applicantHeadline'] as String?) ?? '',
      applicantLocation: (data['applicantLocation'] as String?) ?? '',
      applicantExperienceYears:
          (data['applicantExperienceYears'] as num?)?.round() ?? 0,
      applicantSkills: _readStrings(data['applicantSkills']),
      jobTitle: (data['jobTitle'] as String?) ?? '',
      companyId: (data['companyId'] as String?) ?? '',
      companyName: (data['companyName'] as String?) ?? '',
      jobLocation: (data['jobLocation'] as String?) ?? '',
      jobEmploymentType: (data['jobEmploymentType'] as String?) ?? '',
      jobSalaryLabel: (data['jobSalaryLabel'] as String?) ?? '',
      createdAt: _readDate(data['createdAt']),
      updatedAt: _readDate(data['updatedAt']),
    );
  }

  static List<String> _readStrings(Object? value) {
    if (value is Iterable) {
      return value.whereType<String>().toList(growable: false);
    }
    return const [];
  }

  static DateTime _readDate(Object? value) =>
      _readNullableDate(value) ?? DateTime.now();

  static DateTime? _readNullableDate(Object? value) {
    if (value is DateTime) return value;
    try {
      final dynamic dynamicValue = value;
      final converted = dynamicValue?.toDate();
      if (converted is DateTime) return converted;
    } catch (_) {}
    return null;
  }
}
