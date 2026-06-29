import 'dart:math' as math;

import '../core/constants.dart';

double calculateBmr({
  required double weightKg,
  required double heightCm,
  required int age,
  required bool isMale,
}) {
  final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
  return isMale ? base + 5 : base - 161;
}

double calculateTdee(double bmr, double activityMultiplier) =>
    bmr * activityMultiplier;

class ZigZagPlan {
  const ZigZagPlan({
    required this.high,
    required this.low,
    required this.weeklyAverage,
  });

  final int high;
  final int low;
  final double weeklyAverage;
}

ZigZagPlan calculateZigZagPlan({
  required double tdee,
  required double goalWeightKg,
  required double currentWeightKg,
}) {
  final isWeightLoss = goalWeightKg < currentWeightKg;
  final isWeightGain = goalWeightKg > currentWeightKg;
  // Use a 500 kcal deficit for loss or surplus for gain.
  final adjustment = isWeightLoss ? -500.0 : (isWeightGain ? 500.0 : 0.0);
  final dailyBase = tdee + adjustment;
  final high = (dailyBase * 1.15).round();
  final low = (dailyBase * 0.94).round();
  return ZigZagPlan(high: high, low: low, weeklyAverage: dailyBase);
}

String getDayType(DateTime date) {
  final dow = date.weekday;
  // Dart: Monday=1, Sunday=7. Saturday=6.
  return (dow == DateTime.saturday || dow == DateTime.sunday)
      ? DayType.high
      : DayType.low;
}

int dailyTargetFor(ZigZagPlan plan, DateTime date) =>
    getDayType(date) == DayType.high ? plan.high : plan.low;

double calculateBmi({required double weightKg, required double heightCm}) {
  if (heightCm <= 0) return 0;
  final m = heightCm / 100.0;
  return weightKg / (m * m);
}

class MacroTargets {
  const MacroTargets({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });
  final int proteinG;
  final int carbsG;
  final int fatG;
}

// Protein 30%, carbs 40%, fat 30% of kcal target.
// kcal/g: protein=4, carbs=4, fat=9.
MacroTargets macroTargetsFor(int calories) {
  final proteinKcal = calories * 0.30;
  final carbsKcal = calories * 0.40;
  final fatKcal = calories * 0.30;
  return MacroTargets(
    proteinG: (proteinKcal / 4).round(),
    carbsG: (carbsKcal / 4).round(),
    fatG: (fatKcal / 9).round(),
  );
}

double estimateInsulin({required double carbsG, required double ratio}) {
  if (ratio <= 0) return 0;
  final raw = carbsG / ratio;
  // Round to 1 decimal.
  return (raw * 10).round() / 10;
}

// Utility: format a DateTime as ISO date YYYY-MM-DD for DB storage.
String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

String isoTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}';

// Clamp helper used by progress rings.
double clamp01(double x) => math.max(0.0, math.min(1.0, x));
