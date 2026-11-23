import 'dart:typed_data';

import 'package:career_bridge/core/constants/file_limits.dart';
import 'package:career_bridge/core/services/file_chunk_service.dart';
import 'package:career_bridge/core/services/file_validation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('encodes and reconstructs a multi-chunk file with integrity validation',
      () {
    final bytes = Uint8List.fromList(
      List<int>.generate(
          FileLimits.rawChunkBytes + 2048, (index) => index % 251),
    );

    final encoded = FileChunkService.encode(bytes);
    final reconstructed = FileChunkService.decode(
      chunks: encoded.values,
      expectedSha256: encoded.sha256,
      expectedSizeBytes: bytes.lengthInBytes,
    );

    expect(encoded.values.length, 2);
    expect(reconstructed, orderedEquals(bytes));
    expect(encoded.sha256.length, 64);
  });

  test('rejects files larger than two megabytes', () {
    final bytes = Uint8List(FileLimits.maxFileBytes + 1);
    expect(
      () => FileChunkService.encode(bytes),
      throwsA(isA<FileValidationException>()),
    );
  });
}
