import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../controllers/file_storage_controller.dart';

class StoredFileImage extends StatelessWidget {
  const StoredFileImage({
    required this.fileId,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.borderRadius,
    super.key,
  });

  final String fileId;
  final Widget fallback;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    if (fileId.trim().isEmpty) return fallback;
    return FutureBuilder<Uint8List>(
      future: FileStorageController.instance.download(fileId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return fallback;
        final image = Image.memory(
          snapshot.data!,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => fallback,
        );
        if (borderRadius == null) return image;
        return ClipRRect(borderRadius: borderRadius!, child: image);
      },
    );
  }
}
