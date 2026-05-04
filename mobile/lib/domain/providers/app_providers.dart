import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/gemini_adapter.dart';
import '../../ai/groq_adapter.dart';
import '../../ai/meal_analyzer.dart';
import '../../core/constants.dart';
import '../../data/db/dao/saved_meal_dao.dart';
import '../../data/db/database.dart';
import '../../data/repositories/meals_repo.dart';
import '../../data/repositories/profile_repo.dart';
import '../../data/repositories/saved_meals_repo.dart';
import '../../data/repositories/settings_repo.dart';
import '../../data/repositories/weight_repo.dart';
import '../../data/secure_storage.dart';
import '../../queue/queue_service.dart';
import '../models/meal.dart';
import '../models/profile.dart';
import '../models/settings.dart';
import '../models/weight_entry.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final secureStoreProvider = Provider<SecureStore>((ref) => SecureStore());

final profileRepoProvider = Provider<ProfileRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ProfileRepository(db.profileDao);
});

final mealsRepoProvider = Provider<MealsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MealsRepository(db.mealDao);
});

final savedMealsRepoProvider = Provider<SavedMealsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SavedMealsRepository(db.savedMealDao);
});

final savedMealsStreamProvider =
    StreamProvider<List<SavedMealRow>>((ref) {
  return ref.watch(savedMealsRepoProvider).watchAll();
});

final savedMealWithIngredientsProvider =
    FutureProvider.family<SavedMealWithIngredients?, int>((ref, id) async {
  return ref.watch(savedMealsRepoProvider).getWithIngredients(id);
});

final weightRepoProvider = Provider<WeightRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return WeightRepository(db.weightDao);
});

final settingsRepoProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsRepository(db.settingsDao);
});

final profileStreamProvider = StreamProvider<Profile?>((ref) {
  return ref.watch(profileRepoProvider).watchProfile();
});

final settingsStreamProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsRepoProvider).watch();
});

final mealsTodayStreamProvider = StreamProvider<List<Meal>>((ref) {
  final now = DateTime.now();
  final iso = '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
  return ref.watch(mealsRepoProvider).watchByDate(iso);
});

final mealsRecentStreamProvider =
    StreamProvider.family<List<Meal>, int>((ref, days) {
  return ref.watch(mealsRepoProvider).watchAllRecent(days);
});

final weightStreamProvider = StreamProvider<List<WeightEntry>>((ref) {
  return ref.watch(weightRepoProvider).watchAll();
});

final analyzerProvider = Provider.family<MealAnalyzer, String>((ref, provider) {
  switch (provider) {
    case AiProvider.groq:
      return GroqAdapter();
    case AiProvider.gemini:
    default:
      return GeminiAdapter();
  }
});

final queueServiceProvider = Provider<QueueService>((ref) {
  final svc = QueueService(
    db: ref.watch(databaseProvider),
    meals: ref.watch(mealsRepoProvider),
    profile: ref.watch(profileRepoProvider),
    settings: ref.watch(settingsRepoProvider),
    secure: ref.watch(secureStoreProvider),
  );
  ref.onDispose(svc.stop);
  return svc;
});

final pendingQueueStreamProvider =
    StreamProvider<List<AnalysisQueueRow>>((ref) {
  return ref.watch(databaseProvider).queueDao.watchPending();
});
