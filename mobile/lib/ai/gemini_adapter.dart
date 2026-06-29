import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/constants.dart';
import '../domain/models/meal_analysis.dart';
import 'meal_analyzer.dart';
import 'parse_utils.dart';
import 'prompt.dart';

class GeminiAdapter implements MealAnalyzer {
  GeminiAdapter({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 120),
            ));

  final Dio _dio;

  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  @override
  String get providerId => AiProvider.gemini;

  @override
  String get providerName => 'Google Gemini';

  @override
  String get providerDescription =>
      'Best photo analysis quality. Free tier included.';

  @override
  String get defaultModel => GeminiModel.defaultModel;

  @override
  String get setupUrl => 'https://aistudio.google.com/app/apikey';

  @override
  List<ModelOption> get availableModels => GeminiModel.all
      .map((id) => ModelOption(id: id, label: GeminiModel.labels[id] ?? id))
      .toList();

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

    final parts = <Map<String, dynamic>>[
      {'text': prompt},
    ];
    if (!request.isRecipe && request.hasImage) {
      parts.add({
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Encode(request.imageBytes!),
        }
      });
    }
    if (!request.isRecipe && userText != null && userText.isNotEmpty) {
      parts.add({'text': 'User description: $userText'});
    }

    final body = {
      'contents': [
        {'parts': parts}
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'responseSchema': _responseSchema(request.diabeticRatio != null &&
            request.diabeticRatio! > 0),
      },
    };

    final url = '$_baseUrl/${request.model}:generateContent';
    final Response<dynamic> resp;
    try {
      resp = await _dio.post(
        url,
        data: body,
        queryParameters: {'key': request.apiKey},
        options: Options(
          contentType: 'application/json',
          responseType: ResponseType.json,
        ),
      );
    } on DioException catch (e) {
      throw AiAnalysisException(
        e.response?.data?.toString() ?? e.message ?? 'network error',
        statusCode: e.response?.statusCode,
      );
    }

    final data = resp.data as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw AiAnalysisException('Gemini returned no candidates',
          statusCode: resp.statusCode);
    }
    final contentMap = candidates.first as Map?;
    final content = contentMap?['content'] as Map?;
    final partsList = content?['parts'] as List?;
    String? text;
    if (partsList is List && partsList.isNotEmpty) {
      final firstPart = partsList.first as Map?;
      text = firstPart?['text'] as String?;
    }
    if (text == null || text.trim().isEmpty) {
      throw AiAnalysisException('Gemini response missing text');
    }

    final json = _parseJson(text);
    requireMealFields(json);
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
        'contents': [
          {
            'parts': [
              {'text': 'ping'}
            ]
          }
        ]
      };
      final url = '$_baseUrl/$model:generateContent';
      final resp = await _dio.post(
        url,
        data: body,
        queryParameters: {'key': apiKey},
        options: Options(
          contentType: 'application/json',
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      if (resp.statusCode != 200) return false;
      final data = resp.data as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      return candidates != null && candidates.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _parseJson(String text) {
    var t = text.trim();
    // Strip ```json fences if present.
    if (t.startsWith('```')) {
      final firstNewline = t.indexOf('\n');
      if (firstNewline > 0) t = t.substring(firstNewline + 1);
      if (t.endsWith('```')) t = t.substring(0, t.length - 3);
      t = t.trim();
    }
    try {
      return jsonDecode(t) as Map<String, dynamic>;
    } catch (_) {
      // Try to extract a JSON object substring.
      final start = t.indexOf('{');
      final end = t.lastIndexOf('}');
      if (start >= 0 && end > start) {
        return jsonDecode(t.substring(start, end + 1)) as Map<String, dynamic>;
      }
      throw AiAnalysisException('Could not parse Gemini response: $text');
    }
  }

  Map<String, dynamic> _responseSchema(bool diabetic) => {
        'type': 'OBJECT',
        'properties': {
          'name': {'type': 'STRING'},
          'calories': {'type': 'INTEGER'},
          'protein': {'type': 'NUMBER'},
          'carbs': {'type': 'NUMBER'},
          'fat': {'type': 'NUMBER'},
          'glycemic_index': {'type': 'INTEGER', 'nullable': true},
          'health_score': {'type': 'NUMBER', 'nullable': true},
          'allergen_warning': {'type': 'STRING', 'nullable': true},
          if (diabetic)
            'estimated_insulin': {'type': 'NUMBER', 'nullable': true},
        },
        'required': ['name', 'calories', 'protein', 'carbs', 'fat'],
      };
}
