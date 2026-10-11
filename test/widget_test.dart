import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitiq/main.dart';
import 'package:fitiq/exercise_studio.dart';

void main() {
  test('exercise catalog covers major body areas', () {
    for (final group in muscleGroups.where((group) => group != 'All')) {
      expect(exerciseCatalog.any((exercise) => exercise.muscle == group), isTrue);
    }
    expect(exerciseCatalog.length, greaterThanOrEqualTo(18));
  });

  Future<void> setupScreen(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('first launch has local onboarding and working tabs', (tester) async {
    await setupScreen(tester);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const FitIQ());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profileName')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('profileName')), 'Test Athlete');
    await tester.ensureVisible(find.byKey(const Key('enterFitIQ')));
    await tester.pumpAndSettle();
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('enterFitIQ')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('enterFitIQ')));
    await tester.pumpAndSettle();
    expect(find.text('Make today count, Test Athlete.'), findsOneWidget);
    await tester.tap(find.text('Train'));
    await tester.pumpAndSettle();
    expect(find.text('Train smarter'), findsOneWidget);
    await tester.tap(find.text('Nutrition'));
    await tester.pumpAndSettle();
    expect(find.text('Fuel your body'), findsOneWidget);
  });

  testWidgets('logging dialog closes without lifecycle assertion', (tester) async {
    await setupScreen(tester);
    SharedPreferences.setMockInitialValues({'onboarded': true, 'name': 'Tester'});
    await tester.pumpWidget(const FitIQ());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('enterFitIQ')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Log water'));
    await tester.tap(find.text('Log water'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '250');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('250'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile edit and tab switching preserve widget tree', (tester) async {
    await setupScreen(tester);
    SharedPreferences.setMockInitialValues({'onboarded': true, 'name': 'Tester'});
    await tester.pumpWidget(const FitIQ());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('enterFitIQ')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Updated');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.text('Make today count, Updated.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
