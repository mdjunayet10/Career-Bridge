import 'dart:async';

import 'package:career_bridge/features/auth/data/demo_account_catalog.dart';
import 'package:career_bridge/features/companies/controllers/company_logo_registry.dart';
import 'package:career_bridge/shared/widgets/company_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => CompanyLogoRegistry.instance.clear());

  testWidgets('default demo employer displays its actual bundled company logo',
      (tester) async {
    final employer = DemoAccountCatalog.byEmail('employer@careerbridge.demo')!;
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: CompanyLogo(
            companyId: employer.companyId, companyName: employer.companyName),
      ),
    ));

    final provider = tester.widget<Image>(find.byType(Image)).image;
    final decoded = await tester.runAsync(() async {
      final loaded = Completer<Object>();
      final stream = provider.resolve(ImageConfiguration.empty);
      final listener = ImageStreamListener((info, _) {
        if (!loaded.isCompleted) {
          loaded.complete(
              Size(info.image.width.toDouble(), info.image.height.toDouble()));
        }
        info.dispose();
      }, onError: (error, _) {
        if (!loaded.isCompleted) loaded.complete(error);
      });
      stream.addListener(listener);
      try {
        return await loaded.future.timeout(const Duration(seconds: 5));
      } finally {
        stream.removeListener(listener);
      }
    });
    expect(decoded, isA<Size>(),
        reason: 'The default employer logo must load a real bundled image.');
    expect((decoded! as Size).width, greaterThan(0));
    await tester.pump();
    expect(find.byIcon(Icons.apartment_rounded), findsNothing,
        reason: 'The NovaTech logo must not silently become a generic icon.');
    expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
