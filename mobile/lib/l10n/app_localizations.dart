import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MealTracker'**
  String get appName;

  /// No description provided for @nav_plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get nav_plan;

  /// No description provided for @nav_record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get nav_record;

  /// No description provided for @nav_progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get nav_progress;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @screen_title_plan.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get screen_title_plan;

  /// No description provided for @screen_title_record.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get screen_title_record;

  /// No description provided for @screen_title_progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get screen_title_progress;

  /// No description provided for @screen_title_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get screen_title_settings;

  /// No description provided for @kcal_remaining.
  ///
  /// In en, this message translates to:
  /// **'kcal remaining'**
  String get kcal_remaining;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @low_day.
  ///
  /// In en, this message translates to:
  /// **'Low Day'**
  String get low_day;

  /// No description provided for @high_day.
  ///
  /// In en, this message translates to:
  /// **'High Day'**
  String get high_day;

  /// No description provided for @macros.
  ///
  /// In en, this message translates to:
  /// **'Macronutrients'**
  String get macros;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @diabetic_insights.
  ///
  /// In en, this message translates to:
  /// **'Diabetic Insights'**
  String get diabetic_insights;

  /// No description provided for @estimated_insulin.
  ///
  /// In en, this message translates to:
  /// **'Est. Insulin'**
  String get estimated_insulin;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get units;

  /// No description provided for @todays_meals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meals'**
  String get todays_meals;

  /// No description provided for @no_meals_logged.
  ///
  /// In en, this message translates to:
  /// **'No meals logged yet'**
  String get no_meals_logged;

  /// No description provided for @setup_profile_msg.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile to see your daily plan'**
  String get setup_profile_msg;

  /// No description provided for @setup_profile_btn.
  ///
  /// In en, this message translates to:
  /// **'Set up profile'**
  String get setup_profile_btn;

  /// No description provided for @analysis_pending.
  ///
  /// In en, this message translates to:
  /// **'Analysis pending…'**
  String get analysis_pending;

  /// No description provided for @queued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get queued;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @manual_entry.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manual_entry;

  /// No description provided for @ai_analysis.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get ai_analysis;

  /// No description provided for @food_name.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get food_name;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @glycemic_index.
  ///
  /// In en, this message translates to:
  /// **'Glycemic Index'**
  String get glycemic_index;

  /// No description provided for @photo_prompt.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your meal'**
  String get photo_prompt;

  /// No description provided for @describe_meal.
  ///
  /// In en, this message translates to:
  /// **'Add details for better accuracy (e.g., \'chicken soup, no cream, large bowl\')'**
  String get describe_meal;

  /// No description provided for @describe_meal_only.
  ///
  /// In en, this message translates to:
  /// **'Describe what you ate (e.g., \'chicken soup with rice, large bowl, no cream\')'**
  String get describe_meal_only;

  /// No description provided for @describe_only_title.
  ///
  /// In en, this message translates to:
  /// **'Describe in text'**
  String get describe_only_title;

  /// No description provided for @describe_only_subtitle.
  ///
  /// In en, this message translates to:
  /// **'AI analysis from text only — no photo needed'**
  String get describe_only_subtitle;

  /// No description provided for @analyze_btn.
  ///
  /// In en, this message translates to:
  /// **'Analyze with {provider}'**
  String analyze_btn(String provider);

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing…'**
  String get analyzing;

  /// No description provided for @add_meal_btn.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get add_meal_btn;

  /// No description provided for @save_to_log.
  ///
  /// In en, this message translates to:
  /// **'Save to Today\'s Log'**
  String get save_to_log;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @remove_photo.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get remove_photo;

  /// No description provided for @use_photo.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use_photo;

  /// No description provided for @retake_photo.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake_photo;

  /// No description provided for @open_gallery.
  ///
  /// In en, this message translates to:
  /// **'Open gallery'**
  String get open_gallery;

  /// No description provided for @manual_instead.
  ///
  /// In en, this message translates to:
  /// **'Enter calories manually instead'**
  String get manual_instead;

  /// No description provided for @allergen_warning.
  ///
  /// In en, this message translates to:
  /// **'Allergen warning'**
  String get allergen_warning;

  /// No description provided for @estimated_insulin_meal.
  ///
  /// In en, this message translates to:
  /// **'Estimated insulin'**
  String get estimated_insulin_meal;

  /// No description provided for @tips_title.
  ///
  /// In en, this message translates to:
  /// **'Tips for better accuracy'**
  String get tips_title;

  /// No description provided for @tip_ingredients.
  ///
  /// In en, this message translates to:
  /// **'Mention hidden ingredients (\"no cream\", \"sugar-free\")'**
  String get tip_ingredients;

  /// No description provided for @tip_portion.
  ///
  /// In en, this message translates to:
  /// **'Estimate portion size (\"large bowl\", \"~250g\")'**
  String get tip_portion;

  /// No description provided for @tip_method.
  ///
  /// In en, this message translates to:
  /// **'Specify cooking method (\"fried\", \"steamed\")'**
  String get tip_method;

  /// No description provided for @photo_ready.
  ///
  /// In en, this message translates to:
  /// **'Photo ready'**
  String get photo_ready;

  /// No description provided for @tap_to_edit.
  ///
  /// In en, this message translates to:
  /// **'Tap any value to edit'**
  String get tap_to_edit;

  /// No description provided for @current_weight.
  ///
  /// In en, this message translates to:
  /// **'Current weight (kg)'**
  String get current_weight;

  /// No description provided for @calculate_bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get calculate_bmi;

  /// No description provided for @update_weight_btn.
  ///
  /// In en, this message translates to:
  /// **'Update Weight'**
  String get update_weight_btn;

  /// No description provided for @weight_history.
  ///
  /// In en, this message translates to:
  /// **'Weight history'**
  String get weight_history;

  /// No description provided for @adherence_chart.
  ///
  /// In en, this message translates to:
  /// **'30-day calorie adherence'**
  String get adherence_chart;

  /// No description provided for @macros_chart.
  ///
  /// In en, this message translates to:
  /// **'Daily macros'**
  String get macros_chart;

  /// No description provided for @ring_flip_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap the ring to switch between calories and macros'**
  String get ring_flip_hint;

  /// No description provided for @got_it.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get got_it;

  /// No description provided for @meal_history.
  ///
  /// In en, this message translates to:
  /// **'Meal history'**
  String get meal_history;

  /// No description provided for @no_history.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get no_history;

  /// No description provided for @ai_config.
  ///
  /// In en, this message translates to:
  /// **'AI Provider'**
  String get ai_config;

  /// No description provided for @gemini_api_key.
  ///
  /// In en, this message translates to:
  /// **'Gemini API Key'**
  String get gemini_api_key;

  /// No description provided for @groq_api_key.
  ///
  /// In en, this message translates to:
  /// **'Groq API Key'**
  String get groq_api_key;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @test_key.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get test_key;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing…'**
  String get testing;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Connected!'**
  String get success;

  /// No description provided for @test_failed.
  ///
  /// In en, this message translates to:
  /// **'Test failed — check the key'**
  String get test_failed;

  /// No description provided for @user_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get user_profile;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weight;

  /// No description provided for @goal_weight.
  ///
  /// In en, this message translates to:
  /// **'Goal weight (kg)'**
  String get goal_weight;

  /// No description provided for @activity_level.
  ///
  /// In en, this message translates to:
  /// **'Activity level'**
  String get activity_level;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @show_macros.
  ///
  /// In en, this message translates to:
  /// **'Show macronutrients'**
  String get show_macros;

  /// No description provided for @show_gi.
  ///
  /// In en, this message translates to:
  /// **'Show glycemic index'**
  String get show_gi;

  /// No description provided for @show_insulin.
  ///
  /// In en, this message translates to:
  /// **'Show estimated insulin'**
  String get show_insulin;

  /// No description provided for @diabetic_mode.
  ///
  /// In en, this message translates to:
  /// **'Diabetic mode'**
  String get diabetic_mode;

  /// No description provided for @insulin_ratio.
  ///
  /// In en, this message translates to:
  /// **'Insulin-to-carb ratio (1 unit per X g)'**
  String get insulin_ratio;

  /// No description provided for @insulin_ratio_help.
  ///
  /// In en, this message translates to:
  /// **'Typical values: 8–15 g of carbs per 1 unit of rapid-acting insulin. Ask your doctor for your personal ratio.'**
  String get insulin_ratio_help;

  /// No description provided for @insulin_ratio_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a value between 1 and 100'**
  String get insulin_ratio_invalid;

  /// No description provided for @insulin_disclaimer_title.
  ///
  /// In en, this message translates to:
  /// **'Not medical advice'**
  String get insulin_disclaimer_title;

  /// No description provided for @insulin_disclaimer_body.
  ///
  /// In en, this message translates to:
  /// **'These insulin estimates are informational only. Do not rely on them for dosing decisions. Always consult your doctor.'**
  String get insulin_disclaimer_body;

  /// No description provided for @diabetic_insights_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Rough insulin for today\'s carbs — not a dosing tool'**
  String get diabetic_insights_subtitle;

  /// No description provided for @allergens.
  ///
  /// In en, this message translates to:
  /// **'Allergens (comma-separated)'**
  String get allergens;

  /// No description provided for @allergens_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., peanuts, dairy, gluten'**
  String get allergens_hint;

  /// No description provided for @save_settings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get save_settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @data_retention.
  ///
  /// In en, this message translates to:
  /// **'Data retention'**
  String get data_retention;

  /// No description provided for @photo_quality.
  ///
  /// In en, this message translates to:
  /// **'Photo quality'**
  String get photo_quality;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @days_x.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String days_x(int days);

  /// No description provided for @sedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get sedentary;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Lightly Active'**
  String get light;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderately Active'**
  String get moderate;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Very Active'**
  String get active;

  /// No description provided for @extra.
  ///
  /// In en, this message translates to:
  /// **'Extra Active'**
  String get extra;

  /// No description provided for @settings_saved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settings_saved;

  /// No description provided for @weight_updated.
  ///
  /// In en, this message translates to:
  /// **'Weight updated'**
  String get weight_updated;

  /// No description provided for @meal_added.
  ///
  /// In en, this message translates to:
  /// **'Meal added'**
  String get meal_added;

  /// No description provided for @meal_deleted.
  ///
  /// In en, this message translates to:
  /// **'Meal deleted'**
  String get meal_deleted;

  /// No description provided for @entry_deleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get entry_deleted;

  /// No description provided for @confirm_delete_meal.
  ///
  /// In en, this message translates to:
  /// **'Delete this meal?'**
  String get confirm_delete_meal;

  /// No description provided for @confirm_delete_entry.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get confirm_delete_entry;

  /// No description provided for @analysis_failed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed'**
  String get analysis_failed;

  /// No description provided for @provide_text_image.
  ///
  /// In en, this message translates to:
  /// **'Please add a food name and calories'**
  String get provide_text_image;

  /// No description provided for @enter_food_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter a food name'**
  String get enter_food_name;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @onboarding_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to MealTracker'**
  String get onboarding_welcome_title;

  /// No description provided for @onboarding_welcome_body.
  ///
  /// In en, this message translates to:
  /// **'To analyze your meals with AI, you\'ll need a free API key from one of our supported providers.'**
  String get onboarding_welcome_body;

  /// No description provided for @onboarding_get_started_gemini.
  ///
  /// In en, this message translates to:
  /// **'Get started with Gemini'**
  String get onboarding_get_started_gemini;

  /// No description provided for @onboarding_get_started_groq.
  ///
  /// In en, this message translates to:
  /// **'Get started with Groq'**
  String get onboarding_get_started_groq;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip — I\'ll use manual entry'**
  String get onboarding_skip;

  /// No description provided for @onboarding_recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get onboarding_recommended;

  /// No description provided for @onboarding_step_open.
  ///
  /// In en, this message translates to:
  /// **'Open {provider} console'**
  String onboarding_step_open(String provider);

  /// No description provided for @onboarding_step_create_key.
  ///
  /// In en, this message translates to:
  /// **'Create your API key'**
  String get onboarding_step_create_key;

  /// No description provided for @onboarding_step_paste_key.
  ///
  /// In en, this message translates to:
  /// **'Paste your key here'**
  String get onboarding_step_paste_key;

  /// No description provided for @onboarding_paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get onboarding_paste;

  /// No description provided for @onboarding_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboarding_continue;

  /// No description provided for @onboarding_open_browser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get onboarding_open_browser;

  /// No description provided for @onboarding_skip_msg.
  ///
  /// In en, this message translates to:
  /// **'No problem! Add an API key anytime in Settings. You\'ll be able to log meals manually.'**
  String get onboarding_skip_msg;

  /// No description provided for @onboarding_setup_profile.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile'**
  String get onboarding_setup_profile;

  /// No description provided for @onboarding_finish.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get onboarding_finish;

  /// No description provided for @provider_label_gemini.
  ///
  /// In en, this message translates to:
  /// **'Google Gemini'**
  String get provider_label_gemini;

  /// No description provided for @provider_label_groq.
  ///
  /// In en, this message translates to:
  /// **'Groq'**
  String get provider_label_groq;

  /// No description provided for @provider_desc_gemini.
  ///
  /// In en, this message translates to:
  /// **'Best photo analysis quality. Free tier included.'**
  String get provider_desc_gemini;

  /// No description provided for @provider_desc_groq.
  ///
  /// In en, this message translates to:
  /// **'Fastest setup, no credit card. Instant responses.'**
  String get provider_desc_groq;

  /// No description provided for @tap_camera_to_start.
  ///
  /// In en, this message translates to:
  /// **'Tap the shutter to take a photo'**
  String get tap_camera_to_start;

  /// No description provided for @or_pick_from_gallery.
  ///
  /// In en, this message translates to:
  /// **'or pick from gallery'**
  String get or_pick_from_gallery;

  /// No description provided for @permission_camera_denied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied'**
  String get permission_camera_denied;

  /// No description provided for @dictation_start.
  ///
  /// In en, this message translates to:
  /// **'Dictate'**
  String get dictation_start;

  /// No description provided for @dictation_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop dictation'**
  String get dictation_stop;

  /// No description provided for @dictation_listening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get dictation_listening;

  /// No description provided for @dictation_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition unavailable on this device'**
  String get dictation_unavailable;

  /// No description provided for @dictation_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get dictation_permission_denied;

  /// No description provided for @scan_barcode.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scan_barcode;

  /// No description provided for @scan_barcode_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Look up packaged food in OpenFoodFacts'**
  String get scan_barcode_subtitle;

  /// No description provided for @scanning_barcode.
  ///
  /// In en, this message translates to:
  /// **'Point camera at a barcode'**
  String get scanning_barcode;

  /// No description provided for @looking_up_barcode.
  ///
  /// In en, this message translates to:
  /// **'Looking up product…'**
  String get looking_up_barcode;

  /// No description provided for @barcode_not_found.
  ///
  /// In en, this message translates to:
  /// **'Product not found in OpenFoodFacts'**
  String get barcode_not_found;

  /// No description provided for @barcode_lookup_failed.
  ///
  /// In en, this message translates to:
  /// **'Lookup failed — check connection'**
  String get barcode_lookup_failed;

  /// No description provided for @barcode_no_nutrition.
  ///
  /// In en, this message translates to:
  /// **'Product has no calorie data'**
  String get barcode_no_nutrition;

  /// No description provided for @serving_size_g.
  ///
  /// In en, this message translates to:
  /// **'Serving size (g)'**
  String get serving_size_g;

  /// No description provided for @per_100g.
  ///
  /// In en, this message translates to:
  /// **'Values shown per 100 g'**
  String get per_100g;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notifications_enabled.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get notifications_enabled;

  /// No description provided for @meal_reminders.
  ///
  /// In en, this message translates to:
  /// **'Meal reminders'**
  String get meal_reminders;

  /// No description provided for @meal_reminders_help.
  ///
  /// In en, this message translates to:
  /// **'Gentle daily nudges to log your meals'**
  String get meal_reminders_help;

  /// No description provided for @reminder_breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get reminder_breakfast;

  /// No description provided for @reminder_lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get reminder_lunch;

  /// No description provided for @reminder_dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get reminder_dinner;

  /// No description provided for @reminder_time_label.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminder_time_label;

  /// No description provided for @reminder_off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get reminder_off;

  /// No description provided for @set_time.
  ///
  /// In en, this message translates to:
  /// **'Set time'**
  String get set_time;

  /// No description provided for @notif_queue_completion.
  ///
  /// In en, this message translates to:
  /// **'Notify when queued meal is analyzed'**
  String get notif_queue_completion;

  /// No description provided for @notif_breakfast_title.
  ///
  /// In en, this message translates to:
  /// **'Time for breakfast'**
  String get notif_breakfast_title;

  /// No description provided for @notif_lunch_title.
  ///
  /// In en, this message translates to:
  /// **'Time for lunch'**
  String get notif_lunch_title;

  /// No description provided for @notif_dinner_title.
  ///
  /// In en, this message translates to:
  /// **'Time for dinner'**
  String get notif_dinner_title;

  /// No description provided for @notif_meal_body.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to log what you\'re eating.'**
  String get notif_meal_body;

  /// No description provided for @notif_queue_done_title.
  ///
  /// In en, this message translates to:
  /// **'Analysis complete'**
  String get notif_queue_done_title;

  /// No description provided for @notif_queue_done_body.
  ///
  /// In en, this message translates to:
  /// **'Your queued meal is now in today\'s log.'**
  String get notif_queue_done_body;

  /// No description provided for @notif_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled in system settings'**
  String get notif_permission_denied;

  /// No description provided for @overloaded_title.
  ///
  /// In en, this message translates to:
  /// **'AI service is busy'**
  String get overloaded_title;

  /// No description provided for @overloaded_body.
  ///
  /// In en, this message translates to:
  /// **'{provider} is currently overloaded. You can cancel and try again later, or queue this meal to retry automatically every few minutes.'**
  String overloaded_body(String provider);

  /// No description provided for @queue_for_retry.
  ///
  /// In en, this message translates to:
  /// **'Queue for retry'**
  String get queue_for_retry;

  /// No description provided for @queued_meal_label.
  ///
  /// In en, this message translates to:
  /// **'Queued: {time}'**
  String queued_meal_label(String time);

  /// No description provided for @queued_processing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing now…'**
  String get queued_processing;

  /// No description provided for @queued_section_title.
  ///
  /// In en, this message translates to:
  /// **'Pending analyses'**
  String get queued_section_title;

  /// No description provided for @saved_meals.
  ///
  /// In en, this message translates to:
  /// **'Saved meals'**
  String get saved_meals;

  /// No description provided for @saved_meals_log_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Log a portion from your recipes'**
  String get saved_meals_log_subtitle;

  /// No description provided for @new_saved_meal.
  ///
  /// In en, this message translates to:
  /// **'New saved meal'**
  String get new_saved_meal;

  /// No description provided for @new_saved_meal_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Compose ingredients, AI calculates totals'**
  String get new_saved_meal_subtitle;

  /// No description provided for @saved_meal_name.
  ///
  /// In en, this message translates to:
  /// **'Recipe name'**
  String get saved_meal_name;

  /// No description provided for @saved_meal_name_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Chicken & rice'**
  String get saved_meal_name_hint;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @ingredient_description.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get ingredient_description;

  /// No description provided for @ingredient_description_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., chicken breast, raw'**
  String get ingredient_description_hint;

  /// No description provided for @ingredient_grams.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get ingredient_grams;

  /// No description provided for @add_ingredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get add_ingredient;

  /// No description provided for @remove_ingredient.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove_ingredient;

  /// No description provided for @calculate_and_save.
  ///
  /// In en, this message translates to:
  /// **'Calculate with AI'**
  String get calculate_and_save;

  /// No description provided for @recalculate_with_ai.
  ///
  /// In en, this message translates to:
  /// **'Recalculate with AI'**
  String get recalculate_with_ai;

  /// No description provided for @recipe_ai_failed.
  ///
  /// In en, this message translates to:
  /// **'AI calculation failed — you can enter totals manually'**
  String get recipe_ai_failed;

  /// No description provided for @recipe_no_ingredients.
  ///
  /// In en, this message translates to:
  /// **'Add at least one ingredient with grams'**
  String get recipe_no_ingredients;

  /// No description provided for @recipe_invalid_grams.
  ///
  /// In en, this message translates to:
  /// **'Each ingredient must have a positive weight in grams'**
  String get recipe_invalid_grams;

  /// No description provided for @recipe_total_weight.
  ///
  /// In en, this message translates to:
  /// **'Total weight: {grams} g'**
  String recipe_total_weight(String grams);

  /// No description provided for @saved_meal_saved.
  ///
  /// In en, this message translates to:
  /// **'Recipe saved'**
  String get saved_meal_saved;

  /// No description provided for @saved_meal_updated.
  ///
  /// In en, this message translates to:
  /// **'Recipe updated'**
  String get saved_meal_updated;

  /// No description provided for @saved_meal_deleted.
  ///
  /// In en, this message translates to:
  /// **'Recipe deleted'**
  String get saved_meal_deleted;

  /// No description provided for @confirm_delete_saved_meal.
  ///
  /// In en, this message translates to:
  /// **'Delete this saved recipe?'**
  String get confirm_delete_saved_meal;

  /// No description provided for @log_portion.
  ///
  /// In en, this message translates to:
  /// **'Log a portion'**
  String get log_portion;

  /// No description provided for @log_this_portion.
  ///
  /// In en, this message translates to:
  /// **'Log this portion'**
  String get log_this_portion;

  /// No description provided for @weight_eaten_g.
  ///
  /// In en, this message translates to:
  /// **'Weight eaten (g)'**
  String get weight_eaten_g;

  /// No description provided for @saved_meals_empty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t saved any recipes yet'**
  String get saved_meals_empty;

  /// No description provided for @saved_meals_empty_cta.
  ///
  /// In en, this message translates to:
  /// **'Create your first recipe'**
  String get saved_meals_empty_cta;

  /// No description provided for @search_saved_meals.
  ///
  /// In en, this message translates to:
  /// **'Search recipes'**
  String get search_saved_meals;

  /// No description provided for @edit_recipe.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get edit_recipe;

  /// No description provided for @save_recipe.
  ///
  /// In en, this message translates to:
  /// **'Save recipe'**
  String get save_recipe;

  /// No description provided for @per_100g_short.
  ///
  /// In en, this message translates to:
  /// **'per 100 g'**
  String get per_100g_short;

  /// No description provided for @kcal_per_100g.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal / 100 g'**
  String kcal_per_100g(int kcal);

  /// No description provided for @extras_optional.
  ///
  /// In en, this message translates to:
  /// **'Extras (optional)'**
  String get extras_optional;

  /// No description provided for @extras_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Anything you added on top — calculated by AI on save'**
  String get extras_subtitle;

  /// No description provided for @extras_added.
  ///
  /// In en, this message translates to:
  /// **'Extras added'**
  String get extras_added;

  /// No description provided for @extras_calories_after_save.
  ///
  /// In en, this message translates to:
  /// **'extras counted on save'**
  String get extras_calories_after_save;

  /// No description provided for @add_extra.
  ///
  /// In en, this message translates to:
  /// **'Add extra'**
  String get add_extra;

  /// No description provided for @extra_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., ketchup, olive oil'**
  String get extra_hint;

  /// No description provided for @analysis_overloaded.
  ///
  /// In en, this message translates to:
  /// **'The AI service is temporarily busy — please try again in a few moments.'**
  String get analysis_overloaded;

  /// No description provided for @network_timeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out — check your network and try again.'**
  String get network_timeout;

  /// No description provided for @network_error.
  ///
  /// In en, this message translates to:
  /// **'A network error occurred — please try again.'**
  String get network_error;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
