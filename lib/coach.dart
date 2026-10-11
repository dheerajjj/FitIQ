import 'dart:convert';
import 'package:http/http.dart' as http;

/// Workout guidance, not medical advice. The offline algorithm mirrors
/// intelligence/coach.py and remains available without an internet connection.
class CoachAdvice {
  final String action;
  final double weightKg;
  final String reason;
  final bool fromPython;
  const CoachAdvice(this.action, this.weightKg, this.reason, {this.fromPython = false});
}

class CoachInput {
  final int completedReps, targetReps, effort, soreness;
  final double weightKg;
  const CoachInput(this.completedReps, this.targetReps, this.effort, this.soreness, this.weightKg);
  void validate() {
    if (completedReps < 0 || completedReps > 1000 ||
        targetReps < 1 || targetReps > 1000 ||
        effort < 1 || effort > 10 || soreness < 0 || soreness > 10 ||
        !weightKg.isFinite || weightKg < 0 || weightKg > 1000) {
      throw ArgumentError('Invalid session metrics');
    }
  }
  Map<String, dynamic> toJson() => {
    'completed_reps': completedReps, 'target_reps': targetReps,
    'effort': effort, 'soreness': soreness, 'weight_kg': weightKg,
  };
}

double _round2(double n) => (n * 100).round() / 100;

CoachAdvice offlineAdvice(CoachInput s) {
  s.validate();
  if (s.soreness >= 7) {
    return CoachAdvice('recover', s.weightKg, 'High soreness: prioritize recovery');
  }
  if (s.effort >= 9 || s.completedReps < s.targetReps) {
    return CoachAdvice('reduce', _round2(s.weightKg * 0.95),
        'Reduce load to improve quality');
  }
  if (s.completedReps >= s.targetReps && s.effort <= 7 && s.soreness <= 4) {
    return CoachAdvice('progress', _round2(s.weightKg * 1.025),
        'Small progressive overload');
  }
  return CoachAdvice('maintain', s.weightKg, 'Repeat and consolidate');
}

/// Python service is optional and must be deployed separately over HTTPS.
/// By default, NO health data leaves the device. Network errors fall back
/// to deterministic local guidance.
class CoachService {
  static const endpoint = String.fromEnvironment('FITIQ_COACH_URL', defaultValue: '');
  static Future<CoachAdvice> recommend(CoachInput input, {String? url}) async {
    input.validate();
    final configured = url ?? endpoint;
    final uri = Uri.tryParse(configured);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty ||
        uri.userInfo.isNotEmpty || uri.hasFragment) {
      return offlineAdvice(input);
    }
    try {
      final response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(input.toJson()),
      ).timeout(const Duration(seconds: 4));
      if (response.statusCode != 200) return offlineAdvice(input);
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) return offlineAdvice(input);
      final action = data['action'];
      final weight = data['weight_kg'];
      final reason = data['reason'];
      if (!['recover', 'reduce', 'progress', 'maintain'].contains(action) ||
          weight is! num || !weight.isFinite || weight < 0 ||
          weight > 1000 || reason is! String || reason.length > 200) {
        return offlineAdvice(input);
      }
      return CoachAdvice(action as String, weight.toDouble(), reason, fromPython: true);
    } catch (_) {
      return offlineAdvice(input);
    }
  }
}
