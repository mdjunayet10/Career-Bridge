enum EmployerVerificationStatus {
  notRequired,
  pending,
  approved,
  rejected;

  String get firestoreValue => switch (this) {
        EmployerVerificationStatus.notRequired => 'notRequired',
        EmployerVerificationStatus.pending => 'pending',
        EmployerVerificationStatus.approved => 'approved',
        EmployerVerificationStatus.rejected => 'rejected',
      };

  static EmployerVerificationStatus fromFirestore(String? value) =>
      switch (value) {
        'pending' => EmployerVerificationStatus.pending,
        'approved' => EmployerVerificationStatus.approved,
        'rejected' => EmployerVerificationStatus.rejected,
        _ => EmployerVerificationStatus.notRequired,
      };
}
