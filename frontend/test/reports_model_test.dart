import 'package:career_bridge/features/admin/data/models/platform_report_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('user report fields and moderation states survive Firestore parsing',
      () {
    for (final status in PlatformReportStatus.values) {
      final report = PlatformReportModel.fromFirestore('report', {
        'reporterUid': 'user',
        'reporterName': 'User',
        'targetType': 'company',
        'targetId': 'company',
        'targetLabel': 'Company',
        'reason': 'Scam/Fraud',
        'details': 'Details',
        'createdAt': DateTime(2026, 11, 2),
        'status': status.firestoreValue,
      });
      expect(report.status, status);
      expect(report.targetId, 'company');
      expect(report.details, 'Details');
    }
  });
}
