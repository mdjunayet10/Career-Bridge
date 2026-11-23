import 'package:career_bridge/core/enums/user_role.dart';
import 'package:career_bridge/features/auth/presentation/widgets/demo_access_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('picker fills the selected fictional seeker credentials',
      (tester) async {
    String? selectedEmail;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DemoAccessPanel(
          role: UserRole.jobSeeker,
          onUseCredentials: (email, password) {
            selectedEmail = email;
            expect(password, 'Demo123!');
          },
        ),
      ),
    ));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Mira Sen').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use'));
    expect(selectedEmail, 'designer@careerbridge.demo');
    expect(tester.takeException(), isNull);
  });

  testWidgets('admin portal has no demo picker or credentials', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DemoAccessPanel(
        role: UserRole.admin,
        onUseCredentials: (email, password) {},
      ),
    ));
    expect(find.text('Use'), findsNothing);
    expect(find.textContaining('admin@'), findsNothing);
  });
}
