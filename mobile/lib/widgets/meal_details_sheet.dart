import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../domain/models/meal.dart';
import '../l10n/app_localizations.dart';

Future<void> showMealDetailsSheet(BuildContext context, Meal meal) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (ctx) => _MealDetailsSheet(meal: meal),
  );
}

class _MealDetailsSheet extends StatelessWidget {
  const _MealDetailsSheet({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final allergen = meal.allergenWarning?.trim();
    final showAllergen = allergen != null && allergen.isNotEmpty;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.md, AppSpace.sm, AppSpace.md, AppSpace.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpace.md),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
                _SourcePill(source: meal.source, label: _sourceLabel(meal.source)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              meal.time,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: AppSpace.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${meal.calories}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'kcal',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            Row(
              children: [
                Expanded(
                  child: _MacroTile(
                    label: t.protein,
                    grams: meal.protein,
                    color: AppColors.accentBlue,
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: _MacroTile(
                    label: t.carbs,
                    grams: meal.carbs,
                    color: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: _MacroTile(
                    label: t.fat,
                    grams: meal.fat,
                    color: AppColors.accentRed,
                  ),
                ),
              ],
            ),
            if (meal.glycemicIndex != null ||
                meal.estimatedInsulin != null) ...[
              const SizedBox(height: AppSpace.sm),
              Row(
                children: [
                  if (meal.glycemicIndex != null)
                    Expanded(
                      child: _InfoTile(
                        label: t.glycemic_index,
                        value: meal.glycemicIndex.toString(),
                      ),
                    ),
                  if (meal.glycemicIndex != null &&
                      meal.estimatedInsulin != null)
                    const SizedBox(width: AppSpace.sm),
                  if (meal.estimatedInsulin != null)
                    Expanded(
                      child: _InfoTile(
                        label: t.estimated_insulin_meal,
                        value:
                            '${meal.estimatedInsulin!.toStringAsFixed(1)} ${t.units}',
                      ),
                    ),
                ],
              ),
            ],
            if (showAllergen) ...[
              const SizedBox(height: AppSpace.sm),
              Container(
                padding: const EdgeInsets.all(AppSpace.sm + 2),
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.accentRed),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.accentRed, size: 20),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Text(
                        '${t.allergen_warning}: $allergen',
                        style: const TextStyle(color: AppColors.textMain),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (meal.provider != null && meal.model != null) ...[
              const SizedBox(height: AppSpace.sm),
              Text(
                '${meal.provider} · ${meal.model}',
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _sourceLabel(String source) {
    switch (source) {
      case MealSource.aiPhoto:
        return 'AI · photo';
      case MealSource.aiPhotoText:
        return 'AI · photo + text';
      case MealSource.aiText:
        return 'AI · text';
      case MealSource.manual:
      default:
        return 'Manual';
    }
  }
}

class _SourcePill extends StatelessWidget {
  const _SourcePill({required this.source, required this.label});
  final String source;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isAi = source != MealSource.manual;
    final color = isAi ? AppColors.primary : AppColors.textMuted;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.label,
    required this.grams,
    required this.color,
  });

  final String label;
  final double? grams;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final value = grams == null ? '—' : '${grams!.round()}g';
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpace.sm + 2, horizontal: AppSpace.sm),
      decoration: BoxDecoration(
        color: AppColors.input,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpace.sm + 2, horizontal: AppSpace.sm),
      decoration: BoxDecoration(
        color: AppColors.input,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
