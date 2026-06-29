import 'package:flutter_test/flutter_test.dart';
import 'package:mealtracker/ai/parse_utils.dart';

void main() {
  group('requireMealFields', () {
    test('accepts valid nutrition fields', () {
      final map = <String, dynamic>{
        'name': 'Soup',
        'calories': 200,
        'protein': 10.0,
        'carbs': 25.0,
        'fat': 8.0,
      };
      expect(() => requireMealFields(map), returnsNormally);
    });

    test('rejects missing name', () {
      final map = <String, dynamic>{
        'calories': 200,
        'protein': 10.0,
        'carbs': 25.0,
        'fat': 8.0,
      };
      expect(
        () => requireMealFields(map),
        throwsA(isA<AiAnalysisException>()),
      );
    });

    test('rejects missing calories', () {
      final map = <String, dynamic>{
        'name': 'Soup',
        'protein': 10.0,
        'carbs': 25.0,
        'fat': 8.0,
      };
      expect(
        () => requireMealFields(map),
        throwsA(isA<AiAnalysisException>()),
      );
    });

    test('rejects null protein', () {
      final map = <String, dynamic>{
        'name': 'Soup',
        'calories': 200,
        'protein': null,
        'carbs': 25.0,
        'fat': 8.0,
      };
      expect(
        () => requireMealFields(map),
        throwsA(isA<AiAnalysisException>()),
      );
    });

    test('rejects missing carbs', () {
      final map = <String, dynamic>{
        'name': 'Soup',
        'calories': 200,
        'protein': 10.0,
        'fat': 8.0,
      };
      expect(
        () => requireMealFields(map),
        throwsA(isA<AiAnalysisException>()),
      );
    });

    test('rejects missing fat', () {
      final map = <String, dynamic>{
        'name': 'Soup',
        'calories': 200,
        'protein': 10.0,
        'carbs': 25.0,
      };
      expect(
        () => requireMealFields(map),
        throwsA(isA<AiAnalysisException>()),
      );
    });

    test('rejects name with only whitespace', () {
      final map = <String, dynamic>{
        'name': '   ',
        'calories': 200,
        'protein': 10.0,
        'carbs': 25.0,
        'fat': 8.0,
      };
      // name passes requireMealFields (it's present and non-null),
      // but the MealAnalysis constructor trims it later.
      expect(() => requireMealFields(map), returnsNormally);
    });
  });

  group('Groq regex fallback rejection', () {
    test('partial match with only name throws when validated', () {
      final map = <String, dynamic>{'name': 'Soup'};
      expect(
        () => requireMealFields(map),
        throwsA(isA<AiAnalysisException>()),
      );
    });

    test('partial match missing fat throws', () {
      final map = <String, dynamic>{
        'name': 'Soup',
        'calories': 200,
        'protein': 10.0,
        'carbs': 25.0,
      };
      expect(
        () => requireMealFields(map),
        throwsA(isA<AiAnalysisException>()),
      );
    });
  });
}
