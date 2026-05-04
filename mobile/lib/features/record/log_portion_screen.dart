import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/meal_analyzer.dart';
import '../../core/theme.dart';
import '../../data/db/database.dart';
import '../../domain/models/meal.dart';
import '../../domain/models/meal_analysis.dart';
import '../../domain/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/dialogs.dart';

class _ExtraRow {
  _ExtraRow({String? description, String? grams})
      : description = TextEditingController(text: description ?? ''),
        grams = TextEditingController(text: grams ?? '');
  final TextEditingController description;
  final TextEditingController grams;

  void dispose() {
    description.dispose();
    grams.dispose();
  }
}

class LogPortionScreen extends ConsumerStatefulWidget {
  const LogPortionScreen({super.key, required this.meal});

  final SavedMealRow meal;

  @override
  ConsumerState<LogPortionScreen> createState() => _LogPortionScreenState();
}

class _LogPortionScreenState extends ConsumerState<LogPortionScreen> {
  late final TextEditingController _grams;
  final List<_ExtraRow> _extras = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _grams = TextEditingController(
        text: widget.meal.totalWeightG.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _grams.dispose();
    for (final r in _extras) {
      r.dispose();
    }
    super.dispose();
  }

  void _addExtra() {
    setState(() => _extras.add(_ExtraRow()));
  }

  void _removeExtra(int index) {
    setState(() {
      _extras.removeAt(index).dispose();
    });
  }

  int get _previewKcal {
    final g = double.tryParse(_grams.text.trim().replaceAll(',', '.'));
    if (g == null || g <= 0) return 0;
    return (widget.meal.caloriesPer100g * g / 100.0).round();
  }

  /// Returns null if the extras section is empty (none entered) — that's a
  /// valid state. Returns an empty list and shows a snack if a partial row
  /// is invalid. Returns the populated list otherwise.
  List<MealExtra>? _collectExtras() {
    if (_extras.isEmpty) return const [];
    final t = AppLocalizations.of(context);
    final out = <MealExtra>[];
    for (final r in _extras) {
      final desc = r.description.text.trim();
      final gramsStr = r.grams.text.trim();
      if (desc.isEmpty && gramsStr.isEmpty) continue;
      final grams = double.tryParse(gramsStr.replaceAll(',', '.'));
      if (desc.isEmpty || grams == null || grams <= 0) {
        showAppSnack(context, t.recipe_invalid_grams);
        return null;
      }
      out.add(MealExtra(description: desc, grams: grams));
    }
    return out;
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final g = double.tryParse(_grams.text.trim().replaceAll(',', '.'));
    if (g == null || g <= 0) {
      showAppSnack(context, t.recipe_invalid_grams);
      return;
    }
    final extras = _collectExtras();
    if (extras == null) return;

    setState(() => _busy = true);

    MealAnalysis? extrasTotals;
    if (extras.isNotEmpty) {
      final settings = ref.read(settingsStreamProvider).value;
      if (settings != null) {
        final providerKey = settings.activeProvider;
        final apiKey =
            await ref.read(secureStoreProvider).getApiKey(providerKey);
        if (apiKey != null && apiKey.isNotEmpty) {
          try {
            final analyzer = ref.read(analyzerProvider(providerKey));
            final profile = await ref.read(profileRepoProvider).getProfile();
            extrasTotals = await analyzer.analyzeMeal(AnalysisRequest(
              apiKey: apiKey,
              model: settings.activeModel,
              allergens: settings.allergensList,
              profile: profile,
              diabeticRatio:
                  settings.diabeticMode ? settings.insulinRatio : null,
              recipeIngredients: [
                for (final e in extras)
                  RecipeIngredient(description: e.description, grams: e.grams),
              ],
            ));
          } catch (_) {
            if (!mounted) return;
            setState(() => _busy = false);
            showAppSnack(context, t.recipe_ai_failed);
            return;
          }
        } else {
          if (!mounted) return;
          setState(() => _busy = false);
          showAppSnack(context, t.recipe_ai_failed);
          return;
        }
      }
    }

    await ref.read(mealsRepoProvider).insertFromSavedMeal(
          meal: widget.meal,
          weightG: g,
          extras: extras,
          extrasTotals: extrasTotals,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    showAppSnack(context, t.meal_added);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final meal = widget.meal;
    final hasExtras = _extras.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(t.log_portion)),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.md),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.md),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.input,
                        borderRadius:
                            BorderRadius.circular(AppRadius.md - 2),
                      ),
                      child: const Center(
                        child:
                            Text('🥘', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.kcal_per_100g(meal.caloriesPer100g),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpace.md),
            TextField(
              controller: _grams,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: t.weight_eaten_g),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              hasExtras
                  ? '~ $_previewKcal ${t.calories.toLowerCase()} (${t.extras_calories_after_save})'
                  : '~ $_previewKcal ${t.calories.toLowerCase()}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            Row(
              children: [
                Text(
                  t.extras_optional,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    t.extras_subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            for (var i = 0; i < _extras.length; i++) ...[
              _ExtraEditor(
                row: _extras[i],
                onRemove: () => _removeExtra(i),
                gramsLabel: t.ingredient_grams,
                descriptionLabel: t.ingredient_description,
                descriptionHint: t.extra_hint,
              ),
              const SizedBox(height: AppSpace.sm),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addExtra,
                icon: const Icon(Icons.add),
                label: Text(t.add_extra),
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _save,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_busy
                    ? (hasExtras ? t.analyzing : t.log_this_portion)
                    : t.log_this_portion),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExtraEditor extends StatelessWidget {
  const _ExtraEditor({
    required this.row,
    required this.onRemove,
    required this.gramsLabel,
    required this.descriptionLabel,
    required this.descriptionHint,
  });

  final _ExtraRow row;
  final VoidCallback onRemove;
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
        ),
      ],
    );
  }
}
