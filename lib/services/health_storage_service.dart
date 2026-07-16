import 'package:shared_preferences/shared_preferences.dart';

class HealthAssessment {
  const HealthAssessment({
    required this.hasHeartProblems,
    required this.hasHypertension,
    required this.hasKneePain,
    required this.hasBalanceProblems,
  });

  final bool hasHeartProblems;
  final bool hasHypertension;
  final bool hasKneePain;
  final bool hasBalanceProblems;

  bool get hasAnyCondition =>
      hasHeartProblems ||
      hasHypertension ||
      hasKneePain ||
      hasBalanceProblems;
}

class HealthStorageService {
  HealthStorageService({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _heartProblemsKey =
      'health.hasHeartProblems';
  static const String _hypertensionKey =
      'health.hasHypertension';
  static const String _kneePainKey = 'health.hasKneePain';
  static const String _balanceProblemsKey =
      'health.hasBalanceProblems';

  final SharedPreferencesAsync _preferences;

  Future<void> saveAssessment(
    HealthAssessment assessment,
  ) async {
    await Future.wait([
      _preferences.setBool(
        _heartProblemsKey,
        assessment.hasHeartProblems,
      ),
      _preferences.setBool(
        _hypertensionKey,
        assessment.hasHypertension,
      ),
      _preferences.setBool(
        _kneePainKey,
        assessment.hasKneePain,
      ),
      _preferences.setBool(
        _balanceProblemsKey,
        assessment.hasBalanceProblems,
      ),
    ]);
  }

  Future<HealthAssessment> loadAssessment() async {
    return HealthAssessment(
      hasHeartProblems:
          await _preferences.getBool(_heartProblemsKey) ?? false,
      hasHypertension:
          await _preferences.getBool(_hypertensionKey) ?? false,
      hasKneePain:
          await _preferences.getBool(_kneePainKey) ?? false,
      hasBalanceProblems:
          await _preferences.getBool(_balanceProblemsKey) ?? false,
    );
  }

  Future<void> deleteAssessment() async {
    await Future.wait([
      _preferences.remove(_heartProblemsKey),
      _preferences.remove(_hypertensionKey),
      _preferences.remove(_kneePainKey),
      _preferences.remove(_balanceProblemsKey),
    ]);
  }
}