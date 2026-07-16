import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/profile_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = ProfileStorageService();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  UserProfile? _savedProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _storageService.loadProfile();

      if (!mounted) {
        return;
      }

      if (profile != null) {
        _nameController.text = profile.name;
        _ageController.text = profile.age.toString();
        _weightController.text =
            profile.weightKg.toStringAsFixed(1);
        _heightController.text =
            profile.heightCm.toStringAsFixed(0);
        _targetWeightController.text =
            profile.targetWeightKg.toStringAsFixed(1);
      }

      setState(() {
        _savedProfile = profile;
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
            'Profilul nu a putut fi încărcat.',
          ),
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid || _isSaving) {
      return;
    }

    FocusScope.of(context).unfocus();

    final profile = UserProfile(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text),
      weightKg: _parseDecimal(_weightController.text)!,
      heightCm: _parseDecimal(_heightController.text)!,
      targetWeightKg: _parseDecimal(
        _targetWeightController.text,
      )!,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await _storageService.saveProfile(profile);

      if (!mounted) {
        return;
      }

      setState(() {
        _savedProfile = profile;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profilul a fost salvat.'),
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
            'Profilul nu a putut fi salvat.',
          ),
        ),
      );
    }
  }

  double? _parseDecimal(String value) {
    return double.tryParse(
      value.trim().replaceAll(',', '.'),
    );
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Introdu numele.';
    }

    if (name.length < 2) {
      return 'Numele este prea scurt.';
    }

    return null;
  }

  String? _validateAge(String? value) {
    final age = int.tryParse(value ?? '');

    if (age == null) {
      return 'Introdu o vârstă validă.';
    }

    if (age < 18 || age > 120) {
      return 'Vârsta trebuie să fie între 18 și 120 de ani.';
    }

    return null;
  }

  String? _validateWeight(String? value) {
    final weight = _parseDecimal(value ?? '');

    if (weight == null) {
      return 'Introdu o greutate validă.';
    }

    if (weight < 30 || weight > 350) {
      return 'Greutatea trebuie să fie între 30 și 350 kg.';
    }

    return null;
  }

  String? _validateHeight(String? value) {
    final height = _parseDecimal(value ?? '');

    if (height == null) {
      return 'Introdu o înălțime validă.';
    }

    if (height < 100 || height > 230) {
      return 'Înălțimea trebuie să fie între 100 și 230 cm.';
    }

    return null;
  }

  String? _validateTargetWeight(String? value) {
    final targetWeight = _parseDecimal(value ?? '');

    if (targetWeight == null) {
      return 'Introdu o greutate-țintă validă.';
    }

    if (targetWeight < 30 || targetWeight > 350) {
      return 'Ținta trebuie să fie între 30 și 350 kg.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Date personale',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aceste date sunt păstrate local pe dispozitiv.',
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      validator: _validateName,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nume',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      validator: _validateAge,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Vârstă',
                        suffixText: 'ani',
                        prefixIcon: Icon(Icons.cake_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      validator: _validateWeight,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Greutate actuală',
                        suffixText: 'kg',
                        prefixIcon: Icon(Icons.monitor_weight_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _heightController,
                      validator: _validateHeight,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Înălțime',
                        suffixText: 'cm',
                        prefixIcon: Icon(Icons.height),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetWeightController,
                      validator: _validateTargetWeight,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _saveProfile(),
                      decoration: const InputDecoration(
                        labelText: 'Greutate-țintă',
                        suffixText: 'kg',
                        prefixIcon: Icon(Icons.flag_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _saveProfile,
                      icon: _isSaving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          _isSaving
                              ? 'Se salvează...'
                              : 'Salvează profilul',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    if (_savedProfile != null) ...[
                      const SizedBox(height: 24),
                      _ProfileSummaryCard(
                        profile: _savedProfile!,
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.profile,
  });

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final bmi = profile.bmi;
    final difference =
        profile.weightKg - profile.targetWeightKg;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profil salvat',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 14),
            Text(
              'Bun venit, ${profile.name}!',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Vârstă: ${profile.age} ani',
              style: const TextStyle(fontSize: 17),
            ),
            Text(
              'Greutate: ${profile.weightKg.toStringAsFixed(1)} kg',
              style: const TextStyle(fontSize: 17),
            ),
            Text(
              'Țintă: ${profile.targetWeightKg.toStringAsFixed(1)} kg',
              style: const TextStyle(fontSize: 17),
            ),
            if (bmi != null) ...[
              const SizedBox(height: 8),
              Text(
                'IMC orientativ: ${bmi.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 4),
              Text(
                'Categorie: ${profile.bmiCategory}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              difference > 0
                  ? 'Diferență până la țintă: '
                      '${difference.toStringAsFixed(1)} kg'
                  : 'Ținta a fost atinsă sau depășită.',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'IMC-ul este un indicator general de screening. '
              'Nu ține cont direct de masa musculară, distribuția '
              'grăsimii sau istoricul medical și nu reprezintă '
              'un diagnostic.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}