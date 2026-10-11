import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitiq/main.dart';

void main() {
  testWidgets('main tabs are accessible', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const FitIQ());
    await tester.pumpAndSettle();
    expect(find.text('FITIQ'), findsOneWidget);
    await tester.tap(find.text('Train'));
    await tester.pumpAndSettle();
    expect(find.text('Train smarter'), findsOneWidget);
    await tester.tap(find.text('Nutrition'));
    await tester.pumpAndSettle();
    expect(find.text('Fuel your body'), findsOneWidget);
  });
}
