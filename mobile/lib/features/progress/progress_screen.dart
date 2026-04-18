import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../domain/calculations.dart';
import '../../domain/models/meal.dart';
import '../../domain/models/weight_entry.dart';
import '../../domain/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/meal_details_sheet.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  final _weightCtrl = TextEditingController();

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final profileAsync = ref.watch(profileStreamProvider);
    final weightsAsync = ref.watch(weightStreamProvider);
    final mealsAsync = ref.watch(mealsRecentStreamProvider(30));

    return profileAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (profile) {
        final bmi = profile == null
            ? null
            : calculateBmi(
                weightKg: profile.weightKg, heightCm: profile.heightCm);
        final weights = weightsAsync.value ?? const <WeightEntry>[];
        final meals = mealsAsync.value ?? const <Meal>[];

        return ListView(
          padding: const EdgeInsets.all(AppSpace.md),
          children: [
            Text(t.screen_title_progress,
                style: Theme.of(context).appBarTheme.titleTextStyle),
            const SizedBox(height: AppSpace.md),
            _Card(
              title: t.update_weight_btn,
              child: Column(
                children: [
                  TextField(
                    controller: _weightCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        InputDecoration(labelText: t.current_weight),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _saveWeight(profile?.weightKg),
                      child: Text(t.update_weight_btn),
                    ),
                  ),
                  if (bmi != null) ...[
                    const SizedBox(height: AppSpace.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t.calculate_bmi,
                            style:
                                const TextStyle(color: AppColors.textMuted)),
                        Text(bmi.toStringAsFixed(1),
                            style: const TextStyle(
                                color: AppColors.textMain,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            _Card(
              title: t.weight_history,
              child: SizedBox(
                height: 180,
                child: weights.isEmpty
                    ? Center(
                        child: Text(t.no_history,
                            style:
                                const TextStyle(color: AppColors.textMuted)))
                    : _WeightChart(entries: weights.take(7).toList().reversed.toList()),
              ),
            ),
            _Card(
              title: t.adherence_chart,
              child: SizedBox(
                height: 200,
                child: _AdherenceChart(meals: meals, profile: profile),
              ),
            ),
            _Card(
              title: t.meal_history,
              child: meals.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
                      child: Text(t.no_history,
                          style: const TextStyle(color: AppColors.textMuted),
                          textAlign: TextAlign.center),
                    )
                  : Column(
                      children: meals
                          .take(20)
                          .map((m) => MealCard(
                                meal: m,
                                onTap: () => showMealDetailsSheet(context, m),
                                onDelete: () => _confirmDelete(m),
                              ))
                          .toList(),
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveWeight(double? currentWeight) async {
    final t = AppLocalizations.of(context);
    final w = double.tryParse(_weightCtrl.text.trim());
    if (w == null || w < 30 || w > 400) {
      showAppSnack(context, t.provide_text_image);
      return;
    }
    await ref.read(weightRepoProvider).addEntry(w);
    final profile = await ref.read(profileRepoProvider).getProfile();
    if (profile != null) {
      await ref.read(profileRepoProvider).save(profile.copyWith(weightKg: w));
    }
    if (!mounted) return;
    _weightCtrl.clear();
    showAppSnack(context, t.weight_updated);
  }

  Future<void> _confirmDelete(Meal m) async {
    final t = AppLocalizations.of(context);
    final ok = await showConfirmDialog(context,
        title: t.confirm_delete_meal,
        confirmLabel: t.confirm,
        cancelLabel: t.cancel);
    if (!ok) return;
    await ref.read(mealsRepoProvider).deleteMeal(m.id);
    if (mounted) showAppSnack(context, t.meal_deleted);
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: AppColors.textMain,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            const SizedBox(height: AppSpace.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.entries});
  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox();
    final spots = <FlSpot>[
      for (var i = 0; i < entries.length; i++)
        FlSpot(i.toDouble(), entries[i].weightKg),
    ];
    final values = entries.map((e) => e.weightKg).toList();
    final minY = (values.reduce((a, b) => a < b ? a : b)) - 1;
    final maxY = (values.reduce((a, b) => a > b ? a : b)) + 1;
    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0),
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= entries.length) return const SizedBox();
                final d = DateTime.tryParse(entries[i].date);
                final label = d == null ? '' : '${d.month}/${d.day}';
                return Text(label,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 10));
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

class _AdherenceChart extends StatelessWidget {
  const _AdherenceChart({required this.meals, required this.profile});
  final List<Meal> meals;
  final dynamic profile; // Profile?

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Center(
        child: Text('Set up profile to see adherence',
            style: TextStyle(color: AppColors.textMuted)),
      );
    }
    final bmr = calculateBmr(
      weightKg: profile.weightKg,
      heightCm: profile.heightCm,
      age: profile.age,
      isMale: profile.isMale,
    );
    final tdee = calculateTdee(bmr, profile.activityMultiplier);
    final plan = calculateZigZagPlan(
      tdee: tdee,
      goalWeightKg: profile.goalWeightKg,
      currentWeightKg: profile.weightKg,
    );
    // Aggregate per date.
    final today = DateTime.now();
    final byDate = <String, int>{};
    for (final m in meals) {
      byDate[m.date] = (byDate[m.date] ?? 0) + m.calories;
    }
    final groups = <BarChartGroupData>[];
    final dayCount = 14;
    for (var i = dayCount - 1; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final iso = isoDate(d);
      final consumed = byDate[iso] ?? 0;
      final target = dailyTargetFor(plan, d);
      final ratio = target == 0 ? 0.0 : consumed / target;
      Color color;
      if (consumed == 0) {
        color = AppColors.textMuted.withValues(alpha: 0.3);
      } else if (ratio < 0.85) {
        color = AppColors.accentBlue;
      } else if (ratio <= 1.10) {
        color = AppColors.primary;
      } else {
        color = AppColors.accentRed;
      }
      groups.add(BarChartGroupData(
        x: dayCount - 1 - i,
        barRods: [
          BarChartRodData(
            toY: consumed.toDouble(),
            color: color,
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ));
    }
    final maxKcal = groups
        .expand((g) => g.barRods)
        .map((r) => r.toY)
        .fold<double>(0, (a, b) => a > b ? a : b);
    return BarChart(
      BarChartData(
        maxY: maxKcal == 0 ? 100 : maxKcal * 1.2,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                final d = today.subtract(Duration(days: dayCount - 1 - idx));
                return Text('${d.month}/${d.day}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 9));
              },
            ),
          ),
        ),
        barGroups: groups,
      ),
    );
  }
}

