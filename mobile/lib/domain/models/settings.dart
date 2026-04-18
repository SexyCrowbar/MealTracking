import '../../core/constants.dart';

class AppSettings {
  const AppSettings({
    this.locale = 'en',
    this.showMacros = false,
    this.showGi = false,
    this.showInsulin = false,
    this.diabeticMode = false,
    this.insulinRatio = 10,
    this.allergens = '',
    this.activeProvider = AiProvider.gemini,
    this.geminiModel = GeminiModel.defaultModel,
    this.groqModel = GroqModel.defaultModel,
    this.photoQuality = PhotoQuality.medium,
    this.retentionDays = defaultRetentionDays,
    this.insulinWarningShown = false,
    this.notificationsEnabled = false,
    this.breakfastReminderTime = '',
    this.lunchReminderTime = '',
    this.dinnerReminderTime = '',
    this.notifyQueueCompletion = true,
    this.chartFlipHintShown = false,
  });

  final String locale;
  final bool showMacros;
  final bool showGi;
  final bool showInsulin;
  final bool diabeticMode;
  final double insulinRatio;
  final String allergens;
  final String activeProvider;
  final String geminiModel;
  final String groqModel;
  final String photoQuality;
  final int retentionDays;
  final bool insulinWarningShown;
  final bool notificationsEnabled;
  // Empty string means "reminder off" for that meal. Format: "HH:MM".
  final String breakfastReminderTime;
  final String lunchReminderTime;
  final String dinnerReminderTime;
  final bool notifyQueueCompletion;
  final bool chartFlipHintShown;

  List<String> get allergensList => allergens
      .split(',')
      .map((a) => a.trim())
      .where((a) => a.isNotEmpty)
      .toList();

  String get activeModel =>
      activeProvider == AiProvider.groq ? groqModel : geminiModel;

  AppSettings copyWith({
    String? locale,
    bool? showMacros,
    bool? showGi,
    bool? showInsulin,
    bool? diabeticMode,
    double? insulinRatio,
    String? allergens,
    String? activeProvider,
    String? geminiModel,
    String? groqModel,
    String? photoQuality,
    int? retentionDays,
    bool? insulinWarningShown,
    bool? notificationsEnabled,
    String? breakfastReminderTime,
    String? lunchReminderTime,
    String? dinnerReminderTime,
    bool? notifyQueueCompletion,
    bool? chartFlipHintShown,
  }) =>
      AppSettings(
        locale: locale ?? this.locale,
        showMacros: showMacros ?? this.showMacros,
        showGi: showGi ?? this.showGi,
        showInsulin: showInsulin ?? this.showInsulin,
        diabeticMode: diabeticMode ?? this.diabeticMode,
        insulinRatio: insulinRatio ?? this.insulinRatio,
        allergens: allergens ?? this.allergens,
        activeProvider: activeProvider ?? this.activeProvider,
        geminiModel: geminiModel ?? this.geminiModel,
        groqModel: groqModel ?? this.groqModel,
        photoQuality: photoQuality ?? this.photoQuality,
        retentionDays: retentionDays ?? this.retentionDays,
        insulinWarningShown: insulinWarningShown ?? this.insulinWarningShown,
        notificationsEnabled:
            notificationsEnabled ?? this.notificationsEnabled,
        breakfastReminderTime:
            breakfastReminderTime ?? this.breakfastReminderTime,
        lunchReminderTime: lunchReminderTime ?? this.lunchReminderTime,
        dinnerReminderTime: dinnerReminderTime ?? this.dinnerReminderTime,
        notifyQueueCompletion:
            notifyQueueCompletion ?? this.notifyQueueCompletion,
        chartFlipHintShown:
            chartFlipHintShown ?? this.chartFlipHintShown,
      );
}
