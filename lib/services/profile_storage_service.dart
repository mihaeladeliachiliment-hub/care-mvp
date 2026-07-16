import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.targetWeightKg,
  });

  final String name;
  final int age;
  final double weightKg;
  final double heightCm;
  final double targetWeightKg;

  double get heightMeters => heightCm / 100;

  double? get bmi {
    final height = heightMeters;

    if (height <= 0) {
      return null;
    }

    return weightKg / (height * height);
  }

  String get bmiCategory {
    final value = bmi;

    if (value == null) {
      return 'Indisponibil';
    }

    if (value < 18.5) {
      return 'Sub greutatea orientativă';
    }

    if (value < 25) {
      return 'Interval orientativ normal';
    }

    if (value < 30) {
      return 'Peste intervalul orientativ';
    }

    return 'Valoare ridicată';
  }
}

class ProfileStorageService {
  ProfileStorageService({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _nameKey = 'profile.name';
  static const String _ageKey = 'profile.age';
  static const String _weightKey = 'profile.weightKg';
  static const String _heightKey = 'profile.heightCm';
  static const String _targetWeightKey = 'profile.targetWeightKg';

  final SharedPreferencesAsync _preferences;

  Future<void> saveProfile(UserProfile profile) async {
    await Future.wait([
      _preferences.setString(_nameKey, profile.name),
      _preferences.setInt(_ageKey, profile.age),
      _preferences.setDouble(_weightKey, profile.weightKg),
      _preferences.setDouble(_heightKey, profile.heightCm),
      _preferences.setDouble(
        _targetWeightKey,
        profile.targetWeightKg,
      ),
    ]);
  }

  Future<UserProfile?> loadProfile() async {
    final name = await _preferences.getString(_nameKey);
    final age = await _preferences.getInt(_ageKey);
    final weight = await _preferences.getDouble(_weightKey);
    final height = await _preferences.getDouble(_heightKey);
    final targetWeight =
        await _preferences.getDouble(_targetWeightKey);

    if (name == null ||
        age == null ||
        weight == null ||
        height == null ||
        targetWeight == null) {
      return null;
    }

    return UserProfile(
      name: name,
      age: age,
      weightKg: weight,
      heightCm: height,
      targetWeightKg: targetWeight,
    );
  }

  Future<void> deleteProfile() async {
    await Future.wait([
      _preferences.remove(_nameKey),
      _preferences.remove(_ageKey),
      _preferences.remove(_weightKey),
      _preferences.remove(_heightKey),
      _preferences.remove(_targetWeightKey),
    ]);
  }
}