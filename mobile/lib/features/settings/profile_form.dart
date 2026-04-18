import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../domain/models/profile.dart';
import '../../l10n/app_localizations.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({
    super.key,
    this.initial,
    required this.onSubmit,
    this.submitLabel,
  });

  final Profile? initial;
  final ValueChanged<Profile> onSubmit;
  final String? submitLabel;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final _ageCtrl =
      TextEditingController(text: widget.initial?.age.toString() ?? '');
  late final _heightCtrl =
      TextEditingController(text: widget.initial?.heightCm.toString() ?? '');
  late final _weightCtrl =
      TextEditingController(text: widget.initial?.weightKg.toString() ?? '');
  late final _goalCtrl = TextEditingController(
      text: widget.initial?.goalWeightKg.toString() ?? '');
  late String _gender = widget.initial?.gender ?? Gender.male;
  late String _activity =
      widget.initial?.activityLevel ?? ActivityLevel.moderate;
  String? _error;

  @override
  void dispose() {
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      children: [
        TextField(
          controller: _ageCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: t.age),
        ),
        const SizedBox(height: AppSpace.sm),
        DropdownButtonFormField<String>(
          initialValue: _gender,
          decoration: InputDecoration(labelText: t.gender),
          items: [
            DropdownMenuItem(value: Gender.male, child: Text(t.male)),
            DropdownMenuItem(value: Gender.female, child: Text(t.female)),
          ],
          onChanged: (v) => setState(() => _gender = v ?? Gender.male),
        ),
        const SizedBox(height: AppSpace.sm),
        TextField(
          controller: _heightCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: t.height),
        ),
        const SizedBox(height: AppSpace.sm),
        TextField(
          controller: _weightCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: t.weight),
        ),
        const SizedBox(height: AppSpace.sm),
        TextField(
          controller: _goalCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: t.goal_weight),
        ),
        const SizedBox(height: AppSpace.sm),
        DropdownButtonFormField<String>(
          initialValue: _activity,
          decoration: InputDecoration(labelText: t.activity_level),
          items: [
            DropdownMenuItem(
                value: ActivityLevel.sedentary, child: Text(t.sedentary)),
            DropdownMenuItem(
                value: ActivityLevel.light, child: Text(t.light)),
            DropdownMenuItem(
                value: ActivityLevel.moderate, child: Text(t.moderate)),
            DropdownMenuItem(
                value: ActivityLevel.active, child: Text(t.active)),
            DropdownMenuItem(
                value: ActivityLevel.extra, child: Text(t.extra)),
          ],
          onChanged: (v) =>
              setState(() => _activity = v ?? ActivityLevel.moderate),
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpace.sm),
          Text(_error!, style: const TextStyle(color: AppColors.accentRed)),
        ],
        const SizedBox(height: AppSpace.md),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onSubmit,
            child: Text(widget.submitLabel ?? t.save_settings),
          ),
        ),
      ],
    );
  }

  void _onSubmit() {
    final age = int.tryParse(_ageCtrl.text);
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    final g = double.tryParse(_goalCtrl.text);
    if (age == null || age < 10 || age > 120 ||
        h == null || h < 80 || h > 250 ||
        w == null || w < 30 || w > 400 ||
        g == null || g < 30 || g > 400) {
      setState(() => _error = 'Please enter valid values');
      return;
    }
    setState(() => _error = null);
    widget.onSubmit(Profile(
      age: age,
      gender: _gender,
      heightCm: h,
      weightKg: w,
      goalWeightKg: g,
      activityLevel: _activity,
    ));
  }
}
