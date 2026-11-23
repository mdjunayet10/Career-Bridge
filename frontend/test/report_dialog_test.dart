import 'dart:async';
import 'package:career_bridge/features/reports/report_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'requires reason, locks repeated submits and returns successful result',
      (tester) async {
    final pending = Completer<bool>();
    var calls = 0;
    bool? result;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    child: const Text('Report'),
                    onPressed: () async {
                      result = await showDialog<bool>(
                          context: context,
                          builder: (_) => ReportDialog(
                              targetType: 'job',
                              targetLabel: 'Example job',
                              submit: (reason, details) {
                                calls++;
                                expect(reason, 'Fake Job');
                                expect(details, 'Suspicious listing');
                                return pending.future;
                              }));
                    })))));
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit report'));
    await tester.pumpAndSettle();
    expect(find.text('Select a report reason.'), findsOneWidget);
    expect(calls, 0);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fake Job').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Suspicious listing');
    await tester.tap(find.text('Submit report'));
    await tester.pump();
    expect(calls, 1);
    expect(find.text('Submitting…'), findsOneWidget);
    await tester.tap(find.text('Submitting…'));
    expect(calls, 1);
    pending.complete(true);
    await tester.pumpAndSettle();
    expect(result, true);
    expect(tester.takeException(), isNull);
  });
  testWidgets('failed submission stays open with retry feedback',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ReportDialog(
                targetType: 'company',
                targetLabel: 'Company',
                submit: (reason, details) async =>
                    throw StateError('offline')))));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit report'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not submit report'), findsOneWidget);
    expect(find.text('Submit report'), findsOneWidget);
  });
}
