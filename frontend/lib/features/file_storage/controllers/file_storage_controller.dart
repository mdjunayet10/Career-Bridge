import 'dart:typed_data';

import 'package:printing/printing.dart';

import '../../../core/services/file_picker_service.dart';
import '../../../core/services/file_validation_service.dart';
import '../../../core/services/image_compression_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../data/models/file_object_model.dart';
import '../data/models/prepared_file.dart';
import '../data/repositories/demo_file_object_repository.dart';
import '../data/repositories/file_object_repository.dart';
import '../data/repositories/firebase_file_object_repository.dart';

class FileStorageController {
  FileStorageController._();

  static final FileStorageController instance = FileStorageController._();

  final FilePickerService _picker = const FilePickerService();
  final ImageCompressionService _compressor = const ImageCompressionService();
  final Map<String, Uint8List> _memoryCache = {};
  FileObjectRepository? _repository;
  bool? _repositoryUsesFirebase;
  String? _repositoryUid;

  Future<FileObjectModel?> pickCompressAndUploadImage({
    required String ownerUid,
    required String purpose,
  }) async {
    final selected = await _picker.pickImage();
    if (selected == null) return null;
    final compressed = _compressor.compress(selected);
    FileValidationService.validate(compressed);
    return upload(
      file: compressed,
      ownerUid: ownerUid,
      purpose: purpose,
    );
  }

  Future<FileObjectModel?> pickAndUploadPdf({
    required String ownerUid,
    required String purpose,
    String? applicationId,
  }) async {
    final selected = await _picker.pickPdf();
    if (selected == null) return null;
    FileValidationService.validate(selected);
    return upload(
      file: selected,
      ownerUid: ownerUid,
      purpose: purpose,
      applicationId: applicationId,
    );
  }

  Future<FileObjectModel> upload({
    required PreparedFile file,
    required String ownerUid,
    required String purpose,
    String? applicationId,
  }) async {
    FileValidationService.validate(file);
    final repository = _resolveRepository();
    final result = await repository.upload(
      file: file,
      ownerUid: ownerUid,
      purpose: purpose,
      applicationId: applicationId,
    );
    _memoryCache[result.id] = Uint8List.fromList(file.bytes);
    return result;
  }

  Future<Uint8List> download(String fileId) async {
    // Resolve the current session before consulting memory; _resolveRepository
    // clears private cached bytes whenever the authenticated UID changes.
    final repository = _resolveRepository();
    final cached = _memoryCache[fileId];
    if (cached != null) return Uint8List.fromList(cached);
    final bytes = await repository.download(fileId);
    _memoryCache[fileId] = Uint8List.fromList(bytes);
    return bytes;
  }

  Future<void> sharePdf({
    required String fileId,
    required String fileName,
  }) async {
    final bytes = await download(fileId);
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  Future<void> delete(String? fileId) async {
    if (fileId == null || fileId.trim().isEmpty) return;
    _memoryCache.remove(fileId);
    await _resolveRepository().delete(fileId);
  }

  FileObjectRepository _resolveRepository() {
    final auth = AuthController.instance;
    final usesFirebase = auth.usesFirebase;
    final uid = auth.currentUser?.uid;
    final sessionChanged = _repositoryUid != uid;

    if (_repository == null ||
        _repositoryUsesFirebase != usesFirebase ||
        sessionChanged) {
      // Cached private bytes must never survive a user/session change.
      _memoryCache.clear();
      _repository = usesFirebase
          ? FirebaseFileObjectRepository()
          : DemoFileObjectRepository.instance;
      _repositoryUsesFirebase = usesFirebase;
      _repositoryUid = uid;
    }
    return _repository!;
  }

  void clearCache() => _memoryCache.clear();
}
