import 'dart:convert';
import 'package:career_bridge/core/services/cv_import_service.dart';
import 'package:career_bridge/features/cv_builder/data/models/cv_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final current = CvProfileModel(
      ownerUid: 'owner',
      fullName: 'Old',
      email: 'owner@example.com',
      updatedAt: DateTime(2026),
      experience: const [
        CvExperienceItem(
            role: 'Existing role',
            company: 'Company',
            period: '2025',
            description: 'Confirmed work')
      ]);
  final input = jsonEncode({
    'schemaVersion': 1,
    'expectedEmail': 'owner@example.com',
    'cv': {
      'personal': {'fullName': 'Updated'},
      'showPhoto': false
    }
  });
  test('CV import keeps account identity and unprovided fields', () {
    final cv = CvImportService.parse(input,
        current: current, authenticatedEmail: 'owner@example.com');
    expect(cv.fullName, 'Updated');
    expect(cv.email, current.email);
    expect(cv.ownerUid, 'owner');
    expect(cv.experience.single.role, 'Existing role');
  });
  test('CV import rejects another account and malformed documents', () {
    expect(
        () => CvImportService.parse(input,
            current: current, authenticatedEmail: 'other@example.com'),
        throwsFormatException);
    expect(
        () => CvImportService.parse('{}',
            current: current, authenticatedEmail: 'owner@example.com'),
        throwsFormatException);
  });
}
