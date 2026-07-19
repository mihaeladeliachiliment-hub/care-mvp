import 'package:flutter/material.dart';

import '../workout/workout_screen.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({
    required this.hasHeartProblems,
    required this.hasHypertension,
    required this.hasKneePain,
    required this.hasBalanceProblems,
    super.key,
  });

  final bool hasHeartProblems;
  final bool hasHypertension;
  final bool hasKneePain;
  final bool hasBalanceProblems;

  List<ExerciseRecommendation> _buildRecommendations() {
    final recommendations = <ExerciseRecommendation>[
      const ExerciseRecommendation(
        title: 'Respirație calmă',
        description:
            'Stai confortabil pe un scaun și respiră lent, fără să forțezi.',
        duration: '20 de secunde',
        icon: Icons.air,
      ),
      const ExerciseRecommendation(
        title: 'Rotiri ușoare ale umerilor',
        description: 'Execută mișcări lente ale umerilor, fără mișcări bruște.',
        duration: '15 secunde',
        icon: Icons.accessibility_new,
      ),
      const ExerciseRecommendation(
        title: 'Mobilizarea gleznelor din șezut',
        description:
            'Ridică ușor vârfurile și călcâiele alternativ, stând pe scaun.',
        duration: '20 de secunde',
        icon: Icons.airline_seat_recline_normal,
      ),
    ];

    if (!hasBalanceProblems) {
      recommendations.add(
        const ExerciseRecommendation(
          title: 'Mers lent pe loc cu sprijin',
          description:
              'Mergi lent pe loc lângă un scaun stabil, pe care îl poți folosi pentru sprijin.',
          duration: '30 de secunde',
          icon: Icons.directions_walk,
        ),
      );
    }

    if (hasKneePain) {
      recommendations.add(
        const ExerciseRecommendation(
          title: 'Extensia piciorului din șezut',
          description:
              'Îndreaptă ușor câte un picior, numai în limita confortului.',
          duration: '20 de secunde sau maximum 6 repetări pe fiecare parte',
          icon: Icons.event_seat,
        ),
      );
    } else {
      recommendations.add(
        const ExerciseRecommendation(
          title: 'Ridicări ușoare de pe scaun',
          description:
              'Ridică-te lent de pe un scaun stabil și așază-te controlat.',
          duration: '20 de secunde sau maximum 5 repetări',
          icon: Icons.chair_alt,
        ),
      );
    }

    return recommendations;
  }

  String _buildSafetyMessage() {
    if (hasHeartProblems || hasHypertension) {
      return 'Ai indicat o afecțiune cardiovasculară sau hipertensiune. '
          'Urmează numai nivelul de activitate aprobat de medic și oprește '
          'exercițiul dacă apar simptome neobișnuite.';
    }

    if (hasBalanceProblems) {
      return 'Pentru siguranță, efectuează exercițiile așezat sau lângă '
          'un suport stabil.';
    }

    if (hasKneePain) {
      return 'Nu continua nicio mișcare care accentuează durerea. '
          'Execută exercițiile lent și numai în limita confortului.';
    }

    return 'Începe lent și păstrează un ritm confortabil.';
  }

  String _buildEstimatedDuration(List<ExerciseRecommendation> recommendations) {
    if (recommendations.length <= 4) {
      return 'aproximativ 2 minute';
    }

    return 'aproximativ 2–3 minute';
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = _buildRecommendations();
    final estimatedDuration = _buildEstimatedDuration(recommendations);

    return Scaffold(
      appBar: AppBar(title: const Text('Exerciții recomandate')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.health_and_safety_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _buildSafetyMessage(),
                      style: const TextStyle(fontSize: 17, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Plan introductiv',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Exerciții generale, cu intensitate redusă.',
              style: TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Durata totală estimată a antrenamentului: '
                        '$estimatedDuration, inclusiv pauzele dintre '
                        'exerciții.',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...recommendations.map(
              (exercise) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          exercise.icon,
                          size: 38,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                exercise.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Durată ghidată: ${exercise.duration}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        WorkoutScreen(exercises: recommendations),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Începe planul', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseRecommendation {
  const ExerciseRecommendation({
    required this.title,
    required this.description,
    required this.duration,
    required this.icon,
  });

  final String title;
  final String description;
  final String duration;
  final IconData icon;
}
