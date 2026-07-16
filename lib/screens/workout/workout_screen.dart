import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/workout_history_service.dart';
import '../exercises/exercises_screen.dart';

enum WorkoutPhase {
  exercise,
  rest,
  finished,
}

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({
    required this.exercises,
    super.key,
  });

  final List<ExerciseRecommendation> exercises;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  static const int restDurationSeconds = 10;

  final WorkoutHistoryService _historyService =
      WorkoutHistoryService();

  Timer? _timer;

  int _currentExerciseIndex = 0;
  int _remainingSeconds = 30;
  int _elapsedSeconds = 0;

  bool _isRunning = false;
  bool _isSavingHistory = false;
  bool _historyWasSaved = false;

  WorkoutPhase _phase = WorkoutPhase.exercise;

  ExerciseRecommendation get _currentExercise =>
      widget.exercises[_currentExerciseIndex];

  bool get _isLastExercise =>
      _currentExerciseIndex == widget.exercises.length - 1;

  int get _exerciseDurationSeconds {
    final title = _currentExercise.title.toLowerCase();

    // Duratele scurte sunt păstrate momentan pentru testarea MVP.
    if (title.contains('respirație')) {
      return 20;
    }

    if (title.contains('umerilor')) {
      return 15;
    }

    if (title.contains('gleznelor')) {
      return 20;
    }

    if (title.contains('mers')) {
      return 30;
    }

    return 20;
  }

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _exerciseDurationSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning || _phase == WorkoutPhase.finished) {
      return;
    }

    setState(() {
      _isRunning = true;
    });

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _elapsedSeconds++;
        });

        if (_remainingSeconds > 1) {
          setState(() {
            _remainingSeconds--;
          });
          return;
        }

        timer.cancel();
        _handlePhaseCompletion();
      },
    );
  }

  void _pauseTimer() {
    _timer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _handlePhaseCompletion() async {
    if (_phase == WorkoutPhase.exercise) {
      if (_isLastExercise) {
        setState(() {
          _phase = WorkoutPhase.finished;
          _isRunning = false;
          _remainingSeconds = 0;
        });

        await _saveCompletedWorkout();
        return;
      }

      setState(() {
        _phase = WorkoutPhase.rest;
        _remainingSeconds = restDurationSeconds;
        _isRunning = false;
      });

      return;
    }

    if (_phase == WorkoutPhase.rest) {
      setState(() {
        _currentExerciseIndex++;
        _phase = WorkoutPhase.exercise;
        _remainingSeconds = _exerciseDurationSeconds;
        _isRunning = false;
      });
    }
  }

  Future<void> _skipCurrentPhase() async {
    _timer?.cancel();
    await _handlePhaseCompletion();
  }

  Future<void> _saveCompletedWorkout() async {
    if (_historyWasSaved || _isSavingHistory) {
      return;
    }

    setState(() {
      _isSavingHistory = true;
    });

    final completedAt = DateTime.now();

    final session = WorkoutSession(
      id: completedAt.microsecondsSinceEpoch.toString(),
      completedAt: completedAt,
      durationSeconds: _elapsedSeconds,
      exerciseCount: widget.exercises.length,
    );

    try {
      await _historyService.addSession(session);

      if (!mounted) {
        return;
      }

      setState(() {
        _historyWasSaved = true;
        _isSavingHistory = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSavingHistory = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Antrenamentul a fost finalizat, dar istoricul nu a putut fi salvat.',
          ),
        ),
      );
    }
  }

  Future<void> _showStopWorkoutDialog() async {
    _pauseTimer();

    final shouldStop = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Oprești antrenamentul?'),
          content: const Text(
            'Este în regulă să te oprești. Siguranța și starea ta de bine '
            'sunt mai importante decât finalizarea planului.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Revin la antrenament'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Oprește'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldStop != true) {
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _showSafetyDialog() async {
    _pauseTimer();

    final leaveWorkout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            size: 52,
            color: Theme.of(dialogContext).colorScheme.error,
          ),
          title: const Text(
            'Oprește exercițiul',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Așază-te sau întinde-te într-o poziție sigură și nu relua '
            'antrenamentul.\n\n'
            'Dacă ai durere sau presiune în piept, dificultăți importante '
            'de respirație, amețeală puternică, leșin ori simptome severe, '
            'solicită imediat ajutor medical.',
            style: TextStyle(
              fontSize: 17,
              height: 1.45,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Încheie antrenamentul'),
            ),
          ],
        );
      },
    );

    if (!mounted || leaveWorkout != true) {
      return;
    }

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remaining.toString().padLeft(2, '0')}';
  }

  String get _phaseTitle {
    if (_phase == WorkoutPhase.rest) {
      return 'Pauză';
    }

    return _currentExercise.title;
  }

  String get _phaseDescription {
    if (_phase == WorkoutPhase.rest) {
      return 'Respiră normal, relaxează-te și pregătește-te pentru '
          'următorul exercițiu.';
    }

    return _currentExercise.description;
  }

  IconData get _phaseIcon {
    if (_phase == WorkoutPhase.rest) {
      return Icons.self_improvement;
    }

    return _currentExercise.icon;
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == WorkoutPhase.finished) {
      return _buildFinishedScreen(context);
    }

    final progress =
        (_currentExerciseIndex + 1) / widget.exercises.length;

    final isResting = _phase == WorkoutPhase.rest;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isResting ? 'Pauză de recuperare' : 'Antrenament ghidat',
        ),
        actions: [
          IconButton(
            tooltip: 'Oprește antrenamentul',
            onPressed: _showStopWorkoutDialog,
            icon: const Icon(Icons.stop_circle_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Exercițiul ${_currentExerciseIndex + 1} din '
              '${widget.exercises.length}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 32),
            Icon(
              _phaseIcon,
              size: 90,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              _phaseTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _phaseDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),
            if (!isResting) ...[
              const SizedBox(height: 14),
              Text(
                'Recomandare: ${_currentExercise.duration}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 34),
            Text(
              _formatTime(_remainingSeconds),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _isRunning ? _pauseTimer : _startTimer,
              icon: Icon(
                _isRunning ? Icons.pause : Icons.play_arrow,
              ),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  _isRunning ? 'Pauză' : 'Pornește',
                  style: const TextStyle(fontSize: 19),
                ),
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _skipCurrentPhase,
              icon: Icon(
                isResting ? Icons.skip_next : Icons.fast_forward,
              ),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  isResting
                      ? 'Începe următorul exercițiu'
                      : 'Treci peste acest exercițiu',
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.error,
                  foregroundColor:
                      Theme.of(context).colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _showSafetyDialog,
                icon: const Icon(Icons.sos),
                label: const Text(
                  'Mă simt rău',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.health_and_safety_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Nu continua prin durere, amețeală sau dificultăți '
                        'neobișnuite de respirație. Odihna face parte din '
                        'progres.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishedScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antrenament finalizat'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Felicitări!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ai terminat planul introductiv. Chiar și câteva minute '
                  'de mișcare contează.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Durată: ${_formatTime(_elapsedSeconds)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Exerciții: ${widget.exercises.length}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 14),
                if (_isSavingHistory)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('Se salvează progresul...'),
                    ],
                  )
                else if (_historyWasSaved)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_done_outlined),
                      SizedBox(width: 8),
                      Text('Antrenamentul a fost salvat.'),
                    ],
                  ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _isSavingHistory
                      ? null
                      : () {
                          Navigator.of(context).popUntil(
                            (route) => route.isFirst,
                          );
                        },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Text(
                      'Înapoi la pagina principală',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}