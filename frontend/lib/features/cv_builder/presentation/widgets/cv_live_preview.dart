import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../../core/services/cv_pdf_service.dart';
import '../../data/models/cv_profile_model.dart';

/// Shows the actual export without waiting for a pause in typing.
class CvLivePreview extends StatefulWidget {
  const CvLivePreview({
    required this.cv,
    this.buildPdf,
    this.height = 900,
    this.showTitle = true,
    this.maxPageWidth = 650,
    super.key,
  });

  final CvProfileModel cv;
  final Future<Uint8List> Function(CvProfileModel cv)? buildPdf;
  final double height;
  final bool showTitle;
  final double maxPageWidth;

  @override
  State<CvLivePreview> createState() => _CvLivePreviewState();
}

class _CvLivePreviewState extends State<CvLivePreview> {
  List<_PreviewPage> _pages = [];
  ({CvProfileModel cv, double dpi})? _pending;
  String? _requestedContent;
  double? _requestedDpi;
  bool _rendering = false;
  bool _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _requestRender();
  }

  @override
  void didUpdateWidget(CvLivePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    _requestRender(force: oldWidget.buildPdf != widget.buildPdf);
  }

  void _requestRender({bool force = false}) {
    final media = MediaQuery.of(context);
    final width =
        math.min(widget.maxPageWidth, math.max(1.0, media.size.width - 32));
    final dpi = width * media.devicePixelRatio / PdfPageFormat.a4.width * 72;
    final data = widget.cv.toFirestore()..remove('updatedAt');
    final content = jsonEncode(data);
    // Selection/cursor changes and unrelated parent rebuilds need no new PDF.
    if (!force && content == _requestedContent && dpi == _requestedDpi) return;
    _requestedContent = content;
    _requestedDpi = dpi;
    _pending = (cv: widget.cv, dpi: dpi);
    unawaited(_renderPending());
  }

  Future<void> _renderPending() async {
    if (_rendering) return;
    _rendering = true;
    while (mounted && _pending != null) {
      final request = _pending!;
      _pending = null;
      try {
        final bytes = await (widget.buildPdf ??
            CvPdfService.instance.buildPdf)(request.cv);
        if (!mounted) break;
        final pages = <_PreviewPage>[];
        await for (final page in Printing.raster(bytes, dpi: request.dpi)) {
          final png = await page.toPng();
          if (!mounted) break;
          pages.add(_PreviewPage(png, page.width / page.height));
        }
        if (!mounted) break;
        if (pages.isEmpty) throw StateError('No PDF pages were rendered.');
        // Publish completed frames even while edits continue. Discarding them
        // would make the preview repaint only after the user stops typing.
        setState(() {
          _pages = pages;
          _failed = false;
        });
      } catch (_) {
        if (mounted && _pending == null) setState(() => _failed = true);
      }
      // A single render runs at a time; the next starts immediately with the
      // newest input, so older asynchronous results cannot overwrite it.
    }
    _rendering = false;
  }

  @override
  Widget build(BuildContext context) => SizedBox(
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showTitle)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('CV preview',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          if (_failed)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                  'Could not update the preview. Change the layout to try again.'),
            ),
          Expanded(
            child: _pages.isEmpty
                ? (_failed
                    ? const SizedBox.shrink()
                    : const Center(child: CircularProgressIndicator()))
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _pages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: widget.maxPageWidth),
                        child: AspectRatio(
                          aspectRatio: _pages[index].aspectRatio,
                          child: ColoredBox(
                            color: Colors.white,
                            child: Image.memory(
                              _pages[index].png,
                              fit: BoxFit.fill,
                              gaplessPlayback: true,
                              filterQuality: FilterQuality.high,
                              semanticLabel:
                                  'CV preview page ${index + 1} of ${_pages.length}',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ));
}

class _PreviewPage {
  const _PreviewPage(this.png, this.aspectRatio);

  final Uint8List png;
  final double aspectRatio;
}
