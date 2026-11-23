enum EmployerJobStatus {
  draft,
  pending,
  published,
  rejected,
  closed;

  String get firestoreValue => name;

  String get label => switch (this) {
        EmployerJobStatus.draft => 'Draft',
        EmployerJobStatus.pending => 'Pending review',
        EmployerJobStatus.published => 'Published',
        EmployerJobStatus.rejected => 'Needs changes',
        EmployerJobStatus.closed => 'Closed',
      };

  bool get isEditable =>
      this == EmployerJobStatus.draft || this == EmployerJobStatus.rejected;

  bool get isLive => this == EmployerJobStatus.published;

  static EmployerJobStatus fromFirestore(String? value) {
    return EmployerJobStatus.values.firstWhere(
      (status) => status.firestoreValue == value,
      orElse: () => EmployerJobStatus.draft,
    );
  }
}
