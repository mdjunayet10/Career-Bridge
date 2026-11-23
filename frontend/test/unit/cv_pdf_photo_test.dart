import 'dart:convert';
import 'dart:io';

import 'package:career_bridge/core/services/cv_pdf_service.dart';
import 'package:career_bridge/features/cv_builder/data/models/cv_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final template in ['reference', 'reference-compact']) {
    test('$template renders a circular photo without stretching its contents',
        () async {
      // A circle inside a portrait image reveals stretching independently of
      // the outer crop: a circular frame alone could still contain distortion.
      final portrait = image.Image(width: 200, height: 300);
      image.fill(portrait, color: image.ColorRgb8(255, 0, 0));
      image.fillCircle(portrait,
          x: 100, y: 150, radius: 25, color: image.ColorRgb8(0, 255, 255));
      final cv = CvProfileModel(
        ownerUid: 'photo-geometry',
        fullName: 'Photo Geometry',
        email: 'photo@example.com',
        templateId: template,
        photoDataUrl:
            'data:image/png;base64,${base64Encode(image.encodePng(portrait))}',
        updatedAt: DateTime(2026),
      );
      final bytes = await CvPdfService.instance.buildPdf(cv);
      final directory = await Directory.systemTemp.createTemp('cv-photo-');
      try {
        final pdfPath = '${directory.path}/photo.pdf';
        final prefix = '${directory.path}/photo';
        await File(pdfPath).writeAsBytes(bytes);
        final rendered = await Process.run('pdftoppm',
            ['-f', '1', '-singlefile', '-r', '144', '-png', pdfPath, prefix]);
        expect(rendered.exitCode, 0, reason: '${rendered.stderr}');
        final page = image.decodePng(await File('$prefix.png').readAsBytes())!;

        bool photoPixel(image.Pixel pixel) =>
            (pixel.r > 200 && pixel.g < 50 && pixel.b < 50) ||
            (pixel.r < 50 && pixel.g > 200 && pixel.b > 200);
        final frame = _bounds(page, photoPixel);
        expect((frame.width - frame.height).abs(), lessThanOrEqualTo(2),
            reason: 'The photo frame must be circular, not a portrait oval.');
        expect(frame.width, greaterThan(100));
        for (final xFraction in [.08, .92]) {
          for (final yFraction in [.08, .92]) {
            expect(
                photoPixel(page.getPixel(
                    frame.left + (frame.width * xFraction).round(),
                    frame.top + (frame.height * yFraction).round())),
                isFalse,
                reason:
                    'A circular photo must leave its square corners clear.');
          }
        }
        final circle = _bounds(
            page, (pixel) => pixel.r < 50 && pixel.g > 200 && pixel.b > 200);
        expect(circle.width, greaterThan(25));
        expect((circle.width - circle.height).abs(), lessThanOrEqualTo(2),
            reason: 'A circle in the source photo must remain round.');
      } finally {
        await directory.delete(recursive: true);
      }
    });
  }
}

({int left, int top, int width, int height}) _bounds(
    image.Image page, bool Function(image.Pixel) matches) {
  var left = page.width;
  var top = page.height;
  var right = -1;
  var bottom = -1;
  for (final pixel in page) {
    if (!matches(pixel)) continue;
    if (pixel.x < left) left = pixel.x;
    if (pixel.y < top) top = pixel.y;
    if (pixel.x > right) right = pixel.x;
    if (pixel.y > bottom) bottom = pixel.y;
  }
  expect(right, greaterThanOrEqualTo(left), reason: 'Missing photo pixels.');
  return (
    left: left,
    top: top,
    width: right - left + 1,
    height: bottom - top + 1
  );
}
