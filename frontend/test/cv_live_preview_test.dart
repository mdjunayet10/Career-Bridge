import 'dart:async';
import 'dart:typed_data';

import 'package:career_bridge/features/cv_builder/data/models/cv_profile_model.dart';
import 'package:career_bridge/features/cv_builder/presentation/widgets/cv_live_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:printing/printing.dart';
import 'package:printing/src/interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final original = PrintingPlatform.instance;
    PrintingPlatform.instance = _Printing();
    addTearDown(() => PrintingPlatform.instance = original);
  });

  testWidgets('renders during continuous typing without the 300ms idle delay',
      (tester) async {
    final draft = ValueNotifier(_cv('A'));
    addTearDown(draft.dispose);
    final rendered = <String>[];
    Future<Uint8List> build(CvProfileModel cv) async {
      rendered.add(cv.fullName);
      return Uint8List.fromList([cv.fullName.codeUnitAt(0)]);
    }

    await tester.pumpWidget(_harness(draft, build));
    await tester.pumpAndSettle();
    for (final name in ['B', 'C', 'D', 'E']) {
      draft.value = _cv(name);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(rendered.last, name);
      expect(_shownPage(tester), _Raster.png(name.codeUnitAt(0)));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    }
    expect(rendered, ['A', 'B', 'C', 'D', 'E']);
    // Only the paper is white; there is no gray scroll surface or shadow.
    expect(find.byType(DecoratedBox), findsNothing);
    expect(
        tester
            .widget<ColoredBox>(find.descendant(
                of: find.byType(CvLivePreview),
                matching: find.byType(ColoredBox)))
            .color,
        Colors.white);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps updating while busy and finishes with the newest edit',
      (tester) async {
    final draft = ValueNotifier(_cv('A'));
    addTearDown(draft.dispose);
    final requests = <String, Completer<Uint8List>>{};
    Future<Uint8List> build(CvProfileModel cv) =>
        (requests[cv.fullName] = Completer<Uint8List>()).future;

    await tester.pumpWidget(_harness(draft, build));
    expect(requests.keys, ['A']);
    draft.value = _cv('B');
    await tester.pump();
    draft.value = _cv('C');
    await tester.pump();
    expect(requests.keys, ['A']); // Never run overlapping PDF builds.
    requests['A']!.complete(Uint8List.fromList([65]));
    await tester.pump();
    await tester.pump();
    expect(_shownPage(tester), _Raster.png(65));
    expect(requests.keys, ['A', 'C']); // Coalesce queued edits, not idle time.
    draft.value = _cv('D');
    await tester.pump();
    requests['C']!.complete(Uint8List.fromList([67]));
    await tester.pump();
    await tester.pump();
    expect(_shownPage(tester), _Raster.png(67));
    expect(requests.keys, ['A', 'C', 'D']);
    requests['D']!.complete(Uint8List.fromList([68]));
    await tester.pumpAndSettle();
    expect(_shownPage(tester), _Raster.png(68));
    // Saving/rebuilding identical content must not render it again.
    draft.value = draft.value.copyWith(updatedAt: DateTime(2030));
    await tester.pump();
    expect(requests.length, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shrinks page count and recovers from a failed preview',
      (tester) async {
    final draft = ValueNotifier(_cv('A'));
    addTearDown(draft.dispose);
    Future<Uint8List> build(CvProfileModel cv) async {
      if (cv.fullName == 'B') throw StateError('Test failure');
      return Uint8List.fromList(
          [cv.fullName.codeUnitAt(0), cv.fullName == 'A' ? 2 : 1]);
    }

    await tester.pumpWidget(_harness(draft, build));
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsNWidgets(2));
    draft.value = _cv('B');
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not update'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(2));
    draft.value = _cv('C');
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not update'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
    expect(_shownPage(tester), _Raster.png(67));
  });

  testWidgets('an in-flight render can finish after leaving the builder',
      (tester) async {
    final draft = ValueNotifier(_cv('A'));
    addTearDown(draft.dispose);
    final pending = Completer<Uint8List>();
    await tester.pumpWidget(_harness(draft, (_) => pending.future));
    await tester.pumpWidget(const SizedBox());
    pending.complete(Uint8List.fromList([65]));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

CvProfileModel _cv(String name) => CvProfileModel(
      ownerUid: 'preview',
      fullName: name,
      email: 'test@example.com',
      updatedAt: DateTime(2026),
    );

Widget _harness(ValueNotifier<CvProfileModel> draft,
        Future<Uint8List> Function(CvProfileModel) build) =>
    MaterialApp(
      home: Scaffold(
          body: SingleChildScrollView(
              child: ValueListenableBuilder(
        valueListenable: draft,
        builder: (context, cv, _) => CvLivePreview(cv: cv, buildPdf: build),
      ))),
    );

Uint8List _shownPage(WidgetTester tester) =>
    (tester.widget<Image>(find.byType(Image).first).image as MemoryImage).bytes;

class _Printing extends PrintingPlatform {
  @override
  Stream<PdfRaster> raster(
      Uint8List document, List<int>? pages, double dpi) async* {
    for (var i = 0; i < (document.length > 1 ? document[1] : 1); i++) {
      yield _Raster(document[0]);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Raster extends PdfRaster {
  _Raster(this.color) : super(1, 1, Uint8List.fromList([color, 0, 0, 255]));
  final int color;

  static Uint8List png(int color) => img.encodePng(
      img.Image(width: 1, height: 1)..setPixelRgb(0, 0, color, 0, 0));

  @override
  Future<Uint8List> toPng() async => png(color);
}
