import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Bridges the Flutter app and the Android home-screen widget.
/// Writes the latest "today's kcal remaining" snapshot to shared preferences
/// and asks the Android widget provider to redraw.
class MealWidgetService {
  MealWidgetService._();

  static const String _androidWidgetName = 'MealTrackerWidgetProvider';
  static const String _appGroupId = 'com.mealtracker.mealtracker.widget';

  static Future<void> _saveAll(Map<String, Object?> data) async {
    HomeWidget.setAppGroupId(_appGroupId);
    for (final entry in data.entries) {
      await HomeWidget.saveWidgetData(entry.key, entry.value);
    }
  }

  static Future<void> update({
    required int targetKcal,
    required int consumedKcal,
    required String caption,
    required String appLabel,
  }) async {
    if (!_isAndroid) return;
    try {
      final remaining = targetKcal - consumedKcal;
      await _saveAll({
        'widget_target_kcal': targetKcal,
        'widget_consumed_kcal': consumedKcal,
        'widget_remaining_kcal': remaining,
        'widget_caption': caption,
        'widget_app_label': appLabel,
      });
      await HomeWidget.updateWidget(androidName: _androidWidgetName);
    } catch (e) {
      debugPrint('Widget update failed: $e');
    }
  }

  static Future<void> clear() async {
    if (!_isAndroid) return;
    try {
      await _saveAll({
        'widget_target_kcal': 0,
        'widget_consumed_kcal': 0,
        'widget_remaining_kcal': 0,
        'widget_caption': '',
        'widget_app_label': 'MealTracker',
      });
      await HomeWidget.updateWidget(androidName: _androidWidgetName);
    } catch (e) {
      debugPrint('Widget clear failed: $e');
    }
  }

  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
}
