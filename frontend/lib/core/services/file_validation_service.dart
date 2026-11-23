import '../constants/file_limits.dart';
import '../../features/file_storage/data/models/prepared_file.dart';

class FileValidationException implements Exception {
  const FileValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract final class FileValidationService {
  static void validate(PreparedFile file) {
    if (file.bytes.isEmpty) {
      throw const FileValidationException('The selected file is empty.');
    }
    if (file.sizeBytes > FileLimits.maxFileBytes) {
      throw const FileValidationException('Files must be 2 MB or smaller.');
    }
    if (!FileLimits.allowedMimeTypes.contains(file.mimeType)) {
      throw FileValidationException('Unsupported file type: ${file.mimeType}.');
    }
  }

  static String readableSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kilobytes = bytes / 1024;
    if (kilobytes < 1024) return '${kilobytes.toStringAsFixed(1)} KB';
    return '${(kilobytes / 1024).toStringAsFixed(2)} MB';
  }
}
