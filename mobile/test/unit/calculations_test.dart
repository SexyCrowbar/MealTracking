import 'package:flutter_test/flutter_test.dart';
import 'package:mealtracker/core/constants.dart';
import 'package:mealtracker/domain/calculations.dart';

void main() {
  group('BMR (Mifflin-St Jeor)', () {
    test('male reference: 80kg, 180cm, 30y => 1780', () {
      final bmr = calculateBmr(
        weightKg: 80, heightCm: 180, age: 30, isMale: true,
      );
      expect(bmr, closeTo(1780, 0.5));
    });

    test('female reference: 65kg, 165cm, 30y => 1370.25', () {
      final bmr = calculateBmr(
        weightKg: 65, heightCm: 165, age: 30, isMale: false,
      );
      expect(bmr, closeTo(1370.25, 0.5));
    });

    test('male reference: 70kg, 175cm, 25y => 1673.75', () {
      // 10*70 + 6.25*175 - 5*25 + 5 = 700 + 1093.75 - 125 + 5
      final bmr = calculateBmr(
        weightKg: 70, heightCm: 175, age: 25, isMale: true,
      );
      expect(bmr, closeTo(1673.75, 0.5));
    });
  });

  group('TDEE', () {
    test('sedentary multiplier (1.2)', () {
      expect(calculateTdee(1500, 1.2), closeTo(1800, 0.001));
    });
    test('moderate multiplier (1.55)', () {
      expect(calculateTdee(1800, 1.55), closeTo(2790, 0.001));
    });
    test('extra multiplier (1.9)', () {
      expect(calculateTdee(2000, 1.9), closeTo(3800, 0.001));
    });
  });

  group('ZigZag plan', () {
    test('weight loss: 500 kcal deficit, then high=1.15x, low=0.94x', () {
      final p = calculateZigZagPlan(
          tdee: 2500, goalWeightKg: 70, currentWeightKg: 80);
      expect(p.weeklyAverage, closeTo(2000, 0.001));
      expect(p.high, equals(2300)); // 2000 * 1.15
      expect(p.low, equals(1880));  // 2000 * 0.94
    });

    test('maintenance/gain: no deficit', () {
      final p = calculateZigZagPlan(
          tdee: 2200, goalWeightKg: 80, currentWeightKg: 80);
      expect(p.weeklyAverage, closeTo(2200, 0.001));
      expect(p.high, equals(2530)); // 2200 * 1.15
      expect(p.low, equals(2068));  // 2200 * 0.94
    });
  });

  group('Day type', () {
    test('Saturday is high', () {
      // 2026-04-18 is a Saturday.
      expect(getDayType(DateTime(2026, 4, 18)), equals(DayType.high));
    });
    test('Sunday is high', () {
      expect(getDayType(DateTime(2026, 4, 19)), equals(DayType.high));
    });
    test('Wednesday is low', () {
      expect(getDayType(DateTime(2026, 4, 15)), equals(DayType.low));
    });
  });

  group('BMI', () {
    test('80kg / 180cm => ~24.69', () {
      expect(
          calculateBmi(weightKg: 80, heightCm: 180), closeTo(24.69, 0.01));
    });
    test('zero height returns 0', () {
      expect(calculateBmi(weightKg: 80, heightCm: 0), equals(0));
    });
  });

  group('Macro targets (30/40/30)', () {
    test('2000 kcal => protein 150g, carbs 200g, fat 67g', () {
      final m = macroTargetsFor(2000);
      expect(m.proteinG, equals(150));
      expect(m.carbsG, equals(200));
      expect(m.fatG, equals(67));
    });
  });

  group('Insulin estimate', () {
    test('60g carbs / ratio 10 => 6.0', () {
      expect(
          estimateInsulin(carbsG: 60, ratio: 10), closeTo(6.0, 0.001));
    });
    test('45g carbs / ratio 12 => 3.8 (rounded to 1 decimal)', () {
      expect(
          estimateInsulin(carbsG: 45, ratio: 12), closeTo(3.8, 0.001));
    });
    test('zero ratio returns 0', () {
      expect(estimateInsulin(carbsG: 60, ratio: 0), equals(0));
    });
  });
}
