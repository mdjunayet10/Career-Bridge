import 'package:career_bridge/app/theme/app_theme.dart';
import 'package:career_bridge/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Sora');
    for (final weight in [400, 500, 600, 700, 800]) {
      fonts.addFont(rootBundle.load('assets/fonts/Sora-$weight.ttf'));
    }
    await fonts.load();
  });

  for (final width in [320.0, 390.0, 1200.0]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets('role labels stay on one aligned line at $width / $scale',
          (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.binding.setSurfaceSize(Size(width, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!),
          home: const LoginPage(),
        ));
        await tester.pumpAndSettle();
        final buttonBounds = <Rect>[];
        final labelCenters = <double>[];
        for (final label in ['Job Seeker', 'Employer']) {
          final text = find.text(label);
          final paragraph = tester.renderObject<RenderParagraph>(text);
          final boxes = paragraph.getBoxesForSelection(
              TextSelection(baseOffset: 0, extentOffset: label.length));
          expect(boxes.map((box) => box.top).toSet(), hasLength(1),
              reason: '$label must not wrap mid-word');
          if (scale <= 1.3) {
            expect(paragraph.didExceedMaxLines, isFalse,
                reason: '$label must remain fully readable at $scale');
          }
          expect(paragraph.textScaler.scale(10), closeTo(10 * scale, .01));
          final button =
              find.ancestor(of: text, matching: find.byType(InkWell)).first;
          final bounds = tester.getRect(button);
          buttonBounds.add(bounds);
          labelCenters.add(tester.getCenter(text).dy);
          expect(bounds.height, greaterThanOrEqualTo(48));
          final icon = find.descendant(of: button, matching: find.byType(Icon));
          if (width == 1200 && scale == 1) {
            expect(tester.getCenter(icon).dy,
                closeTo(tester.getCenter(text).dy, .01));
          }
          expect(find.bySemanticsLabel(label), findsOneWidget);
        }
        expect(buttonBounds[0].height, closeTo(buttonBounds[1].height, .01));
        expect(buttonBounds[0].width, closeTo(buttonBounds[1].width, .01));
        expect(labelCenters[0], closeTo(labelCenters[1], .01));
        await tester.ensureVisible(find.text('Employer'));
        await tester.tap(find.text('Employer'));
        await tester.pumpAndSettle();
        expect(
            find.byWidgetPredicate((widget) =>
                widget is TextField &&
                widget.decoration?.labelText == 'Work email'),
            findsOneWidget);
        await tester.ensureVisible(find.text('Job Seeker'));
        await tester.tap(find.text('Job Seeker'));
        await tester.pumpAndSettle();
        expect(
            find.byWidgetPredicate((widget) =>
                widget is TextField &&
                widget.decoration?.labelText == 'Email address'),
            findsOneWidget);
        expect(tester.takeException(), isNull);
        semantics.dispose();
      });
    }
  }
}
