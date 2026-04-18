import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../data/db/database.dart';
import '../../domain/calculations.dart';
import '../../domain/models/meal.dart';
import '../../domain/models/settings.dart';
import '../../domain/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/meal_details_sheet.dart';
import '../../widgets/progress_ring.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final profileAsync = ref.watch(profileStreamProvider);
    final mealsAsync = ref.watch(mealsTodayStreamProvider);
    final settingsAsync = ref.watch(settingsStreamProvider);
    final pendingQueue =
        ref.watch(pendingQueueStreamProvider).value ?? const <AnalysisQueueRow>[];

    return profileAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (profile) {
        if (profile == null) {
          return _SetupPrompt(
            message: t.setup_profile_msg,
            ctaLabel: t.setup_profile_btn,
            onTap: () => _openSettings(context),
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
        final today = DateTime.now();
        final dayType = getDayType(today);
        final target = dailyTargetFor(plan, today);
        final macros = macroTargetsFor(target);

        final meals = mealsAsync.value ?? const <Meal>[];
        final consumed = meals.fold<int>(0, (a, m) => a + m.calories);
        final remaining = target - consumed;
        final progress = target == 0 ? 0.0 : (consumed / target);

        final settings = settingsAsync.value;
        final showMacros = settings?.showMacros ?? false;
        final diabetic = settings?.diabeticMode ?? false;
        final ratio = settings?.insulinRatio ?? 0;

        return ListView(
          padding: const EdgeInsets.all(AppSpace.md),
          children: [
            _DayHeader(
              date: today,
              dayType: dayType,
              labelLow: t.low_day,
              labelHigh: t.high_day,
            ),
            const SizedBox(height: AppSpace.md),
            _FlippableProgressRing(
              calorieProgress: clamp01(progress),
              caloriesRemaining: remaining < 0 ? 0 : remaining,
              calorieTarget: target,
              consumedProtein:
                  meals.fold<double>(0, (a, m) => a + (m.protein ?? 0)),
              consumedCarbs:
                  meals.fold<double>(0, (a, m) => a + (m.carbs ?? 0)),
              consumedFat:
                  meals.fold<double>(0, (a, m) => a + (m.fat ?? 0)),
              proteinTarget: macros.proteinG,
              carbsTarget: macros.carbsG,
              fatTarget: macros.fatG,
              hasMeals: meals.isNotEmpty,
            ),
            const SizedBox(height: AppSpace.lg),
            if (showMacros)
              _MacrosCard(
                title: t.macros,
                proteinTarget: macros.proteinG,
                carbsTarget: macros.carbsG,
                fatTarget: macros.fatG,
                consumedProtein:
                    meals.fold<double>(0, (a, m) => a + (m.protein ?? 0)),
                consumedCarbs:
                    meals.fold<double>(0, (a, m) => a + (m.carbs ?? 0)),
                consumedFat: meals.fold<double>(0, (a, m) => a + (m.fat ?? 0)),
                proteinLabel: t.protein,
                carbsLabel: t.carbs,
                fatLabel: t.fat,
              ),
            if (diabetic && ratio > 0)
              _DiabeticInsightsCard(
                title: t.diabetic_insights,
                subtitle: t.diabetic_insights_subtitle,
                label: t.estimated_insulin,
                unitsLabel: t.units,
                totalCarbs:
                    meals.fold<double>(0, (a, m) => a + (m.carbs ?? 0)),
                ratio: ratio,
              ),
            if (pendingQueue.isNotEmpty) ...[
              const SizedBox(height: AppSpace.md),
              Text(
                t.queued_section_title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              ...pendingQueue.map(
                (row) => QueuedMealCard(
                  label: row.status == QueueStatus.processing
                      ? t.queued_processing
                      : t.queued_meal_label(_formatTime(row.createdAt)),
                  onDelete: () => _confirmDeleteQueued(context, ref, row, t),
                ),
              ),
            ],
            const SizedBox(height: AppSpace.md),
            Text(
              t.todays_meals,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            if (meals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
                child: Text(
                  t.no_meals_logged,
                  style: const TextStyle(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...meals.map(
                (m) => MealCard(
                  meal: m,
                  onTap: () => showMealDetailsSheet(context, m),
                  onDelete: () => _confirmDelete(context, ref, m, t),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Meal m,
    AppLocalizations t,
  ) async {
    final ok = await showConfirmDialog(
      context,
      title: t.confirm_delete_meal,
      confirmLabel: t.confirm,
      cancelLabel: t.cancel,
    );
    if (!ok) return;
    await ref.read(mealsRepoProvider).deleteMeal(m.id);
    if (context.mounted) {
      showAppSnack(context, t.meal_deleted);
    }
  }

  Future<void> _confirmDeleteQueued(
    BuildContext context,
    WidgetRef ref,
    AnalysisQueueRow row,
    AppLocalizations t,
  ) async {
    final ok = await showConfirmDialog(
      context,
      title: t.confirm_delete_entry,
      confirmLabel: t.confirm,
      cancelLabel: t.cancel,
    );
    if (!ok) return;
    await ref.read(queueServiceProvider).cancelQueueEntry(row.id);
    if (context.mounted) {
      showAppSnack(context, t.entry_deleted);
    }
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _openSettings(BuildContext context) {
    DefaultTabController.of(context);
    final shell = context.findAncestorStateOfType<State>();
    // Best-effort: settings is index 3 in HomeShell.
    if (shell?.mounted == true) {
      // Caller can navigate themselves; this is just a no-op fallback.
    }
  }
}

/// Wraps the daily ProgressRing and lets the user tap to flip between the
/// calorie remaining view and a 3-ring macros breakdown. Shows a one-time
/// hint banner once the user has logged their first meal so the gesture is
/// discoverable.
class _FlippableProgressRing extends ConsumerStatefulWidget {
  const _FlippableProgressRing({
    required this.calorieProgress,
    required this.caloriesRemaining,
    required this.calorieTarget,
    required this.consumedProtein,
    required this.consumedCarbs,
    required this.consumedFat,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.hasMeals,
  });

  final double calorieProgress;
  final int caloriesRemaining;
  final int calorieTarget;
  final double consumedProtein;
  final double consumedCarbs;
  final double consumedFat;
  final int proteinTarget;
  final int carbsTarget;
  final int fatTarget;
  final bool hasMeals;

  @override
  ConsumerState<_FlippableProgressRing> createState() =>
      _FlippableProgressRingState();
}

class _FlippableProgressRingState
    extends ConsumerState<_FlippableProgressRing> {
  bool _showMacros = false;

  Future<void> _markHintSeen(AppSettings? s) async {
    if (s == null || s.chartFlipHintShown) return;
    await ref
        .read(settingsRepoProvider)
        .save(s.copyWith(chartFlipHintShown: true));
  }

  Future<void> _toggle(AppSettings? s) async {
    setState(() => _showMacros = !_showMacros);
    await _markHintSeen(s);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final settings = ref.watch(settingsStreamProvider).value;
    final showHint = widget.hasMeals &&
        settings != null &&
        !settings.chartFlipHintShown;

    return Column(
      children: [
        if (showHint) ...[
          _RingFlipHint(
            message: t.ring_flip_hint,
            ctaLabel: t.got_it,
            onDismiss: () => _markHintSeen(settings),
          ),
          const SizedBox(height: AppSpace.sm),
        ],
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _toggle(settings),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, animation) {
                final rotate =
                    Tween(begin: 0.5, end: 0.0).animate(animation);
                return AnimatedBuilder(
                  animation: rotate,
                  child: child,
                  builder: (context, c) {
                    final isUnder =
                        ValueKey(_showMacros) != child.key;
                    final tilt = (isUnder ? -1 : 1) * rotate.value * 3.1415926;
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0015)
                        ..rotateY(tilt),
                      alignment: Alignment.center,
                      child: c,
                    );
                  },
                );
              },
              child: _showMacros
                  ? _MacroRingsTrio(
                      key: const ValueKey(true),
                      protein: widget.consumedProtein,
                      carbs: widget.consumedCarbs,
                      fat: widget.consumedFat,
                      proteinTarget: widget.proteinTarget,
                      carbsTarget: widget.carbsTarget,
                      fatTarget: widget.fatTarget,
                      proteinLabel: t.protein,
                      carbsLabel: t.carbs,
                      fatLabel: t.fat,
                    )
                  : ProgressRing(
                      key: const ValueKey(false),
                      progress: widget.calorieProgress,
                      centerLabel: '${widget.caloriesRemaining}',
                      subLabel:
                          '${t.kcal_remaining} • ${t.target} ${widget.calorieTarget}',
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RingFlipHint extends StatelessWidget {
  const _RingFlipHint({
    required this.message,
    required this.ctaLabel,
    required this.onDismiss,
  });
  final String message;
  final String ctaLabel;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.sm, vertical: AppSpace.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.textMain, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: onDismiss,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              ctaLabel,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three smaller rings shown side-by-side for protein / carbs / fat.
class _MacroRingsTrio extends StatelessWidget {
  const _MacroRingsTrio({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.proteinLabel,
    required this.carbsLabel,
    required this.fatLabel,
  });

  final double protein;
  final double carbs;
  final double fat;
  final int proteinTarget;
  final int carbsTarget;
  final int fatTarget;
  final String proteinLabel;
  final String carbsLabel;
  final String fatLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _MiniRing(
            label: proteinLabel,
            consumed: protein,
            target: proteinTarget,
            color: AppColors.primary,
          ),
          _MiniRing(
            label: carbsLabel,
            consumed: carbs,
            target: carbsTarget,
            color: AppColors.accentOrange,
          ),
          _MiniRing(
            label: fatLabel,
            consumed: fat,
            target: fatTarget,
            color: AppColors.accentRed,
          ),
        ],
      ),
    );
  }
}

class _MiniRing extends StatelessWidget {
  const _MiniRing({
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
  });

  final String label;
  final double consumed;
  final int target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = target == 0 ? 0.0 : (consumed / target).clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProgressRing(
          progress: pct,
          centerLabel: '${consumed.round()}',
          subLabel: '/${target}g',
          size: 80,
          strokeWidth: 7,
          color: color,
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.date,
    required this.dayType,
    required this.labelLow,
    required this.labelHigh,
  });

  final DateTime date;
  final String dayType;
  final String labelLow;
  final String labelHigh;

  @override
  Widget build(BuildContext context) {
    final pillColor =
        dayType == DayType.high ? AppColors.accentOrange : AppColors.primary;
    return Row(
      children: [
        Expanded(
          child: Text(
            _formatLong(date),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.sm + 2, vertical: 4),
          decoration: BoxDecoration(
            color: pillColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: pillColor),
          ),
          child: Text(
            dayType == DayType.high ? labelHigh : labelLow,
            style: TextStyle(
              color: pillColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  String _formatLong(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _MacrosCard extends StatelessWidget {
  const _MacrosCard({
    required this.title,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.consumedProtein,
    required this.consumedCarbs,
    required this.consumedFat,
    required this.proteinLabel,
    required this.carbsLabel,
    required this.fatLabel,
  });

  final String title;
  final int proteinTarget;
  final int carbsTarget;
  final int fatTarget;
  final double consumedProtein;
  final double consumedCarbs;
  final double consumedFat;
  final String proteinLabel;
  final String carbsLabel;
  final String fatLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: AppSpace.md),
            Row(
              children: [
                Expanded(
                    child: _MacroCell(
                        label: proteinLabel,
                        consumed: consumedProtein,
                        target: proteinTarget)),
                Expanded(
                    child: _MacroCell(
                        label: carbsLabel,
                        consumed: consumedCarbs,
                        target: carbsTarget)),
                Expanded(
                    child: _MacroCell(
                        label: fatLabel,
                        consumed: consumedFat,
                        target: fatTarget)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroCell extends StatelessWidget {
  const _MacroCell({
    required this.label,
    required this.consumed,
    required this.target,
  });

  final String label;
  final double consumed;
  final int target;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '${consumed.round()}/${target}g',
          style: const TextStyle(
            color: AppColors.textMain,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DiabeticInsightsCard extends StatelessWidget {
  const _DiabeticInsightsCard({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.unitsLabel,
    required this.totalCarbs,
    required this.ratio,
  });

  final String title;
  final String subtitle;
  final String label;
  final String unitsLabel;
  final double totalCarbs;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final units = ratio <= 0
        ? 0.0
        : (totalCarbs / ratio * 10).round() / 10;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.medical_information_outlined,
                color: AppColors.accentBlue),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.textMain,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    '$label: ${units.toStringAsFixed(1)} $unitsLabel',
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupPrompt extends StatelessWidget {
  const _SetupPrompt({
    required this.message,
    required this.ctaLabel,
    required this.onTap,
  });

  final String message;
  final String ctaLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style:
                  const TextStyle(color: AppColors.textMuted, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpace.md),
            ElevatedButton(onPressed: onTap, child: Text(ctaLabel)),
          ],
        ),
      ),
    );
  }
}
