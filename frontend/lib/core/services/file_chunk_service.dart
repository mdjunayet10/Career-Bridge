import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../constants/file_limits.dart';
import 'file_validation_service.dart';

class EncodedFileChunks {
  const EncodedFileChunks({required this.values, required this.sha256});

  final List<String> values;
  final String sha256;
}

abstract final class FileChunkService {
  static EncodedFileChunks encode(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw const FileValidationException('The file is empty.');
    }
    if (bytes.lengthInBytes > FileLimits.maxFileBytes) {
      throw const FileValidationException('Files must be 2 MB or smaller.');
    }

    final chunks = <String>[];
    for (var offset = 0;
        offset < bytes.length;
        offset += FileLimits.rawChunkBytes) {
      final candidateEnd = offset + FileLimits.rawChunkBytes;
      final end = candidateEnd < bytes.length ? candidateEnd : bytes.length;
      final encoded = base64Encode(bytes.sublist(offset, end));
      if (encoded.length > FileLimits.maxEncodedChunkCharacters) {
        throw const FileValidationException(
            'A file chunk exceeded the Firestore safety limit.');
      }
      chunks.add(encoded);
    }

    if (chunks.length > FileLimits.maxChunkCount) {
      throw const FileValidationException(
          'The selected file requires too many Firestore chunks.');
    }

    return EncodedFileChunks(
      values: List.unmodifiable(chunks),
      sha256: sha256.convert(bytes).toString(),
    );
  }

  static Uint8List decode({
    required List<String> chunks,
    required String expectedSha256,
    required int expectedSizeBytes,
  }) {
    if (chunks.isEmpty) {
      throw const FileValidationException('The stored file has no chunks.');
    }

    final builder = BytesBuilder(copy: false);
    for (final chunk in chunks) {
      builder.add(base64Decode(chunk));
    }
    final bytes = builder.takeBytes();

    if (bytes.lengthInBytes != expectedSizeBytes) {
      throw const FileValidationException(
          'The stored file size does not match its metadata.');
    }
    final actualSha = sha256.convert(bytes).toString();
    if (expectedSha256.isNotEmpty && actualSha != expectedSha256) {
      throw const FileValidationException(
          'The stored file failed its integrity check.');
    }
    return bytes;
  }
}
