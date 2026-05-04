import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/meal_analyzer.dart';
import '../../core/theme.dart';
import '../../data/db/dao/saved_meal_dao.dart';
import '../../data/repositories/saved_meals_repo.dart';
import '../../domain/models/meal_analysis.dart';
import '../../domain/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/dialogs.dart';
import 'saved_meal_result_screen.dart';

class _IngredientRow {
  _IngredientRow({String? description, String? grams})
      : description = TextEditingController(text: description ?? ''),
        grams = TextEditingController(text: grams ?? '');
  final TextEditingController description;
  final TextEditingController grams;

  void dispose() {
    description.dispose();
    grams.dispose();
  }
}

class SavedMealCreateScreen extends ConsumerStatefulWidget {
  const SavedMealCreateScreen({super.key, this.editing});

  /// When non-null, the screen edits an existing saved meal.
  final SavedMealWithIngredients? editing;

  @override
  ConsumerState<SavedMealCreateScreen> createState() =>
      _SavedMealCreateScreenState();
}

class _SavedMealCreateScreenState
    extends ConsumerState<SavedMealCreateScreen> {
  late final TextEditingController _name;
  final List<_IngredientRow> _rows = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.editing;
    _name = TextEditingController(text: existing?.meal.name ?? '');
    if (existing != null && existing.ingredients.isNotEmpty) {
      for (final ing in existing.ingredients) {
        _rows.add(_IngredientRow(
          description: ing.description,
          grams: ing.grams.toStringAsFixed(0),
        ));
      }
    } else {
      _rows.addAll([_IngredientRow(), _IngredientRow()]);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() => _rows.add(_IngredientRow()));
  }

  void _removeRow(int index) {
    setState(() {
      _rows.removeAt(index).dispose();
      if (_rows.isEmpty) _rows.add(_IngredientRow());
    });
  }

  List<RecipeIngredientInput>? _collectIngredients() {
    final t = AppLocalizations.of(context);
    final out = <RecipeIngredientInput>[];
    for (final r in _rows) {
      final desc = r.description.text.trim();
      final gramsStr = r.grams.text.trim();
      if (desc.isEmpty && gramsStr.isEmpty) continue;
      final grams = double.tryParse(gramsStr.replaceAll(',', '.'));
      if (desc.isEmpty || grams == null || grams <= 0) {
        showAppSnack(context, t.recipe_invalid_grams);
        return null;
      }
      out.add(RecipeIngredientInput(description: desc, grams: grams));
    }
    if (out.isEmpty) {
      showAppSnack(context, t.recipe_no_ingredients);
      return null;
    }
    return out;
  }

  Future<void> _calculate() async {
    final t = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      showAppSnack(context, t.saved_meal_name_hint);
      return;
    }
    final ingredients = _collectIngredients();
    if (ingredients == null) return;

    final settings = ref.read(settingsStreamProvider).value;
    if (settings == null) return;
    final providerKey = settings.activeProvider;
    final apiKey = await ref.read(secureStoreProvider).getApiKey(providerKey);

    setState(() => _busy = true);
    MealAnalysis? analysis;
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final analyzer = ref.read(analyzerProvider(providerKey));
        final profile = await ref.read(profileRepoProvider).getProfile();
        analysis = await analyzer.analyzeMeal(AnalysisRequest(
          apiKey: apiKey,
          model: settings.activeModel,
          allergens: settings.allergensList,
          profile: profile,
          diabeticRatio:
              settings.diabeticMode ? settings.insulinRatio : null,
          recipeIngredients: [
            for (final i in ingredients)
              RecipeIngredient(description: i.description, grams: i.grams),
          ],
        ));
      } catch (_) {
        if (mounted) showAppSnack(context, t.recipe_ai_failed);
      }
    } else {
      if (mounted) showAppSnack(context, t.recipe_ai_failed);
    }

    if (!mounted) return;
    setState(() => _busy = false);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SavedMealResultScreen(
          name: name,
          ingredients: ingredients,
          analysis: analysis,
          editingId: widget.editing?.meal.id,
          providerName: settings.activeProvider,
          modelName: settings.activeModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isEdit = widget.editing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? t.edit_recipe : t.new_saved_meal),
      ),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.md),
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: t.saved_meal_name,
                hintText: t.saved_meal_name_hint,
              ),
            ),
            const SizedBox(height: AppSpace.md),
            Text(
              t.ingredients,
              style: const TextStyle(
                color: AppColors.textMain,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            for (var i = 0; i < _rows.length; i++) ...[
              _IngredientEditor(
                row: _rows[i],
                onRemove: _rows.length == 1 ? null : () => _removeRow(i),
                gramsLabel: t.ingredient_grams,
                descriptionLabel: t.ingredient_description,
                descriptionHint: t.ingredient_description_hint,
              ),
              const SizedBox(height: AppSpace.sm),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add),
                label: Text(t.add_ingredient),
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _calculate,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_busy
                    ? t.analyzing
                    : (isEdit ? t.recalculate_with_ai : t.calculate_and_save)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientEditor extends StatelessWidget {
  const _IngredientEditor({
    required this.row,
    required this.onRemove,
    required this.gramsLabel,
    required this.descriptionLabel,
    required this.descriptionHint,
  });

  final _IngredientRow row;
  final VoidCallback? onRemove;
  final String gramsLabel;
  final String descriptionLabel;
  final String descriptionHint;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: row.description,
            decoration: InputDecoration(
              labelText: descriptionLabel,
              hintText: descriptionHint,
            ),
          ),
        ),
        const SizedBox(width: AppSpace.sm),
        SizedBox(
          width: 88,
          child: TextField(
            controller: row.grams,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: gramsLabel),
          ),
        ),
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.close, color: AppColors.textMuted),
          tooltip: onRemove == null ? null : 'Remove',
        ),
      ],
    );
  }
}
