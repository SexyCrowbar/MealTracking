import 'meal_analyzer.dart';

export 'meal_analyzer.dart' show AiAnalysisException;

/// Validates that a parsed AI response contains all required nutrition fields.
/// Throws [AiAnalysisException] if any required field is missing or null.
void requireMealFields(Map<String, dynamic> m) {
  for (final f in ['name', 'calories', 'protein', 'carbs', 'fat']) {
    if (!m.containsKey(f) || m[f] == null) {
      throw AiAnalysisException('AI response missing required field: $f');
    }
  }
}
