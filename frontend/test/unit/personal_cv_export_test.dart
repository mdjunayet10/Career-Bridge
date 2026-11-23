import 'dart:convert';
import 'dart:io';
import 'package:career_bridge/core/services/cv_import_service.dart';
import 'package:career_bridge/core/services/cv_pdf_service.dart';
import 'package:career_bridge/features/cv_builder/data/models/cv_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final input = Platform.environment['PERSONAL_CV_INPUT'];
  test('private supplied profile exports to one A4 page', () async {
    final data = File(input!).readAsStringSync();
    final email = (jsonDecode(data) as Map)['expectedEmail'] as String;
    final cv = CvImportService.parse(data,
        current: CvProfileModel(
            ownerUid: 'local-preview',
            fullName: '',
            email: email,
            updatedAt: DateTime(2026)),
        authenticatedEmail: email);
    final bytes = await CvPdfService.instance.buildPdf(cv);
    expect(
        RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes)).length, 1);
    expect(bytes.length, lessThan(2 * 1024 * 1024));
    final destination = Platform.environment['CV_PDF_QA_DIR'];
    if (destination != null) {
      await File('$destination/Junayet-One-Page-CV.pdf').writeAsBytes(bytes);
    }
  },
      skip: input == null
          ? 'Private CV input supplied only for local export validation.'
          : false);
}
