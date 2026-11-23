enum UserRole {
  jobSeeker,
  employer,
  admin;

  String get firestoreValue => switch (this) {
        UserRole.jobSeeker => 'jobSeeker',
        UserRole.employer => 'employer',
        UserRole.admin => 'admin',
      };

  String get label => switch (this) {
        UserRole.jobSeeker => 'Job Seeker',
        UserRole.employer => 'Employer',
        UserRole.admin => 'Administrator',
      };

  static UserRole fromFirestore(String value) => switch (value) {
        'jobSeeker' => UserRole.jobSeeker,
        'employer' => UserRole.employer,
        'admin' => UserRole.admin,
        _ => throw ArgumentError.value(value, 'value', 'Unknown user role'),
      };
}
