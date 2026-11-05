import 'package:care/services/workout_history_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

WorkoutSession buildSession(String id, DateTime completedAt) {
  return WorkoutSession(
    id: id,
    completedAt: completedAt,
    durationSeconds: 600,
    exerciseCount: 5,
  );
}

void main() {
  late WorkoutHistoryService service;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    service = WorkoutHistoryService();
  });

  group('WorkoutHistoryService', () {
    test('returnează o listă goală când nu există istoric', () async {
      final sessions = await service.loadSessions();

      expect(sessions, isEmpty);
    });

    test('salvează și încarcă un antrenament cu toate datele', () async {
      final completedAt = DateTime(2026, 11, 1, 10, 30);
      await service.addSession(
        WorkoutSession(
          id: 'a',
          completedAt: completedAt,
          durationSeconds: 754,
          exerciseCount: 6,
        ),
      );

      final sessions = await service.loadSessions();

      expect(sessions, hasLength(1));
      expect(sessions.first.id, 'a');
      expect(sessions.first.completedAt, completedAt);
      expect(sessions.first.durationSeconds, 754);
      expect(sessions.first.exerciseCount, 6);
    });

    test('ordonează antrenamentele de la cel mai recent', () async {
      await service.addSession(buildSession('vechi', DateTime(2026, 10, 1)));
      await service.addSession(buildSession('nou', DateTime(2026, 11, 1)));
      await service.addSession(buildSession('mijloc', DateTime(2026, 10, 15)));

      final sessions = await service.loadSessions();

      expect(sessions.map((session) => session.id), ['nou', 'mijloc', 'vechi']);
    });

    test('nu dublează un antrenament salvat de două ori', () async {
      await service.addSession(buildSession('a', DateTime(2026, 11, 1)));
      await service.addSession(buildSession('a', DateTime(2026, 11, 1)));

      final sessions = await service.loadSessions();

      expect(sessions, hasLength(1));
    });

    test('păstrează doar cele mai recente 100 de antrenamente', () async {
      final start = DateTime(2026, 1, 1);
      for (var index = 0; index < 101; index++) {
        await service.addSession(
          buildSession('s$index', start.add(Duration(hours: index))),
        );
      }

      final sessions = await service.loadSessions();

      expect(sessions, hasLength(100));
      expect(sessions.first.id, 's100');
      expect(sessions.any((session) => session.id == 's0'), isFalse);
    });

    test('șterge tot istoricul', () async {
      await service.addSession(buildSession('a', DateTime(2026, 11, 1)));

      await service.deleteAllSessions();

      expect(await service.loadSessions(), isEmpty);
    });

    test('nu se blochează dacă datele salvate sunt corupte', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
        'workout.history': 'date invalide',
      });
      service = WorkoutHistoryService();

      expect(await service.loadSessions(), isEmpty);
    });

    test('ignoră datele salvate care nu sunt o listă', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
        'workout.history': '{"id": "a"}',
      });
      service = WorkoutHistoryService();

      expect(await service.loadSessions(), isEmpty);
    });
  });
}
