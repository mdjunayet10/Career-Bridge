enum ApplicationStatus {
  applied,
  reviewed,
  shortlisted,
  interview,
  hired,
  rejected,
  withdrawn;

  String get firestoreValue => name;

  String get label => switch (this) {
        ApplicationStatus.applied => 'Applied',
        ApplicationStatus.reviewed => 'Under review',
        ApplicationStatus.shortlisted => 'Shortlisted',
        ApplicationStatus.interview => 'Interview',
        ApplicationStatus.hired => 'Hired',
        ApplicationStatus.rejected => 'Not selected',
        ApplicationStatus.withdrawn => 'Withdrawn',
      };

  int get progressStep => switch (this) {
        ApplicationStatus.applied => 1,
        ApplicationStatus.reviewed => 2,
        ApplicationStatus.shortlisted => 3,
        ApplicationStatus.interview => 4,
        ApplicationStatus.hired => 5,
        ApplicationStatus.rejected => 5,
        ApplicationStatus.withdrawn => 1,
      };

  bool get isTerminal =>
      this == ApplicationStatus.hired ||
      this == ApplicationStatus.rejected ||
      this == ApplicationStatus.withdrawn;

  static ApplicationStatus fromFirestore(String? value) {
    return ApplicationStatus.values.firstWhere(
      (status) => status.firestoreValue == value,
      orElse: () => ApplicationStatus.applied,
    );
  }
}
