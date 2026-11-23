class JobCategory {
  const JobCategory(
    this.title,
    this.subtitle,
    this.iconCodePoint,
    this.openings, {
    this.id = '',
  });

  final String id;
  final String title;
  final String subtitle;
  final int iconCodePoint;
  final int openings;
}

abstract final class LandingMockData {
  static const categories = [
    JobCategory('Technology', 'Software, data & IT', 0xe30a, 184),
    JobCategory('Design', 'Product, graphics & UX', 0xe40a, 76),
    JobCategory('Business', 'Operations & management', 0xe0af, 129),
    JobCategory('Marketing', 'Growth, content & sales', 0xe3b7, 102),
    JobCategory('Finance', 'Accounts, banking & audit', 0xe227, 88),
    JobCategory('Engineering', 'Civil, EEE & mechanical', 0xe869, 114),
  ];
}
