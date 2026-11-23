import '../../../../core/services/live_streams.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../companies/data/models/company_model.dart';
import '../../../jobs/data/models/job_model.dart';
import '../landing_mock_data.dart';
import '../models/public_platform_settings_model.dart';
import 'public_portal_repository.dart';

class FirebasePublicPortalRepository implements PublicPortalRepository {
  FirebasePublicPortalRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Query<Map<String, dynamic>> get _companies => _firestore
      .collection('companies')
      .where('verificationStatus', isEqualTo: 'approved')
      .where('isActive', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .limit(200);
  Query<Map<String, dynamic>> get _categories => _firestore
      .collection('categories')
      .where('isActive', isEqualTo: true)
      .orderBy('sortOrder');
  Query<Map<String, dynamic>> get _jobs => _firestore
      .collection('jobs')
      .where('status', isEqualTo: 'published')
      .where('isActive', isEqualTo: true)
      .orderBy('publishedAt', descending: true)
      .limit(300);
  DocumentReference<Map<String, dynamic>> get _settings =>
      _firestore.collection('platformSettings').doc('general');

  @override
  Future<PublicPortalSnapshot> load() async =>
      _fromResults(await Future.wait<Object>([
        _companies.get(),
        _categories.get(),
        _settings.get(),
        _jobs.get(),
      ]));

  Stream<PublicPortalSnapshot> watch() => combineLatest([
        _companies.snapshots(),
        _categories.snapshots(),
        _settings.snapshots(),
        _jobs.snapshots(),
      ]).map(_fromResults);

  PublicPortalSnapshot _fromResults(List<Object> initial) {
    final companiesQuery = initial[0] as QuerySnapshot<Map<String, dynamic>>;
    final categoriesQuery = initial[1] as QuerySnapshot<Map<String, dynamic>>;
    final settingsDoc = initial[2] as DocumentSnapshot<Map<String, dynamic>>;

    final categoryById = <String, String>{};
    final categories = <JobCategory>[];
    for (final doc in categoriesQuery.docs) {
      final data = doc.data();
      final name = (data['name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;
      categoryById[doc.id] = name;
      categories.add(
        JobCategory(
          name,
          (data['description'] as String?)?.trim().isNotEmpty == true
              ? (data['description'] as String).trim()
              : 'Browse current $name opportunities.',
          _iconCodePoint((data['iconName'] as String?) ?? ''),
          0,
          id: doc.id,
        ),
      );
    }

    final companyDataById = <String, Map<String, dynamic>>{
      for (final doc in companiesQuery.docs) doc.id: doc.data(),
    };

    final jobsQuery = initial[3] as QuerySnapshot<Map<String, dynamic>>;

    final openingsByCompany = <String, int>{};
    final openingsByCategory = <String, int>{};
    final jobs = <JobModel>[];
    for (final doc in jobsQuery.docs) {
      final data = doc.data();
      final companyId = (data['companyId'] as String?) ?? '';
      final company = companyDataById[companyId];
      if (company == null) continue;

      final rawCategoryId = (data['categoryId'] as String?)?.trim() ?? '';
      final categoryId = rawCategoryId.isEmpty ? 'other' : rawCategoryId;
      final categoryName = categoryById[categoryId] ?? _titleCase(categoryId);
      final rawOpenings = (data['openings'] as num?)?.round() ?? 1;
      final openings =
          rawOpenings < 1 ? 1 : (rawOpenings > 1000 ? 1000 : rawOpenings);
      openingsByCompany.update(
        companyId,
        (value) => value + openings,
        ifAbsent: () => openings,
      );
      openingsByCategory.update(
        categoryId,
        (value) => value + openings,
        ifAbsent: () => openings,
      );

      final publishedAt =
          _readDate(data['publishedAt']) ?? _readDate(data['updatedAt']);
      final deadline = _readDate(data['deadline']);
      final companyName = (company['name'] as String?)?.trim();
      final resolvedCompanyName = companyName == null || companyName.isEmpty
          ? 'Career Bridge Employer'
          : companyName;

      jobs.add(
        JobModel(
          id: doc.id,
          companyId: companyId,
          companyName: resolvedCompanyName,
          title: (data['title'] as String?)?.trim().isNotEmpty == true
              ? (data['title'] as String).trim()
              : 'Untitled opportunity',
          category: categoryName,
          location: (data['location'] as String?)?.trim().isNotEmpty == true
              ? (data['location'] as String).trim()
              : 'Bangladesh',
          workMode: (data['workMode'] as String?) ?? 'On-site',
          employmentType: (data['employmentType'] as String?) ?? 'Full-time',
          experience: (data['experienceLevel'] as String?) ?? 'Not specified',
          salaryLabel: _salaryLabel(
            (data['salaryMin'] as num?)?.round() ?? 0,
            (data['salaryMax'] as num?)?.round() ?? 0,
            (data['salaryPeriod'] as String?) ?? 'month',
          ),
          salaryMin: (data['salaryMin'] as num?)?.round() ?? 0,
          salaryMax: (data['salaryMax'] as num?)?.round() ?? 0,
          salaryPeriod: (data['salaryPeriod'] as String?) ?? 'month',
          postedLabel: _relativeDate(publishedAt),
          deadlineLabel: _dateLabel(deadline),
          openings: openings,
          description: (data['description'] as String?) ?? '',
          responsibilities: _readStrings(data['responsibilities']),
          requirements: _readStrings(data['requirements']),
          benefits: _readStrings(data['benefits']),
          skills: _readStrings(data['skills']),
          isFeatured: data['isFeatured'] as bool? ?? false,
          isVerified: true,
        ),
      );
    }

    final companies = <CompanyModel>[];
    for (final doc in companiesQuery.docs) {
      final data = doc.data();
      final name = (data['name'] as String?)?.trim();
      final resolvedName =
          name == null || name.isEmpty ? 'Career Bridge Employer' : name;
      final industry = (data['industry'] as String?)?.trim();
      final description = (data['description'] as String?)?.trim();
      final website = (data['website'] as String?)?.trim();
      final specialties = _readStrings(data['specialties']);
      companies.add(
        CompanyModel(
          id: doc.id,
          name: resolvedName,
          industry: industry == null || industry.isEmpty ? 'Other' : industry,
          location: (data['address'] as String?)?.trim().isNotEmpty == true
              ? (data['address'] as String).trim()
              : 'Bangladesh',
          size: (data['companySize'] as String?)?.trim().isNotEmpty == true
              ? (data['companySize'] as String).trim()
              : 'Team size not specified',
          founded: (data['founded'] as String?)?.trim().isNotEmpty == true
              ? (data['founded'] as String).trim()
              : 'Not specified',
          description: description == null || description.isEmpty
              ? 'This verified employer has not added a public company description yet.'
              : description,
          specialties: specialties.isEmpty
              ? [industry == null || industry.isEmpty ? 'General' : industry]
              : specialties,
          openings: openingsByCompany[doc.id] ?? 0,
          website: website == null || website.isEmpty ? null : website,
          logoFileId: (data['logoFileId'] as String?) ?? '',
          isVerified: true,
        ),
      );
    }

    final categoriesWithCounts = categories
        .map(
          (category) => JobCategory(
            category.title,
            category.subtitle,
            category.iconCodePoint,
            openingsByCategory[category.id] ?? 0,
            id: category.id,
          ),
        )
        .toList();

    for (final entry in openingsByCategory.entries) {
      if (categoryById.containsKey(entry.key)) continue;
      final title = _titleCase(entry.key);
      categoriesWithCounts.add(
        JobCategory(
          title,
          'Browse current $title opportunities.',
          _iconCodePoint(''),
          entry.value,
          id: entry.key,
        ),
      );
    }
    categoriesWithCounts.sort((a, b) => a.title.compareTo(b.title));

    // Salary insights are derived from published jobs by the controller.
    // The legacy salaryInsights collection is intentionally not queried here.

    final settingsData = settingsDoc.data();
    final settings = settingsData == null
        ? PublicPlatformSettingsModel.defaults
        : PublicPlatformSettingsModel(
            platformName:
                (settingsData['platformName'] as String?) ?? 'Career Bridge',
            supportEmail: (settingsData['supportEmail'] as String?) ??
                'support@careerbridge.edu',
            maintenanceMode: settingsData['maintenanceMode'] as bool? ?? false,
            allowJobSeekerRegistration:
                settingsData['allowJobSeekerRegistration'] as bool? ?? true,
            allowEmployerRegistration:
                settingsData['allowEmployerRegistration'] as bool? ?? true,
          );

    return PublicPortalSnapshot(
      jobs: jobs,
      companies: companies,
      categories: categoriesWithCounts,
      salaryInsights: const [],
      settings: settings,
    );
  }

  static List<String> _readStrings(Object? value) {
    if (value is Iterable) {
      return value.whereType<String>().toList(growable: false);
    }
    return const [];
  }

  static DateTime? _readDate(Object? value) {
    if (value is DateTime) return value;
    try {
      final dynamic dynamicValue = value;
      final converted = dynamicValue?.toDate();
      if (converted is DateTime) return converted;
    } catch (_) {}
    return null;
  }

  static String _relativeDate(DateTime? value) {
    if (value == null) return 'Recently';
    final difference = DateTime.now().difference(value);
    if (difference.inDays <= 0) return 'Today';
    if (difference.inDays == 1) return '1 day ago';
    if (difference.inDays < 30) return '${difference.inDays} days ago';
    final months = (difference.inDays / 30).floor();
    return months == 1 ? '1 month ago' : '$months months ago';
  }

  static String _dateLabel(DateTime? value) {
    if (value == null) return 'Open until filled';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }

  static String _salaryLabel(int minimum, int maximum, String period) {
    if (minimum <= 0 && maximum <= 0) return 'Salary negotiable';
    String compact(int value) =>
        value >= 1000 && value % 1000 == 0 ? '${value ~/ 1000}k' : '$value';
    if (minimum <= 0) return 'Up to ৳${compact(maximum)} / $period';
    if (maximum <= 0) return 'From ৳${compact(minimum)} / $period';
    return '৳${compact(minimum)}–${compact(maximum)} / $period';
  }

  static String _titleCase(String value) {
    final normalized = value.replaceAll(RegExp(r'[-_]'), ' ').trim();
    if (normalized.isEmpty) return 'Other';
    return normalized
        .split(RegExp(r'\s+'))
        .map((part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  static int _iconCodePoint(String iconName) => switch (iconName) {
        'memory' => 0xe30a,
        'palette' => 0xe40a,
        'business_center' => 0xe0af,
        'campaign' => 0xe3b7,
        'school' => 0xe80c,
        'support_agent' => 0xf0e2,
        'account_balance' => 0xe84f,
        'engineering' => 0xea3d,
        _ => 0xe8f9,
      };
}
