class ActivityLevel {
  const ActivityLevel._();

  static const String sedentary = 'sedentary';
  static const String light = 'light';
  static const String moderate = 'moderate';
  static const String active = 'active';
  static const String extra = 'extra';

  static const Map<String, double> multipliers = {
    sedentary: 1.2,
    light: 1.375,
    moderate: 1.55,
    active: 1.725,
    extra: 1.9,
  };

  static const List<String> all = [sedentary, light, moderate, active, extra];

  static double multiplierFor(String level) =>
      multipliers[level] ?? multipliers[sedentary]!;
}

class Gender {
  const Gender._();
  static const String male = 'male';
  static const String female = 'female';
  static const List<String> all = [male, female];
}

class DayType {
  const DayType._();
  static const String low = 'low';
  static const String high = 'high';
}

class MealSource {
  const MealSource._();
  static const String manual = 'manual';
  static const String aiPhoto = 'ai_photo';
  static const String aiPhotoText = 'ai_photo_text';
  static const String aiText = 'ai_text';
}

class AiProvider {
  const AiProvider._();
  static const String gemini = 'gemini';
  static const String groq = 'groq';
}

class QueueStatus {
  const QueueStatus._();
  static const String pending = 'pending';
  static const String processing = 'processing';
  static const String completed = 'completed';
  static const String failed = 'failed';
}

class SettingsKey {
  const SettingsKey._();
  static const String locale = 'locale';
  static const String showMacros = 'show_macros';
  static const String showGi = 'show_gi';
  static const String showInsulin = 'show_insulin';
  static const String diabeticMode = 'diabetic_mode';
  static const String insulinRatio = 'insulin_ratio';
  static const String allergens = 'allergens';
  static const String geminiModel = 'gemini_model';
  static const String groqModel = 'groq_model';
  static const String photoQuality = 'photo_quality';
  static const String retentionDays = 'retention_days';
  static const String insulinWarningShown = 'insulin_warning_shown';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String breakfastReminderTime = 'breakfast_reminder_time';
  static const String lunchReminderTime = 'lunch_reminder_time';
  static const String dinnerReminderTime = 'dinner_reminder_time';
  static const String notifyQueueCompletion = 'notify_queue_completion';
  static const String chartFlipHintShown = 'chart_flip_hint_shown';
}

class NotificationId {
  const NotificationId._();
  static const int breakfast = 1001;
  static const int lunch = 1002;
  static const int dinner = 1003;
  static const int queueCompletion = 2001;
}

class PhotoQuality {
  const PhotoQuality._();
  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';

  static int pxFor(String q) {
    switch (q) {
      case high:
        return 2048;
      case low:
        return 512;
      case medium:
      default:
        return 1024;
    }
  }
}

const int defaultRetentionDays = 30;
const List<int> retentionDaysOptions = [30, 90, 180, 0]; // 0 = unlimited

class GeminiModel {
  const GeminiModel._();

  // Auto-updating aliases — recommended; track the newest stable revision.
  static const String flashLiteLatest = 'gemini-flash-lite-latest';
  static const String flashLatest = 'gemini-flash-latest';
  static const String proLatest = 'gemini-pro-latest';

  // Pinned stable versions.
  static const String flashLite25 = 'gemini-2.5-flash-lite';
  static const String flash25 = 'gemini-2.5-flash';
  static const String pro25 = 'gemini-2.5-pro';
  static const String flashLite20 = 'gemini-2.0-flash-lite';
  static const String flash20 = 'gemini-2.0-flash';

  // Preview (cutting-edge, behavior may change).
  static const String flash3Preview = 'gemini-3-flash-preview';
  static const String pro3Preview = 'gemini-3-pro-preview';

  static const List<String> all = [
    flashLiteLatest,
    flashLatest,
    proLatest,
    flashLite25,
    flash25,
    pro25,
    flashLite20,
    flash20,
    flash3Preview,
    pro3Preview,
  ];

  static const Map<String, String> labels = {
    flashLiteLatest: 'Flash Lite — latest (highest quota)',
    flashLatest: 'Flash — latest (balanced)',
    proLatest: 'Pro — latest (deepest)',
    flashLite25: 'Gemini 2.5 Flash Lite',
    flash25: 'Gemini 2.5 Flash',
    pro25: 'Gemini 2.5 Pro',
    flashLite20: 'Gemini 2.0 Flash Lite',
    flash20: 'Gemini 2.0 Flash',
    flash3Preview: 'Gemini 3 Flash (preview)',
    pro3Preview: 'Gemini 3 Pro (preview)',
  };

  static const String defaultModel = flashLiteLatest;
}

class GroqModel {
  const GroqModel._();
  static const String scout = 'meta-llama/llama-4-scout-17b-16e-instruct';
  static const String maverick = 'meta-llama/llama-4-maverick-17b-128e-instruct';
  static const List<String> all = [scout, maverick];
  static const Map<String, String> labels = {
    scout: 'Llama 4 Scout 17B (fast)',
    maverick: 'Llama 4 Maverick 17B (deeper)',
  };
  static const String defaultModel = scout;
}

