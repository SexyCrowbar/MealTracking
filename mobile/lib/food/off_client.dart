import 'package:dio/dio.dart';

class OffProduct {
  const OffProduct({
    required this.barcode,
    required this.name,
    required this.kcalPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.brand,
  });

  final String barcode;
  final String name;
  final double kcalPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;
  final String? brand;

  bool get hasMacros =>
      proteinPer100g != null || carbsPer100g != null || fatPer100g != null;
}

class OffLookupException implements Exception {
  OffLookupException(this.message, {this.notFound = false, this.noNutrition = false});
  final String message;
  final bool notFound;
  final bool noNutrition;
  @override
  String toString() => 'OffLookupException: $message';
}

/// Thin client for the OpenFoodFacts public API. No auth needed.
/// Endpoint: https://world.openfoodfacts.org/api/v2/product/{barcode}.json
class OffClient {
  OffClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {
                'User-Agent': 'MealTracker/0.1 (flutter)',
              },
            ));

  final Dio _dio;

  Future<OffProduct> lookup(String barcode) async {
    final code = barcode.trim();
    if (code.isEmpty) {
      throw OffLookupException('Empty barcode');
    }
    final url =
        'https://world.openfoodfacts.org/api/v2/product/$code.json?fields=product_name,brands,nutriments';
    final Response<dynamic> resp;
    try {
      resp = await _dio.get<dynamic>(url);
    } catch (e) {
      throw OffLookupException('Network error: $e');
    }
    final data = resp.data;
    if (data is! Map) {
      throw OffLookupException('Bad response shape');
    }
    final status = data['status'];
    if (status != 1) {
      throw OffLookupException('Not found', notFound: true);
    }
    final product = data['product'];
    if (product is! Map) {
      throw OffLookupException('Missing product', notFound: true);
    }
    final name = (product['product_name'] as String?)?.trim();
    final brand = (product['brands'] as String?)?.trim();
    final nutriments = product['nutriments'];
    final kcal = nutriments is Map
        ? _readNumber(nutriments['energy-kcal_100g']) ??
            _energyToKcal(_readNumber(nutriments['energy_100g']))
        : null;
    if (kcal == null || kcal <= 0) {
      throw OffLookupException('No nutrition data', noNutrition: true);
    }
    return OffProduct(
      barcode: code,
      name: name == null || name.isEmpty ? code : name,
      brand: brand?.isEmpty ?? true ? null : brand,
      kcalPer100g: kcal,
      proteinPer100g:
          nutriments is Map ? _readNumber(nutriments['proteins_100g']) : null,
      carbsPer100g: nutriments is Map
          ? _readNumber(nutriments['carbohydrates_100g'])
          : null,
      fatPer100g:
          nutriments is Map ? _readNumber(nutriments['fat_100g']) : null,
    );
  }

  static double? _readNumber(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  // Off may return only `energy_100g` in kJ. Convert to kcal (1 kcal ~ 4.184 kJ).
  static double? _energyToKcal(double? kj) {
    if (kj == null || kj <= 0) return null;
    return kj / 4.184;
  }
}
