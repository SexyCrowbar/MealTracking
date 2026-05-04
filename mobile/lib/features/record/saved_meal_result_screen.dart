import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/repositories/saved_meals_repo.dart';
import '../../domain/models/meal_analysis.dart';
import '../../domain/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/dialogs.dart';

class SavedMealResultScreen extends ConsumerStatefulWidget {
  const SavedMealResultScreen({
    super.key,
    required this.name,
    required this.ingredients,
    required this.analysis,
    required this.editingId,
    this.providerName,
    this.modelName,
  });

  final String name;
  final List<RecipeIngredientInput> ingredients;
  final MealAnalysis? analysis;
  final int? editingId;
  final String? providerName;
  final String? modelName;

  @override
  ConsumerState<SavedMealResultScreen> createState() =>
      _SavedMealResultScreenState();
}

class _SavedMealResultScreenState
    extends ConsumerState<SavedMealResultScreen> {
  late final TextEditingController _name;
  late final TextEditingController _kcal;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;
  late final TextEditingController _gi;
  bool _saving = false;

  double get _totalG => widget.ingredients.fold<double>(0, (s, i) => s + i.grams);

  @override
  void initState() {
    super.initState();
    final a = widget.analysis;
    _name = TextEditingController(text: a?.name.isNotEmpty == true ? a!.name : widget.name);
    _kcal = TextEditingController(text: a?.calories.toString() ?? '');
    _protein = TextEditingController(
        text: a == null ? '' : a.protein.toStringAsFixed(1));
    _carbs = TextEditingController(
        text: a == null ? '' : a.carbs.toStringAsFixed(1));
    _fat = TextEditingController(
        text: a == null ? '' : a.fat.toStringAsFixed(1));
    _gi = TextEditingController(text: a?.glycemicIndex?.toString() ?? '');
  }

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
    final showGi = ref.watch(settingsStreamProvider).value?.showGi ?? false;
    final totalG = _totalG;
    return Scaffold(
      appBar: AppBar(title: Text(widget.editingId == null
          ? t.new_saved_meal
          : t.edit_recipe)),
      body: AbsorbPointer(
        absorbing: _saving,
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.md),
          children: [
            Text(
              t.recipe_total_weight(totalG.toStringAsFixed(0)),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              t.tap_to_edit,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: AppSpace.sm),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: t.saved_meal_name),
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
            const SizedBox(height: AppSpace.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.ingredients,
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    for (final i in widget.ingredients)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• ${i.grams.toStringAsFixed(0)} ${t.ingredient_grams}  ${i.description}',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(t.save_recipe),
              ),
            ),
          ],
        ),
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
    final repo = ref.read(savedMealsRepoProvider);
    final protein = double.tryParse(_protein.text.trim().replaceAll(',', '.'));
    final carbs = double.tryParse(_carbs.text.trim().replaceAll(',', '.'));
    final fat = double.tryParse(_fat.text.trim().replaceAll(',', '.'));
    final gi = int.tryParse(_gi.text.trim());

    if (widget.editingId == null) {
      await repo.insert(
        name: name,
        ingredients: widget.ingredients,
        totalCalories: kcal,
        totalProtein: protein,
        totalCarbs: carbs,
        totalFat: fat,
        glycemicIndex: gi,
        provider: widget.providerName,
        model: widget.modelName,
      );
    } else {
      await repo.update(
        id: widget.editingId!,
        name: name,
        ingredients: widget.ingredients,
        totalCalories: kcal,
        totalProtein: protein,
        totalCarbs: carbs,
        totalFat: fat,
        glycemicIndex: gi,
        provider: widget.providerName,
        model: widget.modelName,
      );
    }
    if (!mounted) return;
    showAppSnack(
      context,
      widget.editingId == null ? t.saved_meal_saved : t.saved_meal_updated,
    );
    // Pop result + create screens; lands on the library (or RecordHome).
    final nav = Navigator.of(context);
    nav.pop();
    if (nav.canPop()) nav.pop();
  }
}
