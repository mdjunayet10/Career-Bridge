import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/controllers/auth_controller.dart';

const reportReasons = [
  'Fake Job',
  'Scam/Fraud',
  'Misleading Information',
  'Inappropriate Content',
  'Other',
];

class ReportService {
  static Future<bool> submit(
      {required String targetType,
      required String targetId,
      required String targetLabel,
      required String reason,
      required String details}) async {
    final auth = AuthController.instance;
    final user = auth.currentUser;
    if (user == null || !user.isActive) {
      throw StateError('Sign in with an active account to report content.');
    }
    if (!auth.usesFirebase) {
      throw StateError('Demo mode does not submit live reports.');
    }
    if (!['job', 'company'].contains(targetType) ||
        targetId.isEmpty ||
        targetId.contains('/') ||
        !reportReasons.contains(reason) ||
        details.trim().length > 2000) {
      throw ArgumentError('Invalid report. Check the reason and description.');
    }
    final db = FirebaseFirestore.instance;
    final reference =
        db.collection('reports').doc('${user.uid}_${targetType}_$targetId');
    return db.runTransaction((transaction) async {
      final existing = await transaction.get(reference);
      if (existing.exists) return false;
      transaction.set(reference, {
        'reporterUid': user.uid,
        'reporterName': user.name,
        'targetType': targetType,
        'targetId': targetId,
        'targetLabel': targetLabel,
        'reason': reason,
        'details': details.trim(),
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    });
  }
}
