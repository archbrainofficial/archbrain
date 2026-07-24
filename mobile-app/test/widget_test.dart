import 'package:archbrain_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create account flow moves to verification step', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Ada Lovelace');
    await tester.enterText(find.byType(TextFormField).at(1), 'ada@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), '+2348012345678');
    await tester.tap(find.text('Send verification code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.textContaining('Create your ARCHBRAIN account'), findsOneWidget);
  });
}
