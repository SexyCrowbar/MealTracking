import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/photo_cleanup.dart';
import '../../core/theme.dart';
import '../../data/repositories/meals_repo.dart';
import '../../domain/models/meal_analysis.dart';
import '../../domain/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/dialogs.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({
    super.key,
    required this.analysis,
    required this.hadText,
    this.hadImage = true,
    this.imageFile,
  });

  final MealAnalysis analysis;
  final bool hadText;
  final bool hadImage;
  final File? imageFile;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late final _name =
      TextEditingController(text: widget.analysis.name);
  late final _kcal =
      TextEditingController(text: widget.analysis.calories.toString());
  late final _protein = TextEditingController(
      text: widget.analysis.protein.toStringAsFixed(1));
  late final _carbs =
      TextEditingController(text: widget.analysis.carbs.toStringAsFixed(1));
  late final _fat =
      TextEditingController(text: widget.analysis.fat.toStringAsFixed(1));
  late final _gi = TextEditingController(
      text: widget.analysis.glycemicIndex?.toString() ?? '');

  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    _gi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final a = widget.analysis;
    final showGi = ref.watch(settingsStreamProvider).value?.showGi ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(t.ai_analysis)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.md),
        children: [
          if (a.allergenWarning != null && a.allergenWarning!.isNotEmpty)
            Card(
              color: AppColors.accentRed.withValues(alpha: 0.18),
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.md),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.accentRed),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Text(
                        '${t.allergen_warning}: ${a.allergenWarning}',
                        style: const TextStyle(color: AppColors.textMain),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Text(
            t.tap_to_edit,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: AppSpace.sm),
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: t.food_name),
          ),
          const SizedBox(height: AppSpace.sm),
          TextField(
            controller: _kcal,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: t.calories),
          ),
          const SizedBox(height: AppSpace.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _protein,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: t.protein),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: TextField(
                  controller: _carbs,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: t.carbs),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: TextField(
                  controller: _fat,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: t.fat),
                ),
              ),
            ],
          ),
          if (showGi) ...[
            const SizedBox(height: AppSpace.sm),
            TextField(
              controller: _gi,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t.glycemic_index),
            ),
          ],
          if (a.estimatedInsulin != null) ...[
            const SizedBox(height: AppSpace.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.md),
                child: Row(
                  children: [
                    const Icon(Icons.medical_information_outlined,
                        color: AppColors.accentBlue),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Text(
                        '${t.estimated_insulin_meal}: '
                        '${a.estimatedInsulin!.toStringAsFixed(1)} ${t.units}',
                        style: const TextStyle(color: AppColors.textMain),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpace.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(t.save_to_log),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _saving ? null : _discard,
              child: Text(t.discard),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final name = _name.text.trim();
    final kcal = int.tryParse(_kcal.text.trim());
    if (name.isEmpty || kcal == null || kcal < 0) {
      showAppSnack(context, t.provide_text_image);
      return;
    }
    setState(() => _saving = true);
    final updated = widget.analysis.copyWith(
      name: name,
      calories: kcal,
      protein: double.tryParse(_protein.text.trim()) ?? widget.analysis.protein,
      carbs: double.tryParse(_carbs.text.trim()) ?? widget.analysis.carbs,
      fat: double.tryParse(_fat.text.trim()) ?? widget.analysis.fat,
      glycemicIndex: int.tryParse(_gi.text.trim()),
    );
    await ref.read(mealsRepoProvider).insertFromAnalysis(
          updated,
          source: MealsRepository.sourceFor(
            hadImage: widget.hadImage,
            hadText: widget.hadText,
          ),
        );
    await PhotoCleanup.tryDelete(widget.imageFile?.path);
    if (!mounted) return;
    showAppSnack(context, t.meal_added);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _discard() async {
    await PhotoCleanup.tryDelete(widget.imageFile?.path);
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
