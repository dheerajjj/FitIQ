import 'package:flutter_test/flutter_test.dart';
import 'package:fitiq/coach.dart';

void main() {
  test('progress when completed at moderate effort', () {
    final result = offlineAdvice(const CoachInput(12, 12, 6, 2, 20));
    expect(result.action, 'progress');
    expect(result.weightKg, 20.5);
  });
  test('recovery takes priority', () {
    expect(offlineAdvice(const CoachInput(12, 12, 6, 8, 20)).action, 'recover');
  });
  test('high effort reduces load', () {
    expect(offlineAdvice(const CoachInput(8, 12, 9, 2, 20)).action, 'reduce');
  });
  test('invalid input is rejected', () {
    expect(() => offlineAdvice(const CoachInput(-1, 12, 6, 2, 20)),
      throwsArgumentError);
  });
  test('no endpoint means local advice and no network', () async {
    final result = await CoachService.recommend(
      const CoachInput(12, 12, 6, 2, 20), url: '');
    expect(result.fromPython, isFalse);
    expect(result.action, 'progress');
  });
  test('insecure HTTP endpoint is refused', () async {
    final result = await CoachService.recommend(
      const CoachInput(12, 12, 6, 2, 20),
      url: 'http://example.com/v1/next-session');
    expect(result.fromPython, isFalse);
  });
}
