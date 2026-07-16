import 'package:flutter/material.dart';

import '../../services/health_storage_service.dart';
import '../exercises/exercises_screen.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final HealthStorageService _storageService =
      HealthStorageService();

  bool _hasHeartProblems = false;
  bool _hasHypertension = false;
  bool _hasKneePain = false;
  bool _hasBalanceProblems = false;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAssessment();
  }

  Future<void> _loadAssessment() async {
    try {
      final assessment =
          await _storageService.loadAssessment();

      if (!mounted) {
        return;
      }

      setState(() {
        _hasHeartProblems = assessment.hasHeartProblems;
        _hasHypertension = assessment.hasHypertension;
        _hasKneePain = assessment.hasKneePain;
        _hasBalanceProblems =
            assessment.hasBalanceProblems;
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
          content: Text(
            'Evaluarea nu a putut fi încărcată.',
          ),
        ),
      );
    }
  }

  Future<void> _saveAndContinue() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final assessment = HealthAssessment(
      hasHeartProblems: _hasHeartProblems,
      hasHypertension: _hasHypertension,
      hasKneePain: _hasKneePain,
      hasBalanceProblems: _hasBalanceProblems,
    );

    try {
      await _storageService.saveAssessment(assessment);

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => ExercisesScreen(
            hasHeartProblems:
                assessment.hasHeartProblems,
            hasHypertension:
                assessment.hasHypertension,
            hasKneePain: assessment.hasKneePain,
            hasBalanceProblems:
                assessment.hasBalanceProblems,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Evaluarea nu a putut fi salvată.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluare sănătate'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Selectează situațiile care se aplică:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Răspunsurile vor fi păstrate local pe dispozitiv.',
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _HealthOptionCard(
                    title: 'Afecțiuni cardiace',
                    description:
                        'Selectează dacă ai o afecțiune cardiacă diagnosticată.',
                    icon: Icons.favorite_outline,
                    value: _hasHeartProblems,
                    onChanged: (value) {
                      setState(() {
                        _hasHeartProblems = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _HealthOptionCard(
                    title: 'Hipertensiune',
                    description:
                        'Selectează dacă ai tensiune arterială crescută.',
                    icon: Icons.monitor_heart_outlined,
                    value: _hasHypertension,
                    onChanged: (value) {
                      setState(() {
                        _hasHypertension = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _HealthOptionCard(
                    title: 'Dureri de genunchi',
                    description:
                        'Selectează dacă mișcarea îți provoacă disconfort la genunchi.',
                    icon: Icons.accessibility_new,
                    value: _hasKneePain,
                    onChanged: (value) {
                      setState(() {
                        _hasKneePain = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _HealthOptionCard(
                    title: 'Probleme de echilibru',
                    description:
                        'Selectează dacă ai instabilitate sau risc de cădere.',
                    icon: Icons.assist_walker_outlined,
                    value: _hasBalanceProblems,
                    onChanged: (value) {
                      setState(() {
                        _hasBalanceProblems = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Aplicația nu stabilește diagnostice și nu '
                              'înlocuiește recomandările medicului.',
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
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed:
                        _isSaving ? null : _saveAndContinue,
                    icon: _isSaving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      child: Text(
                        _isSaving
                            ? 'Se salvează...'
                            : 'Salvează și continuă',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _HealthOptionCard extends StatelessWidget {
  const _HealthOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }
}