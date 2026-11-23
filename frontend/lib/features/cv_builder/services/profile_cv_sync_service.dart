import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../job_seeker/data/models/job_seeker_profile_model.dart';
import '../data/models/cv_profile_model.dart';

abstract final class ProfileCvSyncService {
  static CvProfileModel sync({
    required JobSeekerProfileModel profile,
    required CvProfileModel currentCv,
    JobSeekerProfileModel? previousProfile,
    String? photoDataUrl,
  }) {
    final previousAutoEducation = previousProfile == null
        ? const <CvEducationItem>[]
        : _educationFrom(previousProfile.educationSummary);
    final newAutoEducation = _educationFrom(profile.educationSummary);

    final shouldSyncEducation = currentCv.education.isEmpty ||
        _sameEducation(currentCv.education, previousAutoEducation);

    return normalizeDetails(currentCv.copyWith(
      fullName: profile.fullName,
      email: profile.email,
      phone: profile.phone,
      location: profile.location,
      professionalSummary: profile.about,
      skills: profile.skills,
      education: profile.hasCvDetails
          ? profile.education
          : shouldSyncEducation
              ? newAutoEducation
              : currentCv.education,
      technicalLanguages: profile.hasCvDetails
          ? profile.technicalLanguages
          : currentCv.technicalLanguages,
      frameworks:
          profile.hasCvDetails ? profile.frameworks : currentCv.frameworks,
      toolsAndPlatforms: profile.hasCvDetails
          ? profile.toolsAndPlatforms
          : currentCv.toolsAndPlatforms,
      projects: profile.hasCvDetails ? profile.projects : currentCv.projects,
      experience: profile.hasCvExperience || profile.experience.isNotEmpty
          ? profile.experience
          : currentCv.experience,
      achievements:
          profile.hasCvDetails ? profile.achievements : currentCv.achievements,
      references:
          profile.hasCvDetails ? profile.references : currentCv.references,
      linkedInUrl: profile.linkedInUrl,
      portfolioUrl: profile.portfolioUrl,
      photoDataUrl: photoDataUrl,
      updatedAt: DateTime.now(),
    ));
  }

  /// Remove unused editor rows while keeping explicit empty sections empty.
  static CvProfileModel normalizeDetails(CvProfileModel cv) => cv.copyWith(
        technicalLanguages: _cleanStrings(cv.technicalLanguages),
        frameworks: _cleanStrings(cv.frameworks),
        toolsAndPlatforms: _cleanStrings(cv.toolsAndPlatforms),
        education: [
          for (final item in cv.education)
            if ([
              item.degree,
              item.institution,
              item.period,
              item.location,
              item.result,
              item.details,
              item.institutionUrl
            ].any((value) => value.trim().isNotEmpty))
              CvEducationItem(
                degree: item.degree.trim(),
                institution: item.institution.trim(),
                period: item.period.trim(),
                location: item.location.trim(),
                result: item.result.trim(),
                details: item.details.trim(),
                institutionUrl: item.institutionUrl.trim(),
              ),
        ],
        projects: [
          for (final item in cv.projects)
            if ([item.name, item.description, item.link, item.toolsAndMethods]
                .any((value) => value.trim().isNotEmpty))
              CvProjectItem(
                  name: item.name.trim(),
                  description: item.description.trim(),
                  link: item.link.trim(),
                  toolsAndMethods: item.toolsAndMethods.trim()),
        ],
        experience: [
          for (final item in cv.experience)
            if ([item.role, item.company, item.period, item.description]
                .any((value) => value.trim().isNotEmpty))
              CvExperienceItem(
                role: item.role.trim(),
                company: item.company.trim(),
                period: item.period.trim(),
                description: item.description.trim(),
              ),
        ],
        achievements: [
          for (final item in cv.achievements)
            if ([item.title, item.qualifier, item.date, item.description]
                .any((value) => value.trim().isNotEmpty))
              CvAchievementItem(
                  title: item.title.trim(),
                  qualifier: item.qualifier.trim(),
                  date: item.date.trim(),
                  description: item.description.trim()),
        ],
        references: [
          for (final item in cv.references)
            if ([
              item.name,
              item.designation,
              item.organization,
              item.email,
              item.phone
            ].any((value) => value.trim().isNotEmpty))
              CvReferenceItem(
                  name: item.name.trim(),
                  designation: item.designation.trim(),
                  organization: item.organization.trim(),
                  email: item.email.trim(),
                  phone: item.phone.trim()),
        ],
      );

  static List<String> _cleanStrings(List<String> values) => values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList(growable: false);

  /// A small export thumbnail keeps CV documents below Firestore size limits.
  static String photoThumbnailDataUrl(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('The profile photo could not be decoded.');
    }
    var image = img.bakeOrientation(decoded);
    if (image.width > 320 || image.height > 320) {
      image = img.copyResize(
        image,
        width: image.width >= image.height ? 320 : null,
        height: image.height > image.width ? 320 : null,
        interpolation: img.Interpolation.average,
      );
    }
    return 'data:image/jpeg;base64,${base64Encode(img.encodeJpg(image, quality: 88))}';
  }

  static List<CvEducationItem> _educationFrom(String summary) {
    final value = summary.trim();
    if (value.isEmpty) return const [];

    String degree = value;
    String institution = '';
    String period = '';

    final periodMatch = RegExp(r'\(([^)]+)\)\s*$').firstMatch(value);
    if (periodMatch != null) {
      period = periodMatch.group(1)?.trim() ?? '';
      degree = value.substring(0, periodMatch.start).trim();
    }

    final atIndex = degree.toLowerCase().lastIndexOf(' at ');
    if (atIndex > 0) {
      institution = degree.substring(atIndex + 4).trim();
      degree = degree.substring(0, atIndex).trim();
    } else {
      final commaIndex = degree.lastIndexOf(',');
      if (commaIndex > 0 && commaIndex < degree.length - 1) {
        institution = degree.substring(commaIndex + 1).trim();
        degree = degree.substring(0, commaIndex).trim();
      }
    }

    return [
      CvEducationItem(
        degree: degree,
        institution: institution,
        period: period,
      ),
    ];
  }

  static bool _sameEducation(
    List<CvEducationItem> current,
    List<CvEducationItem> previousAuto,
  ) {
    if (current.length != previousAuto.length) return false;
    for (var index = 0; index < current.length; index++) {
      final a = current[index];
      final b = previousAuto[index];
      if (a.degree != b.degree ||
          a.institution != b.institution ||
          a.period != b.period ||
          a.location != b.location ||
          a.result != b.result ||
          a.details != b.details ||
          a.institutionUrl != b.institutionUrl) {
        return false;
      }
    }
    return true;
  }
}
