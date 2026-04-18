import '../domain/models/profile.dart';

class PromptBuilder {
  const PromptBuilder._();

  static String systemInstruction({
    required List<String> allergens,
    Profile? profile,
    double? diabeticRatio,
    bool textOnly = false,
  }) {
    if (textOnly) {
      return _textOnlyInstruction(
        allergens: allergens,
        profile: profile,
        diabeticRatio: diabeticRatio,
      );
    }
    final allergensStr = allergens.isEmpty ? 'none' : allergens.join(', ');
    final diabeticPart = diabeticRatio != null && diabeticRatio > 0
        ? "Diabetic mode: ON — also estimate insulin units using ratio 1 unit per ${diabeticRatio.toStringAsFixed(0)} grams of carbs (set 'estimated_insulin' field).\n"
        : "Diabetic mode: OFF\n";
    final profilePart = profile != null
        ? 'User profile: age=${profile.age}, gender=${profile.gender}, weight=${profile.weightKg}kg, height=${profile.heightCm}cm, activity=${profile.activityLevel}.\n'
        : '';

    return '''
Analyze the attached photo of a meal and estimate its nutritional content.

The photo is the primary source of truth. Use it to identify food items, estimate portion sizes, and calculate nutrition.

If the user has provided a text description, use it to refine your analysis — it may specify ingredients not visible in the photo, clarify preparation method, indicate portion size, or correct assumptions (e.g., "sugar-free", "dressing on the side", "about 250g of pasta"). When the text and photo conflict, prefer the text for ingredient details and the photo for portion size estimation.

Context:
${profilePart}Consider typical home/restaurant portion sizes. If the photo shows multiple dishes, analyze ALL of them as one meal.

User's allergen list: $allergensStr
$diabeticPart

Required output fields:
- name: concise meal name (e.g., "Grilled Chicken Salad")
- calories: total estimated kcal (integer)
- protein: grams (number)
- carbs: grams (number)
- fat: grams (number)
- glycemic_index: estimated GI 0-100 (integer or null)
- health_score: 1-10 rating (number)
- allergen_warning: warning string if allergens detected from user's list, otherwise null
- estimated_insulin: insulin units (number) only if diabetic mode is ON, otherwise null
''';
  }

  /// Few-shot example string for Groq (less reliable JSON mode).
  static const String groqExample = '''
Example output for a "grilled chicken salad" photo:
{"name":"Grilled Chicken Salad","calories":420,"protein":35,"carbs":18,"fat":22,"glycemic_index":35,"health_score":8,"allergen_warning":null,"estimated_insulin":null}
''';

  static String _textOnlyInstruction({
    required List<String> allergens,
    Profile? profile,
    double? diabeticRatio,
  }) {
    final allergensStr = allergens.isEmpty ? 'none' : allergens.join(', ');
    final diabeticPart = diabeticRatio != null && diabeticRatio > 0
        ? "Diabetic mode: ON — also estimate insulin units using ratio 1 unit per ${diabeticRatio.toStringAsFixed(0)} grams of carbs (set 'estimated_insulin' field).\n"
        : "Diabetic mode: OFF\n";
    final profilePart = profile != null
        ? 'User profile: age=${profile.age}, gender=${profile.gender}, weight=${profile.weightKg}kg, height=${profile.heightCm}cm, activity=${profile.activityLevel}.\n'
        : '';

    return '''
Estimate the nutritional content of a meal described by the user in text.

There is no photo — rely entirely on the user's description. Identify the dishes, infer typical ingredients and preparation, and estimate portion size from any quantities or descriptors the user provides (e.g., "large bowl", "~250g", "small plate"). If portion size is ambiguous, assume a typical adult serving.

Context:
${profilePart}If multiple dishes are mentioned, analyze ALL of them as one meal.

User's allergen list: $allergensStr
$diabeticPart

Required output fields:
- name: concise meal name (e.g., "Grilled Chicken Salad")
- calories: total estimated kcal (integer)
- protein: grams (number)
- carbs: grams (number)
- fat: grams (number)
- glycemic_index: estimated GI 0-100 (integer or null)
- health_score: 1-10 rating (number)
- allergen_warning: warning string if allergens detected from user's list, otherwise null
- estimated_insulin: insulin units (number) only if diabetic mode is ON, otherwise null
''';
  }
}
