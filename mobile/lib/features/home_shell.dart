import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/calculations.dart';
import '../domain/models/profile.dart';
import '../domain/models/settings.dart';
import '../domain/providers/app_providers.dart';
import '../l10n/app_localizations.dart';
import '../notifications/notification_service.dart';
import '../widget/widget_service.dart';
import 'plan/plan_screen.dart';
import 'progress/progress_screen.dart';
import 'record/describe_screen.dart';
import 'record/record_home_screen.dart';
import 'record/share_intake_service.dart';
import 'settings/settings_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  late int _index = widget.initialIndex;
  AppSettings? _lastNotifSettings;
  StreamSubscription<SharedPayload>? _shareSub;
  int? _lastWidgetTarget;
  int? _lastWidgetConsumed;

  @override
  void initState() {
    super.initState();
    _shareSub = ShareIntakeService.instance.stream.listen(_onSharedPayload);
  }

  @override
  void dispose() {
    _shareSub?.cancel();
    super.dispose();
  }

  void _onSharedPayload(SharedPayload payload) {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    navigator.popUntil((r) => r.isFirst);
    setState(() => _index = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DescribeScreen(
            image: payload.image,
            initialText: payload.text,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final pages = const [
      PlanScreen(),
      RecordHomeScreen(),
      ProgressScreen(),
      SettingsScreen(),
    ];

    final currentSettings = ref.watch(settingsStreamProvider).value;
    if (currentSettings != null &&
        _shouldReschedule(_lastNotifSettings, currentSettings)) {
      _lastNotifSettings = currentSettings;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyMealReminders(currentSettings, t);
      });
    }

    final profile = ref.watch(profileStreamProvider).value;
    final mealsToday = ref.watch(mealsTodayStreamProvider).value;
    if (profile != null && mealsToday != null) {
      final target = _todayTargetFor(profile);
      final consumed = mealsToday.fold<int>(0, (a, m) => a + m.calories);
      if (target != _lastWidgetTarget || consumed != _lastWidgetConsumed) {
        _lastWidgetTarget = target;
        _lastWidgetConsumed = consumed;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          MealWidgetService.update(
            targetKcal: target,
            consumedKcal: consumed,
            caption: t.kcal_remaining,
            appLabel: t.appName,
          );
        });
      }
    }

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: t.nav_plan,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_a_photo_outlined),
            activeIcon: const Icon(Icons.add_a_photo),
            label: t.nav_record,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart_outlined),
            activeIcon: const Icon(Icons.show_chart),
            label: t.nav_progress,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: t.nav_settings,
          ),
        ],
      ),
    );
  }

  bool _shouldReschedule(AppSettings? prev, AppSettings next) {
    if (prev == null) return true;
    return prev.notificationsEnabled != next.notificationsEnabled ||
        prev.breakfastReminderTime != next.breakfastReminderTime ||
        prev.lunchReminderTime != next.lunchReminderTime ||
        prev.dinnerReminderTime != next.dinnerReminderTime ||
        prev.locale != next.locale;
  }

  Future<void> _applyMealReminders(
      AppSettings s, AppLocalizations t) async {
    await NotificationService.applyMealReminders(
      enabled: s.notificationsEnabled,
      breakfastHHmm: s.breakfastReminderTime,
      lunchHHmm: s.lunchReminderTime,
      dinnerHHmm: s.dinnerReminderTime,
      breakfastTitle: t.notif_breakfast_title,
      lunchTitle: t.notif_lunch_title,
      dinnerTitle: t.notif_dinner_title,
      body: t.notif_meal_body,
    );
  }

  int _todayTargetFor(Profile profile) {
    final bmr = calculateBmr(
      weightKg: profile.weightKg,
      heightCm: profile.heightCm,
      age: profile.age,
      isMale: profile.isMale,
    );
    final tdee = calculateTdee(bmr, profile.activityMultiplier);
    final plan = calculateZigZagPlan(
      tdee: tdee,
      goalWeightKg: profile.goalWeightKg,
      currentWeightKg: profile.weightKg,
    );
    return dailyTargetFor(plan, DateTime.now());
  }
}
