import 'dart:typed_data';

import 'package:career_bridge/core/constants/file_limits.dart';
import 'package:career_bridge/core/services/image_compression_service.dart';
import 'package:career_bridge/features/file_storage/data/models/prepared_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('compresses and resizes an image into a Firestore-safe JPEG', () {
    final sourceImage = img.Image(width: 2200, height: 1200);
    img.fill(sourceImage, color: img.ColorRgb8(31, 92, 210));
    final source = PreparedFile(
      bytes: Uint8List.fromList(img.encodePng(sourceImage)),
      fileName: 'profile.png',
      mimeType: 'image/png',
    );

    final result = const ImageCompressionService().compress(source);
    final decoded = img.decodeImage(result.bytes);

    expect(result.mimeType, 'image/jpeg');
    expect(result.sizeBytes, lessThanOrEqualTo(FileLimits.maxFileBytes));
    expect(decoded, isNotNull);
    expect(decoded!.width, lessThanOrEqualTo(FileLimits.maxImageDimension));
    expect(decoded.height, lessThanOrEqualTo(FileLimits.maxImageDimension));
  });
}
