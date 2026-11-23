import '../../cv_builder/data/models/cv_profile_model.dart';
import '../../job_seeker/data/models/job_seeker_profile_model.dart';
import '../data/models/job_model.dart';

class JobRecommendation {
  const JobRecommendation({
    required this.job,
    required this.score,
    required this.reasons,
  });

  final JobModel job;
  final int score;
  final List<String> reasons;
}

abstract final class JobRecommendationService {
  static List<JobRecommendation> rankJobs({
    required List<JobModel> jobs,
    JobSeekerProfileModel? profile,
    CvProfileModel? cvProfile,
  }) {
    final ranked = [
      for (final job in jobs)
        _scoreJob(job: job, profile: profile, cvProfile: cvProfile),
    ];

    ranked.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      if (a.job.isFeatured != b.job.isFeatured) {
        return a.job.isFeatured ? -1 : 1;
      }
      return a.job.title.compareTo(b.job.title);
    });
    return ranked;
  }

  static JobRecommendation recommendationFor({
    required JobModel job,
    JobSeekerProfileModel? profile,
    CvProfileModel? cvProfile,
  }) {
    return _scoreJob(job: job, profile: profile, cvProfile: cvProfile);
  }

  static JobRecommendation _scoreJob({
    required JobModel job,
    JobSeekerProfileModel? profile,
    CvProfileModel? cvProfile,
  }) {
    if (profile == null && cvProfile == null) {
      return JobRecommendation(
        job: job,
        score: job.isFeatured ? 5 : 0,
        reasons: const [],
      );
    }

    var score = 0.0;
    final reasons = <String>[];

    final cvSkills = <String>{
      ...?cvProfile?.skills,
      ...?profile?.skills,
      ...?cvProfile?.technicalLanguages,
      ...?cvProfile?.frameworks,
      ...?cvProfile?.toolsAndPlatforms,
      ...?profile?.technicalLanguages,
      ...?profile?.frameworks,
      ...?profile?.toolsAndPlatforms,
    };
    final jobSkillTokens = _normalizedSet(job.skills);
    final candidateSkillTokens = _normalizedSet(cvSkills);
    final skillMatches = candidateSkillTokens.intersection(jobSkillTokens);
    if (jobSkillTokens.isNotEmpty && skillMatches.isNotEmpty) {
      final ratio = skillMatches.length / jobSkillTokens.length;
      score += 48 * ratio.clamp(0.0, 1.0).toDouble();
      reasons.add(
          '${skillMatches.length} skill match${skillMatches.length == 1 ? '' : 'es'}');
    }

    final roleSignals = <String>[
      ...?profile?.preferredRoles,
      if ((profile?.headline ?? '').trim().isNotEmpty) profile!.headline,
      if ((cvProfile?.professionalSummary ?? '').trim().isNotEmpty)
        cvProfile!.professionalSummary,
    ];
    final roleTokens = _tokens(roleSignals.join(' '));
    final jobRoleTokens = _tokens('${job.title} ${job.category}');
    final roleOverlap = roleTokens.intersection(jobRoleTokens);
    if (roleOverlap.isNotEmpty) {
      final ratio = roleOverlap.length / jobRoleTokens.length.clamp(1, 999);
      score += 22 * ratio.clamp(0.0, 1.0).toDouble();
      reasons.add('role relevance');
    }

    final preferredRoles = profile?.preferredRoles ?? const <String>[];
    if (preferredRoles.any((role) => _containsEither(job.title, role))) {
      score += 12;
      if (!reasons.contains('role relevance')) reasons.add('preferred role');
    }

    final preferredLocations = profile?.preferredLocations ?? const <String>[];
    final profileLocation = profile?.location ?? '';
    final locationMatches = preferredLocations.any(
          (location) => _containsEither(job.location, location),
        ) ||
        (profileLocation.isNotEmpty &&
            _containsEither(job.location, profileLocation));
    if (locationMatches) {
      score += 9;
      reasons.add('preferred location');
    }

    final preferredModes = profile?.workModes ?? const <String>[];
    if (preferredModes.any((mode) => _containsEither(job.workMode, mode))) {
      score += 7;
      reasons.add('${job.workMode.toLowerCase()} fit');
    }

    final backgroundText = [
      profile?.about ?? '',
      profile?.educationSummary ?? '',
      cvProfile?.professionalSummary ?? '',
      ...(cvProfile?.education ?? const <CvEducationItem>[]).map(
        (item) => '${item.degree} ${item.institution}',
      ),
      ...(cvProfile?.experience ?? const <CvExperienceItem>[]).map(
        (item) => '${item.role} ${item.description}',
      ),
      ...(cvProfile?.projects ?? const <CvProjectItem>[]).map(
        (item) => '${item.name} ${item.description}',
      ),
      ...(cvProfile?.achievements ?? const <CvAchievementItem>[]).map(
        (item) => '${item.title} ${item.qualifier} ${item.description}',
      ),
      ...(profile?.education ?? const <CvEducationItem>[]).map(
        (item) => '${item.degree} ${item.institution} ${item.details}',
      ),
      ...(profile?.projects ?? const <CvProjectItem>[]).map(
        (item) => '${item.name} ${item.description}',
      ),
      ...(profile?.experience ?? const <CvExperienceItem>[]).map(
        (item) => '${item.role} ${item.company} ${item.description}',
      ),
      ...(profile?.achievements ?? const <CvAchievementItem>[]).map(
        (item) => '${item.title} ${item.qualifier} ${item.description}',
      ),
    ].join(' ');
    final backgroundTokens = _tokens(backgroundText);
    final requirementTokens = _tokens(
      '${job.description} ${job.requirements.join(' ')} ${job.responsibilities.join(' ')}',
    );
    final backgroundOverlap = backgroundTokens.intersection(requirementTokens);
    if (backgroundOverlap.length >= 2) {
      score += (backgroundOverlap.length * 0.7).clamp(0.0, 7.0).toDouble();
      reasons.add('CV content alignment');
    }

    return JobRecommendation(
      job: job,
      score: score.round().clamp(0, 100).toInt(),
      reasons: reasons.take(3).toList(growable: false),
    );
  }

  static Set<String> _normalizedSet(Iterable<String> values) => values
      .map((value) => value.trim().toLowerCase())
      .where((value) => value.isNotEmpty)
      .toSet();

  static Set<String> _tokens(String value) {
    const stopWords = <String>{
      'and',
      'the',
      'with',
      'for',
      'from',
      'that',
      'this',
      'your',
      'you',
      'our',
      'are',
      'will',
      'into',
      'work',
      'years',
      'year',
    };
    return value
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9+#.]+'))
        .map((token) => token.trim())
        .where((token) => token.length >= 2 && !stopWords.contains(token))
        .toSet();
  }

  static bool _containsEither(String a, String b) {
    final first = a.trim().toLowerCase();
    final second = b.trim().toLowerCase();
    if (first.isEmpty || second.isEmpty) return false;
    return first.contains(second) || second.contains(first);
  }
}
