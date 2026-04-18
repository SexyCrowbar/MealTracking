// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MealTracker';

  @override
  String get nav_plan => 'Plan';

  @override
  String get nav_record => 'Record';

  @override
  String get nav_progress => 'Progress';

  @override
  String get nav_settings => 'Settings';

  @override
  String get screen_title_plan => 'Today';

  @override
  String get screen_title_record => 'Add Meal';

  @override
  String get screen_title_progress => 'Progress';

  @override
  String get screen_title_settings => 'Settings';

  @override
  String get kcal_remaining => 'kcal remaining';

  @override
  String get target => 'Target';

  @override
  String get low_day => 'Low Day';

  @override
  String get high_day => 'High Day';

  @override
  String get macros => 'Macronutrients';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get fat => 'Fat';

  @override
  String get diabetic_insights => 'Diabetic Insights';

  @override
  String get estimated_insulin => 'Est. Insulin';

  @override
  String get units => 'units';

  @override
  String get todays_meals => 'Today\'s Meals';

  @override
  String get no_meals_logged => 'No meals logged yet';

  @override
  String get setup_profile_msg => 'Set up your profile to see your daily plan';

  @override
  String get setup_profile_btn => 'Set up profile';

  @override
  String get analysis_pending => 'Analysis pending…';

  @override
  String get queued => 'Queued';

  @override
  String get failed => 'Failed';

  @override
  String get retry => 'Retry';

  @override
  String get manual_entry => 'Manual Entry';

  @override
  String get ai_analysis => 'AI Analysis';

  @override
  String get food_name => 'Food name';

  @override
  String get calories => 'Calories';

  @override
  String get glycemic_index => 'Glycemic Index';

  @override
  String get photo_prompt => 'Take a photo of your meal';

  @override
  String get describe_meal =>
      'Add details for better accuracy (e.g., \'chicken soup, no cream, large bowl\')';

  @override
  String get describe_meal_only =>
      'Describe what you ate (e.g., \'chicken soup with rice, large bowl, no cream\')';

  @override
  String get describe_only_title => 'Describe in text';

  @override
  String get describe_only_subtitle =>
      'AI analysis from text only — no photo needed';

  @override
  String analyze_btn(String provider) {
    return 'Analyze with $provider';
  }

  @override
  String get analyzing => 'Analyzing…';

  @override
  String get add_meal_btn => 'Add Meal';

  @override
  String get save_to_log => 'Save to Today\'s Log';

  @override
  String get discard => 'Discard';

  @override
  String get remove_photo => 'Remove photo';

  @override
  String get use_photo => 'Use';

  @override
  String get retake_photo => 'Retake';

  @override
  String get open_gallery => 'Open gallery';

  @override
  String get manual_instead => 'Enter calories manually instead';

  @override
  String get allergen_warning => 'Allergen warning';

  @override
  String get estimated_insulin_meal => 'Estimated insulin';

  @override
  String get tips_title => 'Tips for better accuracy';

  @override
  String get tip_ingredients =>
      'Mention hidden ingredients (\"no cream\", \"sugar-free\")';

  @override
  String get tip_portion => 'Estimate portion size (\"large bowl\", \"~250g\")';

  @override
  String get tip_method => 'Specify cooking method (\"fried\", \"steamed\")';

  @override
  String get photo_ready => 'Photo ready';

  @override
  String get tap_to_edit => 'Tap any value to edit';

  @override
  String get current_weight => 'Current weight (kg)';

  @override
  String get calculate_bmi => 'BMI';

  @override
  String get update_weight_btn => 'Update Weight';

  @override
  String get weight_history => 'Weight history';

  @override
  String get adherence_chart => '30-day calorie adherence';

  @override
  String get macros_chart => 'Daily macros';

  @override
  String get ring_flip_hint =>
      'Tap the ring to switch between calories and macros';

  @override
  String get got_it => 'Got it';

  @override
  String get meal_history => 'Meal history';

  @override
  String get no_history => 'No history yet';

  @override
  String get ai_config => 'AI Provider';

  @override
  String get gemini_api_key => 'Gemini API Key';

  @override
  String get groq_api_key => 'Groq API Key';

  @override
  String get model => 'Model';

  @override
  String get test_key => 'Test Connection';

  @override
  String get testing => 'Testing…';

  @override
  String get success => 'Connected!';

  @override
  String get test_failed => 'Test failed — check the key';

  @override
  String get user_profile => 'Profile';

  @override
  String get age => 'Age';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get height => 'Height (cm)';

  @override
  String get weight => 'Weight (kg)';

  @override
  String get goal_weight => 'Goal weight (kg)';

  @override
  String get activity_level => 'Activity level';

  @override
  String get preferences => 'Preferences';

  @override
  String get show_macros => 'Show macronutrients';

  @override
  String get show_gi => 'Show glycemic index';

  @override
  String get show_insulin => 'Show estimated insulin';

  @override
  String get diabetic_mode => 'Diabetic mode';

  @override
  String get insulin_ratio => 'Insulin-to-carb ratio (1 unit per X g)';

  @override
  String get insulin_ratio_help =>
      'Typical values: 8–15 g of carbs per 1 unit of rapid-acting insulin. Ask your doctor for your personal ratio.';

  @override
  String get insulin_ratio_invalid => 'Enter a value between 1 and 100';

  @override
  String get insulin_disclaimer_title => 'Not medical advice';

  @override
  String get insulin_disclaimer_body =>
      'These insulin estimates are informational only. Do not rely on them for dosing decisions. Always consult your doctor.';

  @override
  String get diabetic_insights_subtitle =>
      'Rough insulin for today\'s carbs — not a dosing tool';

  @override
  String get allergens => 'Allergens (comma-separated)';

  @override
  String get allergens_hint => 'e.g., peanuts, dairy, gluten';

  @override
  String get save_settings => 'Save Settings';

  @override
  String get language => 'Language';

  @override
  String get data_retention => 'Data retention';

  @override
  String get photo_quality => 'Photo quality';

  @override
  String get low => 'Low';

  @override
  String get medium => 'Medium';

  @override
  String get high => 'High';

  @override
  String get unlimited => 'Unlimited';

  @override
  String days_x(int days) {
    return '$days days';
  }

  @override
  String get sedentary => 'Sedentary';

  @override
  String get light => 'Lightly Active';

  @override
  String get moderate => 'Moderately Active';

  @override
  String get active => 'Very Active';

  @override
  String get extra => 'Extra Active';

  @override
  String get settings_saved => 'Settings saved';

  @override
  String get weight_updated => 'Weight updated';

  @override
  String get meal_added => 'Meal added';

  @override
  String get meal_deleted => 'Meal deleted';

  @override
  String get entry_deleted => 'Entry deleted';

  @override
  String get confirm_delete_meal => 'Delete this meal?';

  @override
  String get confirm_delete_entry => 'Delete this entry?';

  @override
  String get analysis_failed => 'Analysis failed';

  @override
  String get provide_text_image => 'Please add a food name and calories';

  @override
  String get enter_food_name => 'Please enter a food name';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get ok => 'OK';

  @override
  String get onboarding_welcome_title => 'Welcome to MealTracker';

  @override
  String get onboarding_welcome_body =>
      'To analyze your meals with AI, you\'ll need a free API key from one of our supported providers.';

  @override
  String get onboarding_get_started_gemini => 'Get started with Gemini';

  @override
  String get onboarding_get_started_groq => 'Get started with Groq';

  @override
  String get onboarding_skip => 'Skip — I\'ll use manual entry';

  @override
  String get onboarding_recommended => 'Recommended';

  @override
  String onboarding_step_open(String provider) {
    return 'Open $provider console';
  }

  @override
  String get onboarding_step_create_key => 'Create your API key';

  @override
  String get onboarding_step_paste_key => 'Paste your key here';

  @override
  String get onboarding_paste => 'Paste';

  @override
  String get onboarding_continue => 'Continue';

  @override
  String get onboarding_open_browser => 'Open in browser';

  @override
  String get onboarding_skip_msg =>
      'No problem! Add an API key anytime in Settings. You\'ll be able to log meals manually.';

  @override
  String get onboarding_setup_profile => 'Set up your profile';

  @override
  String get onboarding_finish => 'Finish setup';

  @override
  String get provider_label_gemini => 'Google Gemini';

  @override
  String get provider_label_groq => 'Groq';

  @override
  String get provider_desc_gemini =>
      'Best photo analysis quality. Free tier included.';

  @override
  String get provider_desc_groq =>
      'Fastest setup, no credit card. Instant responses.';

  @override
  String get tap_camera_to_start => 'Tap the shutter to take a photo';

  @override
  String get or_pick_from_gallery => 'or pick from gallery';

  @override
  String get permission_camera_denied => 'Camera permission denied';

  @override
  String get dictation_start => 'Dictate';

  @override
  String get dictation_stop => 'Stop dictation';

  @override
  String get dictation_listening => 'Listening…';

  @override
  String get dictation_unavailable =>
      'Speech recognition unavailable on this device';

  @override
  String get dictation_permission_denied => 'Microphone permission denied';

  @override
  String get scan_barcode => 'Scan barcode';

  @override
  String get scan_barcode_subtitle => 'Look up packaged food in OpenFoodFacts';

  @override
  String get scanning_barcode => 'Point camera at a barcode';

  @override
  String get looking_up_barcode => 'Looking up product…';

  @override
  String get barcode_not_found => 'Product not found in OpenFoodFacts';

  @override
  String get barcode_lookup_failed => 'Lookup failed — check connection';

  @override
  String get barcode_no_nutrition => 'Product has no calorie data';

  @override
  String get serving_size_g => 'Serving size (g)';

  @override
  String get per_100g => 'Values shown per 100 g';

  @override
  String get notifications => 'Notifications';

  @override
  String get notifications_enabled => 'Enable notifications';

  @override
  String get meal_reminders => 'Meal reminders';

  @override
  String get meal_reminders_help => 'Gentle daily nudges to log your meals';

  @override
  String get reminder_breakfast => 'Breakfast';

  @override
  String get reminder_lunch => 'Lunch';

  @override
  String get reminder_dinner => 'Dinner';

  @override
  String get reminder_time_label => 'Time';

  @override
  String get reminder_off => 'Off';

  @override
  String get set_time => 'Set time';

  @override
  String get notif_queue_completion => 'Notify when queued meal is analyzed';

  @override
  String get notif_breakfast_title => 'Time for breakfast';

  @override
  String get notif_lunch_title => 'Time for lunch';

  @override
  String get notif_dinner_title => 'Time for dinner';

  @override
  String get notif_meal_body => 'Don\'t forget to log what you\'re eating.';

  @override
  String get notif_queue_done_title => 'Analysis complete';

  @override
  String get notif_queue_done_body =>
      'Your queued meal is now in today\'s log.';

  @override
  String get notif_permission_denied =>
      'Notifications disabled in system settings';

  @override
  String get overloaded_title => 'AI service is busy';

  @override
  String overloaded_body(String provider) {
    return '$provider is currently overloaded. You can cancel and try again later, or queue this meal to retry automatically every few minutes.';
  }

  @override
  String get queue_for_retry => 'Queue for retry';

  @override
  String queued_meal_label(String time) {
    return 'Queued: $time';
  }

  @override
  String get queued_processing => 'Analyzing now…';

  @override
  String get queued_section_title => 'Pending analyses';
}
