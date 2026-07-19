import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/health_storage_service.dart';
import '../../services/profile_storage_service.dart';
import '../../services/workout_history_service.dart';
import '../exercises/exercises_screen.dart';
import '../health/health_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProfileStorageService _profileStorageService = ProfileStorageService();

  final HealthStorageService _healthStorageService = HealthStorageService();

  final WorkoutHistoryService _workoutHistoryService = WorkoutHistoryService();

  UserProfile? _profile;
  HealthAssessment? _healthAssessment;

  List<WorkoutSession> _workoutSessions = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final results = await Future.wait<Object?>([
        _profileStorageService.loadProfile(),
        _healthStorageService.loadAssessment(),
        _workoutHistoryService.loadSessions(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _profile = results[0] as UserProfile?;
        _healthAssessment = results[1] as HealthAssessment?;
        _workoutSessions = results[2] as List<WorkoutSession>;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datele aplicației nu au putut fi încărcate.'),
        ),
      );
    }
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const ProfileScreen()),
    );

    await _loadDashboardData();
  }

  Future<void> _openHealthAssessment() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => const HealthScreen()));

    await _loadDashboardData();
  }

  Future<void> _openRecommendedExercises() async {
    final assessment = _healthAssessment;

    if (assessment == null) {
      await _openHealthAssessment();
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ExercisesScreen(
          hasHeartProblems: assessment.hasHeartProblems,
          hasHypertension: assessment.hasHypertension,
          hasKneePain: assessment.hasKneePain,
          hasBalanceProblems: assessment.hasBalanceProblems,
        ),
      ),
    );
  }

  String _encodeQueryParameters(Map<String, String> parameters) {
    return parameters.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}='
              '${Uri.encodeComponent(entry.value)}',
        )
        .join('&');
  }

  Future<void> _sendFeedback() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'care.app.feedback@gmail.com',
      query: _encodeQueryParameters({
        'subject': 'Feedback aplicația CARE',
        'body': '''
Bună,

Am testat aplicația CARE.

1. Ce mi-a plăcut?


2. Ce mi s-a părut neclar sau dificil?


3. Am reușit să finalizez un antrenament?


4. Ce aș îmbunătăți?


Versiunea aplicației: 1.0.0
''',
      }),
    );

    try {
      final wasOpened = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!wasOpened && mounted) {
        _showFeedbackError();
      }
    } catch (_) {
      if (mounted) {
        _showFeedbackError();
      }
    }
  }

  void _showFeedbackError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Nu am găsit o aplicație de email. '
          'Poți trimite feedback la care.app.feedback@gmail.com.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CARE'), centerTitle: true),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 24),
                    if (_profile != null)
                      _buildProfileSummary()
                    else
                      _buildMissingProfileCard(),
                    const SizedBox(height: 20),
                    _buildSafetyProfileCard(),
                    const SizedBox(height: 20),
                    _buildProgressCard(),
                    const SizedBox(height: 20),
                    _buildActionsSection(),
                    const SizedBox(height: 20),
                    _buildMedicalDisclaimerCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final name = _profile?.name.trim();

    return Column(
      children: [
        const Icon(Icons.favorite, color: Colors.red, size: 72),
        const SizedBox(height: 18),
        Text(
          name != null && name.isNotEmpty
              ? 'Bun venit, $name!'
              : 'Bine ai venit!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Mișcare sigură și adaptată pentru persoane 50+',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildProfileSummary() {
    final profile = _profile!;
    final bmi = profile.bmi;
    final difference = profile.weightKg - profile.targetWeightKg;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Rezumatul tău',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _DashboardValueRow(
              label: 'Greutate actuală',
              value: '${profile.weightKg.toStringAsFixed(1)} kg',
              icon: Icons.monitor_weight_outlined,
            ),
            const SizedBox(height: 12),
            _DashboardValueRow(
              label: 'Greutate-țintă',
              value: '${profile.targetWeightKg.toStringAsFixed(1)} kg',
              icon: Icons.flag_outlined,
            ),
            if (bmi != null) ...[
              const SizedBox(height: 12),
              _DashboardValueRow(
                label: 'IMC orientativ',
                value: bmi.toStringAsFixed(1),
                icon: Icons.calculate_outlined,
              ),
              const SizedBox(height: 8),
              Text(
                profile.bmiCategory,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              difference > 0
                  ? 'Mai ai ${difference.toStringAsFixed(1)} kg până la țintă.'
                  : 'Ținta ta a fost atinsă sau depășită.',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _openProfile,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editează profilul'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyProfileCard() {
    final assessment = _healthAssessment;

    if (assessment == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              const Text(
                'Profil de siguranță',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Completează evaluarea pentru a primi un program adaptat.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, height: 1.4),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _openHealthAssessment,
                icon: const Icon(Icons.assignment_outlined),
                label: const Text('Completează evaluarea'),
              ),
            ],
          ),
        ),
      );
    }

    final conditions = _buildConditionLabels(assessment);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.health_and_safety_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Profil de siguranță',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (conditions.isEmpty)
              const Text(
                'Nu au fost raportate limitări în evaluare.',
                style: TextStyle(fontSize: 17, height: 1.4),
              )
            else
              ...conditions.map(
                (condition) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 22,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          condition,
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Program recomandat: ${_buildProgramLevel(assessment)}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _openHealthAssessment,
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Modifică evaluarea'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _buildConditionLabels(HealthAssessment assessment) {
    final conditions = <String>[];

    if (assessment.hasHeartProblems) {
      conditions.add('Afecțiuni cardiace');
    }

    if (assessment.hasHypertension) {
      conditions.add('Hipertensiune');
    }

    if (assessment.hasKneePain) {
      conditions.add('Dureri de genunchi');
    }

    if (assessment.hasBalanceProblems) {
      conditions.add('Probleme de echilibru');
    }

    return conditions;
  }

  String _buildProgramLevel(HealthAssessment assessment) {
    if (assessment.hasHeartProblems || assessment.hasBalanceProblems) {
      return 'intensitate foarte redusă, cu sprijin';
    }

    if (assessment.hasHypertension || assessment.hasKneePain) {
      return 'intensitate redusă';
    }

    return 'standard 50+, nivel începător';
  }

  Widget _buildMissingProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              Icons.person_add_alt_1_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            const Text(
              'Completează profilul',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Adaugă numele, vârsta, greutatea și obiectivul tău.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, height: 1.4),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _openProfile,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Creează profilul'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final completedWorkouts = _workoutSessions.length;

    final totalSeconds = _workoutSessions.fold<int>(
      0,
      (total, session) => total + session.durationSeconds,
    );

    final totalExercises = _workoutSessions.fold<int>(
      0,
      (total, session) => total + session.exerciseCount,
    );

    final lastSession = _workoutSessions.isEmpty
        ? null
        : _workoutSessions.first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Progresul meu',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_workoutSessions.isEmpty) ...[
              const Text(
                'Nu ai încă antrenamente finalizate.',
                style: TextStyle(fontSize: 17, height: 1.4),
              ),
              const SizedBox(height: 8),
              const Text(
                'Finalizează primul program pentru a vedea progresul aici.',
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
            ] else ...[
              _ProgressValueRow(
                icon: Icons.check_circle_outline,
                label: 'Antrenamente finalizate',
                value: completedWorkouts.toString(),
              ),
              const SizedBox(height: 12),
              _ProgressValueRow(
                icon: Icons.timer_outlined,
                label: 'Timp total activ',
                value: _formatTotalDuration(totalSeconds),
              ),
              const SizedBox(height: 12),
              _ProgressValueRow(
                icon: Icons.fitness_center_outlined,
                label: 'Exerciții efectuate',
                value: totalExercises.toString(),
              ),
              if (lastSession != null) ...[
                const SizedBox(height: 12),
                _ProgressValueRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Ultimul antrenament',
                  value: _formatWorkoutDate(lastSession.completedAt),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _formatTotalDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }

    if (minutes > 0) {
      return '${minutes}min ${seconds}s';
    }

    return '${seconds}s';
  }

  String _formatWorkoutDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final workoutDay = DateTime(date.year, date.month, date.day);

    final difference = today.difference(workoutDay).inDays;

    if (difference == 0) {
      return 'Astăzi';
    }

    if (difference == 1) {
      return 'Ieri';
    }

    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Planul tău',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _openRecommendedExercises,
            icon: const Icon(Icons.play_arrow),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Continuă programul recomandat',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openHealthAssessment,
            icon: const Icon(Icons.favorite_outline),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Text('Evaluare sănătate', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openProfile,
            icon: const Icon(Icons.person_outline),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Text('Profilul meu', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),

        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _sendFeedback,
            icon: const Icon(Icons.feedback_outlined),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Text('Trimite feedback', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalDisclaimerCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'CARE oferă recomandări generale și nu înlocuiește '
                'evaluarea sau indicațiile medicului.',
                style: TextStyle(fontSize: 16, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardValueRow extends StatelessWidget {
  const _DashboardValueRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 26, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 17))),
        Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ProgressValueRow extends StatelessWidget {
  const _ProgressValueRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 26, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 17))),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
