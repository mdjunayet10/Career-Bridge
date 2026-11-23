import 'package:flutter/material.dart';

import '../../data/models/cv_profile_model.dart';
import 'cv_live_preview.dart';

/// The single on-page PDF preview, with scrolling and zoom.
class CvDocumentPreview extends StatefulWidget {
  const CvDocumentPreview({required this.cv, required this.height, super.key});

  final CvProfileModel cv;
  final double height;

  @override
  State<CvDocumentPreview> createState() => _CvDocumentPreviewState();
}

class _CvDocumentPreviewState extends State<CvDocumentPreview> {
  final _transform = TransformationController();

  @override
  void initState() {
    super.initState();
    _transform.addListener(_refreshZoom);
  }

  void _refreshZoom() => setState(() {});

  void _zoom(double factor) {
    final scale =
        (_transform.value.getMaxScaleOnAxis() * factor).clamp(1.0, 4.0);
    _transform.value = Matrix4.diagonal3Values(scale, scale, 1);
  }

  @override
  void dispose() {
    _transform.removeListener(_refreshZoom);
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              const Expanded(
                child: Text('CV preview',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              IconButton(
                tooltip: 'Zoom out',
                onPressed: () => _zoom(1 / 1.25),
                icon: const Icon(Icons.zoom_out),
              ),
              TextButton(
                onPressed: () => _transform.value = Matrix4.identity(),
                child: Text(
                    '${(_transform.value.getMaxScaleOnAxis() * 100).round()}%'),
              ),
              IconButton(
                tooltip: 'Zoom in',
                onPressed: () => _zoom(1.25),
                icon: const Icon(Icons.zoom_in),
              ),
            ]),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => InteractiveViewer(
                  transformationController: _transform,
                  alignment: Alignment.topCenter,
                  minScale: 1,
                  maxScale: 4,
                  child: CvLivePreview(
                    cv: widget.cv,
                    height: constraints.maxHeight,
                    showTitle: false,
                    maxPageWidth: 1000,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
