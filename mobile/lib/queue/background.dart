import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../data/db/database.dart';
import '../data/repositories/meals_repo.dart';
import '../data/repositories/profile_repo.dart';
import '../data/repositories/settings_repo.dart';
import '../data/secure_storage.dart';
import '../notifications/notification_service.dart';
import 'queue_service.dart';

const String backgroundQueueTask = 'mealtracker.queue.process';
const String backgroundQueueTag = 'mealtracker-queue';

@pragma('vm:entry-point')
void backgroundCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    if (task != backgroundQueueTask) return true;

    final db = AppDatabase();
    try {
      await NotificationService.init();
      final settingsRepo = SettingsRepository(db.settingsDao);
      final appSettings = await settingsRepo.load();
      final locale = appSettings.locale;
      final titles = _queueTitlesFor(locale);

      final svc = QueueService(
        db: db,
        meals: MealsRepository(db.mealDao),
        profile: ProfileRepository(db.profileDao),
        settings: settingsRepo,
        secure: SecureStore(),
        onCompleted: appSettings.notifyQueueCompletion
            ? (rowId) => NotificationService.showQueueCompleted(
                  title: titles.title,
                  body: titles.body,
                )
            : null,
      );
      if (!await svc.isOnline()) return true;
      final pending = await db.queueDao.getPending();
      if (pending.isEmpty) return true;
      await svc.processOnce();
      return true;
    } catch (e) {
      debugPrint('Background queue task failed: $e');
      return false;
    } finally {
      await db.close();
    }
  });
}

class _QueueNotifStrings {
  const _QueueNotifStrings(this.title, this.body);
  final String title;
  final String body;
}

_QueueNotifStrings _queueTitlesFor(String locale) {
  // Background isolate has no AppLocalizations — fall back to bundled strings.
  if (locale == 'uk') {
    return const _QueueNotifStrings(
      'Аналіз готовий',
      'Страва з черги вже у журналі дня.',
    );
  }
  return const _QueueNotifStrings(
    'Analysis complete',
    "Your queued meal is now in today's log.",
  );
}

Future<void> initBackgroundQueue() async {
  await Workmanager().initialize(backgroundCallbackDispatcher);
  await Workmanager().registerPeriodicTask(
    backgroundQueueTag,
    backgroundQueueTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    backoffPolicy: BackoffPolicy.exponential,
    backoffPolicyDelay: const Duration(minutes: 5),
  );
}
