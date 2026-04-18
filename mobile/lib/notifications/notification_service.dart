import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../core/constants.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _mealChannelId = 'meal_reminders';
  static const String _mealChannelName = 'Meal reminders';
  static const String _queueChannelId = 'queue_completion';
  static const String _queueChannelName = 'Queue completion';

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (e) {
      debugPrint('Local timezone lookup failed: $e');
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const init = InitializationSettings(android: androidInit);
    await _plugin.initialize(init);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _mealChannelId,
        _mealChannelName,
        description: 'Daily reminders to log your meals',
        importance: Importance.defaultImportance,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _queueChannelId,
        _queueChannelName,
        description: 'Notifies when a queued meal analysis finishes',
        importance: Importance.defaultImportance,
      ),
    );

    _initialized = true;
  }

  static Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  /// Reschedules all daily meal reminders from the given times.
  /// An empty time string for any meal disables that reminder.
  static Future<void> applyMealReminders({
    required bool enabled,
    required String breakfastHHmm,
    required String lunchHHmm,
    required String dinnerHHmm,
    required String breakfastTitle,
    required String lunchTitle,
    required String dinnerTitle,
    required String body,
  }) async {
    await _plugin.cancel(NotificationId.breakfast);
    await _plugin.cancel(NotificationId.lunch);
    await _plugin.cancel(NotificationId.dinner);
    if (!enabled) return;

    await _scheduleDaily(
      id: NotificationId.breakfast,
      hhmm: breakfastHHmm,
      title: breakfastTitle,
      body: body,
    );
    await _scheduleDaily(
      id: NotificationId.lunch,
      hhmm: lunchHHmm,
      title: lunchTitle,
      body: body,
    );
    await _scheduleDaily(
      id: NotificationId.dinner,
      hhmm: dinnerHHmm,
      title: dinnerTitle,
      body: body,
    );
  }

  static Future<void> _scheduleDaily({
    required int id,
    required String hhmm,
    required String title,
    required String body,
  }) async {
    final parsed = parseHHmm(hhmm);
    if (parsed == null) return;
    final scheduled = _nextInstanceOf(parsed.$1, parsed.$2);
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _mealChannelId,
            _mealChannelName,
            channelDescription: 'Daily reminders to log your meals',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Schedule failed for id=$id: $e');
    }
  }

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> showQueueCompleted({
    required String title,
    required String body,
  }) async {
    try {
      await _plugin.show(
        NotificationId.queueCompletion,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _queueChannelId,
            _queueChannelName,
            channelDescription:
                'Notifies when a queued meal analysis finishes',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Queue completion notification failed: $e');
    }
  }

  static (int, int)? parseHHmm(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return (h, m);
  }

  static String formatHHmm(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
