import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'features/record/share_intake_service.dart';
import 'notifications/notification_service.dart';
import 'queue/background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('Failed to init notifications: $e');
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    try {
      await initBackgroundQueue();
    } catch (e) {
      debugPrint('Failed to init background queue: $e');
    }
    try {
      await ShareIntakeService.instance.init();
    } catch (e) {
      debugPrint('Failed to init share intake: $e');
    }
  }
  runApp(const ProviderScope(child: MealTrackerApp()));
}
