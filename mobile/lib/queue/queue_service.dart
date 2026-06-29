import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../ai/gemini_adapter.dart';
import '../ai/groq_adapter.dart';
import '../ai/image_prep.dart';
import '../ai/meal_analyzer.dart';
import '../core/constants.dart';
import '../core/photo_cleanup.dart';
import '../data/db/database.dart';
import '../data/repositories/meals_repo.dart';
import '../data/repositories/profile_repo.dart';
import '../data/repositories/settings_repo.dart';
import '../data/secure_storage.dart';
import 'package:drift/drift.dart' show Value;

typedef QueueCompletedCallback = Future<void> Function(int rowId);

class QueueService {
  QueueService({
    required this.db,
    required this.meals,
    required this.profile,
    required this.settings,
    required this.secure,
    Connectivity? connectivity,
    this.onCompleted,
  }) : _connectivity = connectivity ?? Connectivity();

  final AppDatabase db;
  final MealsRepository meals;
  final ProfileRepository profile;
  final SettingsRepository settings;
  final SecureStore secure;
  final Connectivity _connectivity;
  final QueueCompletedCallback? onCompleted;

  static const _retryDelaysSec = [5, 15, 60, 300, 600];

  StreamSubscription? _sub;
  bool _processing = false;

  void start() {
    _sub ??= _connectivity.onConnectivityChanged.listen((states) {
      final online = states.any((s) => s != ConnectivityResult.none);
      if (online) {
        unawaited(processOnce());
      }
    });
    unawaited(processOnce());
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((s) => s != ConnectivityResult.none);
  }

  /// Enqueue a new analysis: copies image to app docs, inserts queue row,
  /// then attempts immediate processing if online.
  Future<int> enqueueAndMaybeRun({
    File? imageFile,
    String? textDescription,
  }) async {
    if (imageFile == null &&
        (textDescription == null || textDescription.trim().isEmpty)) {
      throw ArgumentError('Either imageFile or textDescription is required');
    }
    final id = await db.queueDao.enqueue(
      AnalysisQueueCompanion(
        imagePath: Value(imageFile?.path),
        textDescription: Value(textDescription),
      ),
    );
    if (await isOnline()) {
      unawaited(processOnce());
    }
    return id;
  }

  Future<void> processOnce() async {
    if (_processing) return;
    _processing = true;
    try {
      while (true) {
        final pending = await db.queueDao.getPending();
        if (pending.isEmpty) break;
        final row = pending.first;
        if (!await isOnline()) break;
        await _processRow(row);
      }
    } finally {
      _processing = false;
    }
  }

  Future<void> _processRow(AnalysisQueueRow row) async {
    await db.queueDao.markProcessing(row.id);
    final s = await settings.load();
    final prov = s.activeProvider;
    final apiKey = await secure.getApiKey(prov);
    if (apiKey == null || apiKey.isEmpty) {
      await _markFailedFinal(row.id, 'No API key configured');
      return;
    }
    final analyzer = _adapterFor(prov);
    final model = prov == AiProvider.groq ? s.groqModel : s.geminiModel;
    try {
      final hadText = row.textDescription?.trim().isNotEmpty == true;
      final imagePath = row.imagePath;
      if (imagePath == null && !hadText) {
        await _markFailedFinal(row.id, 'Empty queue entry');
        return;
      }
      Uint8List? bytes;
      if (imagePath != null) {
        final imageFile = File(imagePath);
        if (!await imageFile.exists()) {
          await _markFailedFinal(row.id, 'Image file missing');
          return;
        }
        bytes = await ImagePrep.prepareForUpload(
          file: imageFile,
          quality: s.photoQuality,
        );
      }
      final prof = await profile.getProfile();
      final analysis = await analyzer.analyzeMeal(AnalysisRequest(
        imageBytes: bytes,
        textDescription: row.textDescription,
        apiKey: apiKey,
        model: model,
        allergens: s.allergensList,
        profile: prof,
        diabeticRatio: s.diabeticMode ? s.insulinRatio : null,
      ));
      await db.transaction(() async {
        await meals.insertFromAnalysis(
          analysis,
          source: MealsRepository.sourceFor(
            hadImage: imagePath != null,
            hadText: hadText,
          ),
          at: row.createdAt,
        );
        await db.queueDao.markCompleted(row.id, jsonEncode(analysis.toJson()));
      });
      await PhotoCleanup.tryDelete(imagePath);
      if (onCompleted != null) {
        try {
          await onCompleted!(row.id);
        } catch (e) {
          // Never let notification failures abort queue processing.
        }
      }
    } catch (e) {
      final retries = row.retryCount + 1;
      if (retries >= _retryDelaysSec.length) {
        await _markFailedFinal(row.id, e.toString());
      } else {
        await db.queueDao.markFailed(row.id, e.toString());
        await db.queueDao.bumpRetry(row.id);
        // Schedule a delayed re-check.
        Future<void>.delayed(
          Duration(seconds: _retryDelaysSec[row.retryCount]),
          () => unawaited(processOnce()),
        );
      }
    }
  }

  Future<void> _markFailedFinal(int id, String error) async {
    final rows = await (db.select(db.analysisQueue)
          ..where((r) => r.id.equals(id)))
        .get();
    final imagePath = rows.isEmpty ? null : rows.first.imagePath;
    await (db.update(db.analysisQueue)..where((r) => r.id.equals(id))).write(
      AnalysisQueueCompanion(
        status: const Value('failed'),
        errorMessage: Value(error),
      ),
    );
    await PhotoCleanup.tryDelete(imagePath);
  }

  /// Cancels a queued entry: removes the row and any photo we own.
  Future<void> cancelQueueEntry(int id) async {
    final rows = await (db.select(db.analysisQueue)
          ..where((r) => r.id.equals(id)))
        .get();
    final imagePath = rows.isEmpty ? null : rows.first.imagePath;
    await db.queueDao.deleteEntry(id);
    await PhotoCleanup.tryDelete(imagePath);
  }

  MealAnalyzer _adapterFor(String provider) {
    switch (provider) {
      case AiProvider.groq:
        return GroqAdapter();
      case AiProvider.gemini:
      default:
        return GeminiAdapter();
    }
  }
}
