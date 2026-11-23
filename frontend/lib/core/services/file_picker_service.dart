import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../features/file_storage/data/models/prepared_file.dart';
import 'file_validation_service.dart';

class FilePickerService {
  const FilePickerService();

  Future<PreparedFile?> pickImage() {
    return _pick(
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      fallbackMimeType: 'image/jpeg',
    );
  }

  Future<PreparedFile?> pickPdf() {
    return _pick(
      allowedExtensions: const ['pdf'],
      fallbackMimeType: 'application/pdf',
    );
  }

  Future<PreparedFile?> _pick({
    required List<String> allowedExtensions,
    required String fallbackMimeType,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      throw const FileValidationException(
          'The selected file could not be read on this device.');
    }

    final prepared = PreparedFile(
      bytes: Uint8List.fromList(bytes),
      fileName: _safeFileName(file.name),
      mimeType: _mimeTypeFor(file.extension, fallbackMimeType),
    );
    return prepared;
  }

  String _mimeTypeFor(String? extension, String fallback) {
    return switch (extension?.toLowerCase()) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'pdf' => 'application/pdf',
      _ => fallback,
    };
  }

  String _safeFileName(String name) {
    final sanitized = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return sanitized.isEmpty ? 'career_bridge_file' : sanitized;
  }
}
