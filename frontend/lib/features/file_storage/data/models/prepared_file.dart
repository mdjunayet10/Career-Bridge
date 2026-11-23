import 'dart:typed_data';

class PreparedFile {
  const PreparedFile({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String fileName;
  final String mimeType;

  int get sizeBytes => bytes.lengthInBytes;
}
