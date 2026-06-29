import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/constants.dart';
import '../domain/models/meal_analysis.dart';
import 'meal_analyzer.dart';
import 'parse_utils.dart';
import 'prompt.dart';

class GroqAdapter implements MealAnalyzer {
  GroqAdapter({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 120),
            ));

  final Dio _dio;
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  @override
  String get providerId => AiProvider.groq;

  @override
  String get providerName => 'Groq';

  @override
  String get providerDescription =>
      'Fastest setup, no credit card needed. Instant responses.';

  @override
  String get defaultModel => GroqModel.defaultModel;

  @override
  String get setupUrl => 'https://console.groq.com/keys';

  @override
  List<ModelOption> get availableModels => const [
        ModelOption(id: GroqModel.scout, label: 'Llama 4 Scout (vision)'),
        ModelOption(id: GroqModel.maverick, label: 'Llama 4 Maverick (vision)'),
      ];

  @override
  Future<MealAnalysis> analyzeMeal(AnalysisRequest request) async {
    final start = DateTime.now();
    final userText = request.textDescription?.trim();
    if (!request.isRecipe &&
        !request.hasImage &&
        (userText == null || userText.isEmpty)) {
      throw AiAnalysisException('No image or description provided');
    }
    final prompt = PromptBuilder.systemInstruction(
      allergens: request.allergens,
      profile: request.profile,
      diabeticRatio: request.diabeticRatio,
      textOnly: !request.hasImage,
      recipeIngredients: request.recipeIngredients,
    );

    final fullPrompt = StringBuffer()
      ..writeln(prompt)
      ..writeln(PromptBuilder.groqExample);
    if (!request.isRecipe && userText != null && userText.isNotEmpty) {
      fullPrompt.writeln('User description: $userText');
    }
    fullPrompt.writeln('Return ONLY a JSON object — no commentary.');

    final content = <Map<String, dynamic>>[
      {'type': 'text', 'text': fullPrompt.toString()},
    ];
    if (!request.isRecipe && request.hasImage) {
      final imageDataUrl =
          'data:image/jpeg;base64,${base64Encode(request.imageBytes!)}';
      content.add({
        'type': 'image_url',
        'image_url': {'url': imageDataUrl},
      });
    }

    final body = {
      'model': request.model,
      'messages': [
        {'role': 'user', 'content': content},
      ],
      'response_format': {'type': 'json_object'},
      'temperature': 0.2,
    };

    final Response<dynamic> resp;
    try {
      resp = await _dio.post(
        _endpoint,
        data: body,
        options: Options(
          contentType: 'application/json',
          headers: {'Authorization': 'Bearer ${request.apiKey}'},
        ),
      );
    } on DioException catch (e) {
      throw AiAnalysisException(
        e.response?.data?.toString() ?? e.message ?? 'network error',
        statusCode: e.response?.statusCode,
      );
    }

    final data = resp.data as Map<String, dynamic>;
    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw AiAnalysisException('No choices in Groq response',
          statusCode: resp.statusCode);
    }
    final messageContent =
        choices.first['message']?['content'] as String?;
    if (messageContent == null || messageContent.isEmpty) {
      throw AiAnalysisException('Empty Groq message');
    }

    final json = _parseJsonWithFallbacks(messageContent);
    requireMealFields(json); // rejects partial regex matches (e.g. calories: 0)
    final latency = DateTime.now().difference(start).inMilliseconds;
    return MealAnalysis(
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : 'Meal',
      calories: (json['calories'] as num?)?.round() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      glycemicIndex: (json['glycemic_index'] as num?)?.round(),
      healthScore: (json['health_score'] as num?)?.toDouble(),
      allergenWarning: (json['allergen_warning'] as String?)?.trim().isEmpty == true
          ? null
          : json['allergen_warning'] as String?,
      estimatedInsulin: (json['estimated_insulin'] as num?)?.toDouble(),
      providerUsed: providerId,
      modelUsed: request.model,
      latencyMs: latency,
    );
  }

  @override
  Future<bool> validateApiKey(String apiKey, String model) async {
    try {
      final body = {
        'model': model,
        'messages': [
          {'role': 'user', 'content': 'ping'}
        ],
        'max_tokens': 5,
      };
      final resp = await _dio.post(
        _endpoint,
        data: body,
        options: Options(
          contentType: 'application/json',
          headers: {'Authorization': 'Bearer $apiKey'},
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _parseJsonWithFallbacks(String text) {
    var t = text.trim();
    // 1) Direct JSON parse.
    try {
      return jsonDecode(t) as Map<String, dynamic>;
    } catch (_) {}
    // 2) Strip markdown fences.
    if (t.startsWith('```')) {
      final firstNewline = t.indexOf('\n');
      if (firstNewline > 0) t = t.substring(firstNewline + 1);
      if (t.endsWith('```')) t = t.substring(0, t.length - 3);
      t = t.trim();
      try {
        return jsonDecode(t) as Map<String, dynamic>;
      } catch (_) {}
    }
    // 3) Extract first {...} object.
    final start = t.indexOf('{');
    final end = t.lastIndexOf('}');
    if (start >= 0 && end > start) {
      try {
        return jsonDecode(t.substring(start, end + 1))
            as Map<String, dynamic>;
      } catch (_) {}
    }
    // 4) Regex fallback for individual fields.
    final result = <String, dynamic>{};
    final patterns = <String, RegExp>{
      'name': RegExp(r'"name"\s*:\s*"([^"]+)"'),
      'calories': RegExp(r'"calories"\s*:\s*(\d+)'),
      'protein': RegExp(r'"protein"\s*:\s*([\d.]+)'),
      'carbs': RegExp(r'"carbs"\s*:\s*([\d.]+)'),
      'fat': RegExp(r'"fat"\s*:\s*([\d.]+)'),
      'glycemic_index': RegExp(r'"glycemic_index"\s*:\s*(\d+)'),
      'health_score': RegExp(r'"health_score"\s*:\s*([\d.]+)'),
    };
    for (final entry in patterns.entries) {
      final m = entry.value.firstMatch(text);
      if (m == null) continue;
      final v = m.group(1)!;
      result[entry.key] = num.tryParse(v) ?? v;
    }
    if (result.isEmpty) {
      throw AiAnalysisException('Could not parse Groq response: $text');
    }
    return result;
  }
}
