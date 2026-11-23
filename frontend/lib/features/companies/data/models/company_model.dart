class CompanyModel {
  const CompanyModel({
    required this.id,
    required this.name,
    required this.industry,
    required this.location,
    required this.size,
    required this.founded,
    required this.description,
    required this.specialties,
    required this.openings,
    this.website,
    this.logoFileId = '',
    this.isVerified = true,
  });

  final String id;
  final String name;
  final String industry;
  final String location;
  final String size;
  final String founded;
  final String description;
  final List<String> specialties;
  final int openings;
  final String? website;
  final String logoFileId;
  final bool isVerified;

  bool matchesText(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    final text =
        [name, industry, location, ...specialties].join(' ').toLowerCase();
    return text.contains(normalized);
  }
}
