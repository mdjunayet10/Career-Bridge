import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/file_chunk_service.dart';
import '../../../../core/services/file_validation_service.dart';
import '../models/file_object_model.dart';
import '../models/prepared_file.dart';
import 'file_object_repository.dart';

class FirebaseFileObjectRepository implements FileObjectRepository {
  FirebaseFileObjectRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<FileObjectModel> upload({
    required PreparedFile file,
    required String ownerUid,
    required String purpose,
    String? applicationId,
  }) async {
    FileValidationService.validate(file);
    final encoded = FileChunkService.encode(file.bytes);
    final parent = _firestore.collection('fileObjects').doc();
    final now = DateTime.now();

    await parent.set({
      'ownerUid': ownerUid,
      'applicationId': applicationId,
      'fileName': file.fileName,
      'mimeType': file.mimeType,
      'sizeBytes': file.sizeBytes,
      'chunkCount': encoded.values.length,
      'sha256': encoded.sha256,
      'purpose': purpose,
      'state': 'uploading',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    try {
      final batch = _firestore.batch();
      for (var index = 0; index < encoded.values.length; index++) {
        final chunkRef =
            parent.collection('chunks').doc(index.toString().padLeft(3, '0'));
        batch.set(chunkRef, {
          'index': index,
          'data': encoded.values[index],
        });
      }
      await batch.commit();
      await parent.update({
        'state': 'ready',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      await _bestEffortDelete(parent.id);
      rethrow;
    }

    return FileObjectModel(
      id: parent.id,
      ownerUid: ownerUid,
      fileName: file.fileName,
      mimeType: file.mimeType,
      sizeBytes: file.sizeBytes,
      chunkCount: encoded.values.length,
      sha256: encoded.sha256,
      purpose: purpose,
      state: 'ready',
      applicationId: applicationId,
      createdAt: now,
    );
  }

  @override
  Future<FileObjectModel> getMetadata(String fileId) async {
    final snapshot =
        await _firestore.collection('fileObjects').doc(fileId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      throw const FileValidationException('The requested file does not exist.');
    }
    return FileObjectModel.fromFirestore(snapshot.id, data);
  }

  @override
  Future<Uint8List> download(String fileId) async {
    final metadata = await getMetadata(fileId);
    if (!metadata.isReady) {
      throw const FileValidationException(
          'The requested file has not finished uploading.');
    }

    final query = await _firestore
        .collection('fileObjects')
        .doc(fileId)
        .collection('chunks')
        .orderBy('index')
        .get();

    if (query.docs.length != metadata.chunkCount) {
      throw const FileValidationException('The stored file is incomplete.');
    }

    return FileChunkService.decode(
      chunks: query.docs
          .map((doc) => (doc.data()['data'] as String?) ?? '')
          .toList(growable: false),
      expectedSha256: metadata.sha256,
      expectedSizeBytes: metadata.sizeBytes,
    );
  }

  @override
  Future<void> delete(String fileId) => _bestEffortDelete(fileId);

  Future<void> _bestEffortDelete(String fileId) async {
    final parent = _firestore.collection('fileObjects').doc(fileId);
    final chunks = await parent.collection('chunks').get();
    if (chunks.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (final chunk in chunks.docs) {
        batch.delete(chunk.reference);
      }
      await batch.commit();
    }
    await parent.delete();
  }
}
