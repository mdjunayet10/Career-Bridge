import 'dart:typed_data';

import '../models/file_object_model.dart';
import '../models/prepared_file.dart';

abstract interface class FileObjectRepository {
  Future<FileObjectModel> upload({
    required PreparedFile file,
    required String ownerUid,
    required String purpose,
    String? applicationId,
  });

  Future<FileObjectModel> getMetadata(String fileId);

  Future<Uint8List> download(String fileId);

  Future<void> delete(String fileId);
}
