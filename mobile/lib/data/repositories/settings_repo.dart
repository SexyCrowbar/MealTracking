import '../../core/constants.dart';
import '../../domain/models/settings.dart';
import '../db/dao/settings_dao.dart';

class SettingsRepository {
  SettingsRepository(this._dao);

  final SettingsDao _dao;

  Future<AppSettings> load() async {
    final map = await _dao.getAll();
    return _fromMap(map);
  }

  Stream<AppSettings> watch() =>
      _dao.watchAll().map(_fromMap);

  Future<void> save(AppSettings s) async {
    await _dao.setValue(SettingsKey.locale, s.locale);
    await _dao.setValue(SettingsKey.showMacros, s.showMacros.toString());
    await _dao.setValue(SettingsKey.showGi, s.showGi.toString());
    await _dao.setValue(SettingsKey.showInsulin, s.showInsulin.toString());
    await _dao.setValue(SettingsKey.diabeticMode, s.diabeticMode.toString());
    await _dao.setValue(SettingsKey.insulinRatio, s.insulinRatio.toString());
    await _dao.setValue(SettingsKey.allergens, s.allergens);
    await _dao.setValue('SettingsKey.activeProvider', s.activeProvider);
    await _dao.setValue(SettingsKey.geminiModel, s.geminiModel);
    await _dao.setValue(SettingsKey.groqModel, s.groqModel);
    await _dao.setValue(SettingsKey.photoQuality, s.photoQuality);
    await _dao.setValue(SettingsKey.retentionDays, s.retentionDays.toString());
    await _dao.setValue(
        SettingsKey.insulinWarningShown, s.insulinWarningShown.toString());
    await _dao.setValue(
        SettingsKey.notificationsEnabled, s.notificationsEnabled.toString());
    await _dao.setValue(
        SettingsKey.breakfastReminderTime, s.breakfastReminderTime);
    await _dao.setValue(SettingsKey.lunchReminderTime, s.lunchReminderTime);
    await _dao.setValue(SettingsKey.dinnerReminderTime, s.dinnerReminderTime);
    await _dao.setValue(
        SettingsKey.notifyQueueCompletion, s.notifyQueueCompletion.toString());
    await _dao.setValue(
        SettingsKey.chartFlipHintShown, s.chartFlipHintShown.toString());
  }

  Future<void> setOne(String key, String value) => _dao.setValue(key, value);

  AppSettings _fromMap(Map<String, String> m) => AppSettings(
        locale: m[SettingsKey.locale] ?? 'en',
        showMacros: (m[SettingsKey.showMacros] ?? 'false') == 'true',
        showGi: (m[SettingsKey.showGi] ?? 'false') == 'true',
        showInsulin: (m[SettingsKey.showInsulin] ?? 'false') == 'true',
        diabeticMode: (m[SettingsKey.diabeticMode] ?? 'false') == 'true',
        insulinRatio: double.tryParse(m[SettingsKey.insulinRatio] ?? '10') ?? 10,
        allergens: m[SettingsKey.allergens] ?? '',
        activeProvider: m['SettingsKey.activeProvider'] ?? AiProvider.gemini,
        geminiModel: m[SettingsKey.geminiModel] ?? GeminiModel.defaultModel,
        groqModel: m[SettingsKey.groqModel] ?? GroqModel.defaultModel,
        photoQuality: m[SettingsKey.photoQuality] ?? PhotoQuality.medium,
        retentionDays:
            int.tryParse(m[SettingsKey.retentionDays] ?? '$defaultRetentionDays') ??
                defaultRetentionDays,
        insulinWarningShown:
            (m[SettingsKey.insulinWarningShown] ?? 'false') == 'true',
        notificationsEnabled:
            (m[SettingsKey.notificationsEnabled] ?? 'false') == 'true',
        breakfastReminderTime: m[SettingsKey.breakfastReminderTime] ?? '',
        lunchReminderTime: m[SettingsKey.lunchReminderTime] ?? '',
        dinnerReminderTime: m[SettingsKey.dinnerReminderTime] ?? '',
        notifyQueueCompletion:
            (m[SettingsKey.notifyQueueCompletion] ?? 'true') == 'true',
        chartFlipHintShown:
            (m[SettingsKey.chartFlipHintShown] ?? 'false') == 'true',
      );
}
