abstract final class FileLimits {
  static const int maxFileBytes = 2 * 1024 * 1024;
  static const int rawChunkBytes = 480 * 1024;
  static const int maxChunkCount = 8;
  static const int maxEncodedChunkCharacters = 700000;
  static const int maxImageDimension = 1600;

  static const Set<String> allowedImageMimeTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
  };

  static const Set<String> allowedDocumentMimeTypes = {
    'application/pdf',
  };

  static const Set<String> allowedMimeTypes = {
    ...allowedImageMimeTypes,
    ...allowedDocumentMimeTypes,
  };
}
