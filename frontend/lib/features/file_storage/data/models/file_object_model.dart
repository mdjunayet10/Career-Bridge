class FileObjectModel {
  const FileObjectModel({
    required this.id,
    required this.ownerUid,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.chunkCount,
    required this.sha256,
    required this.purpose,
    required this.state,
    required this.createdAt,
    this.applicationId,
  });

  final String id;
  final String ownerUid;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final int chunkCount;
  final String sha256;
  final String purpose;
  final String state;
  final String? applicationId;
  final DateTime createdAt;

  bool get isReady => state == 'ready';
  bool get isImage => mimeType.startsWith('image/');
  bool get isPdf => mimeType == 'application/pdf';

  factory FileObjectModel.fromFirestore(String id, Map<String, dynamic> data) {
    return FileObjectModel(
      id: id,
      ownerUid: (data['ownerUid'] as String?) ?? '',
      fileName: (data['fileName'] as String?) ?? 'file',
      mimeType: (data['mimeType'] as String?) ?? 'application/octet-stream',
      sizeBytes: (data['sizeBytes'] as num?)?.toInt() ?? 0,
      chunkCount: (data['chunkCount'] as num?)?.toInt() ?? 0,
      sha256: (data['sha256'] as String?) ?? '',
      purpose: (data['purpose'] as String?) ?? 'other',
      state: (data['state'] as String?) ?? 'uploading',
      applicationId: data['applicationId'] as String?,
      createdAt: _readDate(data['createdAt']),
    );
  }

  static DateTime _readDate(Object? value) {
    if (value is DateTime) return value;
    try {
      final dynamic dynamicValue = value;
      final converted = dynamicValue?.toDate();
      if (converted is DateTime) return converted;
    } catch (_) {}
    return DateTime.now();
  }
}
