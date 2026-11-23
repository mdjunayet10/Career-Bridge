import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../constants/file_limits.dart';
import '../../features/file_storage/data/models/prepared_file.dart';
import 'file_validation_service.dart';

class ImageCompressionService {
  const ImageCompressionService();

  PreparedFile compress(PreparedFile source) {
    final decoded = img.decodeImage(source.bytes);
    if (decoded == null) {
      throw const FileValidationException(
          'The selected image is invalid or unsupported.');
    }

    var image = img.bakeOrientation(decoded);
    final longestSide = image.width > image.height ? image.width : image.height;
    if (longestSide > FileLimits.maxImageDimension) {
      if (image.width >= image.height) {
        image = img.copyResize(
          image,
          width: FileLimits.maxImageDimension,
          interpolation: img.Interpolation.average,
        );
      } else {
        image = img.copyResize(
          image,
          height: FileLimits.maxImageDimension,
          interpolation: img.Interpolation.average,
        );
      }
    }

    Uint8List? best;
    for (final quality in const [88, 80, 72, 64, 56, 48, 40]) {
      final encoded =
          Uint8List.fromList(img.encodeJpg(image, quality: quality));
      best = encoded;
      if (encoded.lengthInBytes <= FileLimits.maxFileBytes) break;
    }

    if (best == null || best.lengthInBytes > FileLimits.maxFileBytes) {
      throw const FileValidationException(
        'The image is still larger than 2 MB after compression. Choose a smaller image.',
      );
    }

    final baseName = source.fileName.replaceFirst(RegExp(r'\.[^.]+$'), '');
    return PreparedFile(
      bytes: best,
      fileName: '${baseName}_compressed.jpg',
      mimeType: 'image/jpeg',
    );
  }
}
