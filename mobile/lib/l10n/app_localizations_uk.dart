// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'MealTracker';

  @override
  String get nav_plan => 'План';

  @override
  String get nav_record => 'Запис';

  @override
  String get nav_progress => 'Прогрес';

  @override
  String get nav_settings => 'Налаштування';

  @override
  String get screen_title_plan => 'Сьогодні';

  @override
  String get screen_title_record => 'Додати страву';

  @override
  String get screen_title_progress => 'Прогрес';

  @override
  String get screen_title_settings => 'Налаштування';

  @override
  String get kcal_remaining => 'ккал залишилось';

  @override
  String get target => 'Ціль';

  @override
  String get low_day => 'Низький день';

  @override
  String get high_day => 'Високий день';

  @override
  String get macros => 'Макронутрієнти';

  @override
  String get protein => 'Білки';

  @override
  String get carbs => 'Вуглеводи';

  @override
  String get fat => 'Жири';

  @override
  String get diabetic_insights => 'Діабетичні дані';

  @override
  String get estimated_insulin => 'Прибл. інсулін';

  @override
  String get units => 'од.';

  @override
  String get todays_meals => 'Сьогоднішні страви';

  @override
  String get no_meals_logged => 'Страви ще не додано';

  @override
  String get setup_profile_msg => 'Налаштуйте профіль, щоб побачити план';

  @override
  String get setup_profile_btn => 'Налаштувати профіль';

  @override
  String get analysis_pending => 'Аналіз триває…';

  @override
  String get queued => 'У черзі';

  @override
  String get failed => 'Помилка';

  @override
  String get retry => 'Повторити';

  @override
  String get manual_entry => 'Ручне введення';

  @override
  String get ai_analysis => 'AI-аналіз';

  @override
  String get food_name => 'Назва страви';

  @override
  String get calories => 'Калорії';

  @override
  String get glycemic_index => 'Глікемічний індекс';

  @override
  String get photo_prompt => 'Сфотографуйте страву';

  @override
  String get describe_meal =>
      'Додайте деталі для точності (напр.: \'курячий суп без вершків, велика миска\')';

  @override
  String get describe_meal_only =>
      'Опишіть, що ви з\'їли (напр.: \'курячий суп з рисом, велика миска, без вершків\')';

  @override
  String get describe_only_title => 'Опис текстом';

  @override
  String get describe_only_subtitle => 'AI-аналіз лише з тексту — без фото';

  @override
  String analyze_btn(String provider) {
    return 'Аналіз через $provider';
  }

  @override
  String get analyzing => 'Аналізую…';

  @override
  String get add_meal_btn => 'Додати страву';

  @override
  String get save_to_log => 'Зберегти у щоденник';

  @override
  String get discard => 'Скасувати';

  @override
  String get remove_photo => 'Прибрати фото';

  @override
  String get use_photo => 'Використати';

  @override
  String get retake_photo => 'Перезняти';

  @override
  String get open_gallery => 'Галерея';

  @override
  String get manual_instead => 'Ввести калорії вручну';

  @override
  String get allergen_warning => 'Попередження про алерген';

  @override
  String get estimated_insulin_meal => 'Орієнтовний інсулін';

  @override
  String get tips_title => 'Поради для точності';

  @override
  String get tip_ingredients =>
      'Згадайте приховані інгредієнти (\"без вершків\", \"без цукру\")';

  @override
  String get tip_portion =>
      'Оцініть розмір порції (\"велика миска\", \"~250 г\")';

  @override
  String get tip_method =>
      'Вкажіть спосіб приготування (\"смажене\", \"варене\")';

  @override
  String get photo_ready => 'Фото готове';

  @override
  String get tap_to_edit => 'Торкніться будь-якого значення для редагування';

  @override
  String get current_weight => 'Поточна вага (кг)';

  @override
  String get calculate_bmi => 'ІМТ';

  @override
  String get update_weight_btn => 'Оновити вагу';

  @override
  String get weight_history => 'Історія ваги';

  @override
  String get adherence_chart => 'Калорії за 30 днів';

  @override
  String get macros_chart => 'Денні макроси';

  @override
  String get ring_flip_hint =>
      'Торкніться кільця, щоб переключити калорії / макроси';

  @override
  String get got_it => 'Зрозуміло';

  @override
  String get meal_history => 'Історія страв';

  @override
  String get no_history => 'Історія порожня';

  @override
  String get ai_config => 'AI-провайдер';

  @override
  String get gemini_api_key => 'API-ключ Gemini';

  @override
  String get groq_api_key => 'API-ключ Groq';

  @override
  String get model => 'Модель';

  @override
  String get test_key => 'Перевірити з\'єднання';

  @override
  String get testing => 'Тестую…';

  @override
  String get success => 'Підключено!';

  @override
  String get test_failed => 'Помилка — перевірте ключ';

  @override
  String get user_profile => 'Профіль';

  @override
  String get age => 'Вік';

  @override
  String get gender => 'Стать';

  @override
  String get male => 'Чоловіча';

  @override
  String get female => 'Жіноча';

  @override
  String get height => 'Зріст (см)';

  @override
  String get weight => 'Вага (кг)';

  @override
  String get goal_weight => 'Цільова вага (кг)';

  @override
  String get activity_level => 'Рівень активності';

  @override
  String get preferences => 'Налаштування';

  @override
  String get show_macros => 'Показувати макронутрієнти';

  @override
  String get show_gi => 'Показувати глікемічний індекс';

  @override
  String get show_insulin => 'Показувати інсулін';

  @override
  String get diabetic_mode => 'Діабетичний режим';

  @override
  String get insulin_ratio => 'Коефіцієнт інсулін:вуглеводи (1 од на X г)';

  @override
  String get insulin_ratio_help =>
      'Типові значення: 8–15 г вуглеводів на 1 одиницю швидкого інсуліну. Уточніть свій коефіцієнт у лікаря.';

  @override
  String get insulin_ratio_invalid => 'Введіть значення від 1 до 100';

  @override
  String get insulin_disclaimer_title => 'Не є медичною порадою';

  @override
  String get insulin_disclaimer_body =>
      'Оцінки інсуліну є лише орієнтовними. Не покладайтеся на них для розрахунку доз. Завжди консультуйтеся з лікарем.';

  @override
  String get diabetic_insights_subtitle =>
      'Приблизний інсулін для сьогоднішніх вуглеводів — не для дозування';

  @override
  String get allergens => 'Алергени (через кому)';

  @override
  String get allergens_hint => 'напр.: арахіс, молочне, глютен';

  @override
  String get save_settings => 'Зберегти';

  @override
  String get language => 'Мова';

  @override
  String get data_retention => 'Термін зберігання';

  @override
  String get photo_quality => 'Якість фото';

  @override
  String get low => 'Низька';

  @override
  String get medium => 'Середня';

  @override
  String get high => 'Висока';

  @override
  String get unlimited => 'Без обмежень';

  @override
  String days_x(int days) {
    return '$days днів';
  }

  @override
  String get sedentary => 'Малорухливий';

  @override
  String get light => 'Легка активність';

  @override
  String get moderate => 'Помірна активність';

  @override
  String get active => 'Висока активність';

  @override
  String get extra => 'Дуже висока активність';

  @override
  String get settings_saved => 'Налаштування збережено';

  @override
  String get weight_updated => 'Вагу оновлено';

  @override
  String get meal_added => 'Страву додано';

  @override
  String get meal_deleted => 'Страву видалено';

  @override
  String get entry_deleted => 'Запис видалено';

  @override
  String get confirm_delete_meal => 'Видалити цю страву?';

  @override
  String get confirm_delete_entry => 'Видалити цей запис?';

  @override
  String get analysis_failed => 'Помилка аналізу';

  @override
  String get provide_text_image => 'Додайте назву та калорії';

  @override
  String get enter_food_name => 'Вкажіть назву страви';

  @override
  String get cancel => 'Скасувати';

  @override
  String get confirm => 'Підтвердити';

  @override
  String get ok => 'Гаразд';

  @override
  String get onboarding_welcome_title => 'Ласкаво просимо до MealTracker';

  @override
  String get onboarding_welcome_body =>
      'Для AI-аналізу страв потрібен безкоштовний API-ключ одного з підтримуваних провайдерів.';

  @override
  String get onboarding_get_started_gemini => 'Почати з Gemini';

  @override
  String get onboarding_get_started_groq => 'Почати з Groq';

  @override
  String get onboarding_skip => 'Пропустити — ручне введення';

  @override
  String get onboarding_recommended => 'Рекомендовано';

  @override
  String onboarding_step_open(String provider) {
    return 'Відкрити консоль $provider';
  }

  @override
  String get onboarding_step_create_key => 'Створіть API-ключ';

  @override
  String get onboarding_step_paste_key => 'Вставте ключ';

  @override
  String get onboarding_paste => 'Вставити';

  @override
  String get onboarding_continue => 'Далі';

  @override
  String get onboarding_open_browser => 'Відкрити в браузері';

  @override
  String get onboarding_skip_msg =>
      'Без проблем! Ключ можна додати у Налаштуваннях. Поки що страви додавайте вручну.';

  @override
  String get onboarding_setup_profile => 'Налаштуйте профіль';

  @override
  String get onboarding_finish => 'Завершити';

  @override
  String get provider_label_gemini => 'Google Gemini';

  @override
  String get provider_label_groq => 'Groq';

  @override
  String get provider_desc_gemini =>
      'Найкраща якість аналізу фото. Безкоштовний тариф.';

  @override
  String get provider_desc_groq =>
      'Найшвидше налаштування, без картки. Миттєвий відгук.';

  @override
  String get tap_camera_to_start => 'Торкніться затвору, щоб зняти фото';

  @override
  String get or_pick_from_gallery => 'або оберіть з галереї';

  @override
  String get permission_camera_denied => 'Дозвіл на камеру відхилено';

  @override
  String get dictation_start => 'Диктування';

  @override
  String get dictation_stop => 'Зупинити диктування';

  @override
  String get dictation_listening => 'Слухаю…';

  @override
  String get dictation_unavailable =>
      'Розпізнавання мовлення недоступне на цьому пристрої';

  @override
  String get dictation_permission_denied => 'Доступ до мікрофона відхилено';

  @override
  String get scan_barcode => 'Сканувати штрих-код';

  @override
  String get scan_barcode_subtitle =>
      'Пошук пакованого продукту в OpenFoodFacts';

  @override
  String get scanning_barcode => 'Наведіть камеру на штрих-код';

  @override
  String get looking_up_barcode => 'Шукаю продукт…';

  @override
  String get barcode_not_found => 'Продукт не знайдено в OpenFoodFacts';

  @override
  String get barcode_lookup_failed => 'Помилка пошуку — перевірте з\'єднання';

  @override
  String get barcode_no_nutrition => 'Продукт без даних про калорії';

  @override
  String get serving_size_g => 'Розмір порції (г)';

  @override
  String get per_100g => 'Значення на 100 г';

  @override
  String get notifications => 'Сповіщення';

  @override
  String get notifications_enabled => 'Увімкнути сповіщення';

  @override
  String get meal_reminders => 'Нагадування про їжу';

  @override
  String get meal_reminders_help => 'Щоденні нагадування додати страву';

  @override
  String get reminder_breakfast => 'Сніданок';

  @override
  String get reminder_lunch => 'Обід';

  @override
  String get reminder_dinner => 'Вечеря';

  @override
  String get reminder_time_label => 'Час';

  @override
  String get reminder_off => 'Вимкнено';

  @override
  String get set_time => 'Вибрати час';

  @override
  String get notif_queue_completion => 'Сповіщати про завершення аналізу';

  @override
  String get notif_breakfast_title => 'Час снідати';

  @override
  String get notif_lunch_title => 'Час обідати';

  @override
  String get notif_dinner_title => 'Час вечеряти';

  @override
  String get notif_meal_body => 'Не забудьте додати те, що їсте.';

  @override
  String get notif_queue_done_title => 'Аналіз готовий';

  @override
  String get notif_queue_done_body => 'Страва з черги вже у журналі дня.';

  @override
  String get notif_permission_denied =>
      'Сповіщення вимкнено в системних налаштуваннях';

  @override
  String get overloaded_title => 'Сервіс ШІ зараз перевантажений';

  @override
  String overloaded_body(String provider) {
    return '$provider зараз перевантажений. Можна скасувати й спробувати пізніше або поставити цю страву в чергу для автоматичної повторної спроби.';
  }

  @override
  String get queue_for_retry => 'Поставити в чергу';

  @override
  String queued_meal_label(String time) {
    return 'У черзі: $time';
  }

  @override
  String get queued_processing => 'Аналізую…';

  @override
  String get queued_section_title => 'Аналіз у черзі';

  @override
  String get saved_meals => 'Збережені страви';

  @override
  String get saved_meals_log_subtitle => 'Записати порцію зі своїх рецептів';

  @override
  String get new_saved_meal => 'Новий рецепт';

  @override
  String get new_saved_meal_subtitle =>
      'Складіть інгредієнти, ШІ порахує підсумки';

  @override
  String get saved_meal_name => 'Назва рецепта';

  @override
  String get saved_meal_name_hint => 'напр., Курка з рисом';

  @override
  String get ingredients => 'Інгредієнти';

  @override
  String get ingredient_description => 'Інгредієнт';

  @override
  String get ingredient_description_hint => 'напр., куряче філе сире';

  @override
  String get ingredient_grams => 'г';

  @override
  String get add_ingredient => 'Додати інгредієнт';

  @override
  String get remove_ingredient => 'Прибрати';

  @override
  String get calculate_and_save => 'Порахувати через ШІ';

  @override
  String get recalculate_with_ai => 'Перерахувати через ШІ';

  @override
  String get recipe_ai_failed =>
      'Не вдалося порахувати — введіть значення вручну';

  @override
  String get recipe_no_ingredients => 'Додайте хоча б один інгредієнт з вагою';

  @override
  String get recipe_invalid_grams =>
      'Кожен інгредієнт має мати додатну вагу в грамах';

  @override
  String recipe_total_weight(String grams) {
    return 'Загальна вага: $grams г';
  }

  @override
  String get saved_meal_saved => 'Рецепт збережено';

  @override
  String get saved_meal_updated => 'Рецепт оновлено';

  @override
  String get saved_meal_deleted => 'Рецепт видалено';

  @override
  String get confirm_delete_saved_meal => 'Видалити цей рецепт?';

  @override
  String get log_portion => 'Записати порцію';

  @override
  String get log_this_portion => 'Записати цю порцію';

  @override
  String get weight_eaten_g => 'З\'їдена вага (г)';

  @override
  String get saved_meals_empty => 'Ви ще не зберегли жодного рецепта';

  @override
  String get saved_meals_empty_cta => 'Створити перший рецепт';

  @override
  String get search_saved_meals => 'Пошук рецептів';

  @override
  String get edit_recipe => 'Редагувати рецепт';

  @override
  String get save_recipe => 'Зберегти рецепт';

  @override
  String get per_100g_short => 'на 100 г';

  @override
  String kcal_per_100g(int kcal) {
    return '$kcal ккал / 100 г';
  }

  @override
  String get extras_optional => 'Додатки (необов\'язково)';

  @override
  String get extras_subtitle =>
      'Все, що ви додали зверху — порахує ШІ під час збереження';

  @override
  String get extras_added => 'Додано';

  @override
  String get extras_calories_after_save =>
      'додатки враховуються при збереженні';

  @override
  String get add_extra => 'Додати позицію';

  @override
  String get extra_hint => 'напр., кетчуп, олія';

  @override
  String get analysis_overloaded =>
      'ШІ-сервіс тимчасове перевантажений — повторіть спробу за кілька хвилин.';

  @override
  String get network_timeout =>
      'Тайм-аут з\'єднання — перевірте мережу та повторіть спробу.';

  @override
  String get network_error =>
      'Сталася мережева помилка — перевірте з\'єднання та повторіть спробу.';
}
