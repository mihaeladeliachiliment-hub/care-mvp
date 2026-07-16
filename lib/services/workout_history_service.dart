import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.completedAt,
    required this.durationSeconds,
    required this.exerciseCount,
  });

  final String id;
  final DateTime completedAt;
  final int durationSeconds;
  final int exerciseCount;

  Map<String, Object> toJson() {
    return {
      'id': id,
      'completedAt': completedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'exerciseCount': exerciseCount,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      durationSeconds: json['durationSeconds'] as int,
      exerciseCount: json['exerciseCount'] as int,
    );
  }
}

class WorkoutHistoryService {
  WorkoutHistoryService({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _historyKey = 'workout.history';

  final SharedPreferencesAsync _preferences;

  Future<List<WorkoutSession>> loadSessions() async {
    final storedValue = await _preferences.getString(_historyKey);

    if (storedValue == null || storedValue.isEmpty) {
      return [];
    }

    try {
      final decodedValue = jsonDecode(storedValue);

      if (decodedValue is! List) {
        return [];
      }

      final sessions = decodedValue
          .whereType<Map<String, dynamic>>()
          .map(WorkoutSession.fromJson)
          .toList();

      sessions.sort(
        (first, second) =>
            second.completedAt.compareTo(first.completedAt),
      );

      return sessions;
    } catch (_) {
      return [];
    }
  }

  Future<void> addSession(WorkoutSession session) async {
    final sessions = await loadSessions();

    final updatedSessions = [
      session,
      ...sessions.where(
        (existingSession) => existingSession.id != session.id,
      ),
    ];

    final encodedValue = jsonEncode(
      updatedSessions
          .take(100)
          .map((storedSession) => storedSession.toJson())
          .toList(),
    );

    await _preferences.setString(_historyKey, encodedValue);
  }

  Future<void> deleteAllSessions() async {
    await _preferences.remove(_historyKey);
  }
}