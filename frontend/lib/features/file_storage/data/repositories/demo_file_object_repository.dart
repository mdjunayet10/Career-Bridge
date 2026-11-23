import 'dart:typed_data';

import '../../../../core/services/file_chunk_service.dart';
import '../../../../core/services/file_validation_service.dart';
import '../models/file_object_model.dart';
import '../models/prepared_file.dart';
import 'file_object_repository.dart';

class DemoFileObjectRepository implements FileObjectRepository {
  DemoFileObjectRepository._();

  static final DemoFileObjectRepository instance = DemoFileObjectRepository._();

  final Map<String, FileObjectModel> _metadata = {};
  final Map<String, Uint8List> _bytes = {};

  Future<void> _wait() =>
      Future<void>.delayed(const Duration(milliseconds: 180));

  @override
  Future<FileObjectModel> upload({
    required PreparedFile file,
    required String ownerUid,
    required String purpose,
    String? applicationId,
  }) async {
    await _wait();
    FileValidationService.validate(file);
    final encoded = FileChunkService.encode(file.bytes);
    final id = 'demo-file-${DateTime.now().microsecondsSinceEpoch}';
    final model = FileObjectModel(
      id: id,
      ownerUid: ownerUid,
      fileName: file.fileName,
      mimeType: file.mimeType,
      sizeBytes: file.sizeBytes,
      chunkCount: encoded.values.length,
      sha256: encoded.sha256,
      purpose: purpose,
      state: 'ready',
      applicationId: applicationId,
      createdAt: DateTime.now(),
    );
    _metadata[id] = model;
    _bytes[id] = Uint8List.fromList(file.bytes);
    return model;
  }

  @override
  Future<FileObjectModel> getMetadata(String fileId) async {
    await _wait();
    final model = _metadata[fileId];
    if (model == null) {
      throw const FileValidationException(
          'The requested demo file does not exist.');
    }
    return model;
  }

  @override
  Future<Uint8List> download(String fileId) async {
    await _wait();
    final bytes = _bytes[fileId];
    if (bytes == null) {
      throw const FileValidationException(
          'The requested demo file does not exist.');
    }
    return Uint8List.fromList(bytes);
  }

  @override
  Future<void> delete(String fileId) async {
    await _wait();
    _metadata.remove(fileId);
    _bytes.remove(fileId);
  }

  void reset() {
    _metadata.clear();
    _bytes.clear();
  }
}
