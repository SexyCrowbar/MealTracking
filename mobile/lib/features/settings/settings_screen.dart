import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/settings.dart';
import '../../domain/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../notifications/notification_service.dart';
import '../../widgets/dialogs.dart';
import 'profile_form.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _allergensCtrl = TextEditingController();
  final _ratioCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();
  String? _testStatus; // 'ok', 'fail', 'testing'
  String? _ratioError;
  bool _initialized = false;

  @override
  void dispose() {
    _allergensCtrl.dispose();
    _ratioCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final settingsAsync = ref.watch(settingsStreamProvider);
    final profileAsync = ref.watch(profileStreamProvider);

    return settingsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (s) {
        if (!_initialized) {
          _allergensCtrl.text = s.allergens;
          _ratioCtrl.text =
              s.insulinRatio == 0 ? '' : s.insulinRatio.toStringAsFixed(0);
          _initialized = true;
          _loadApiKey(s.activeProvider);
        }

        return ListView(
          padding: const EdgeInsets.all(AppSpace.md),
          children: [
            Text(t.screen_title_settings,
                style: Theme.of(context).appBarTheme.titleTextStyle),
            const SizedBox(height: AppSpace.md),

            // Language
            _Section(
              title: t.language,
              child: DropdownButtonFormField<String>(
                initialValue: s.locale,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'uk', child: Text('Українська')),
                ],
                onChanged: (v) async {
                  if (v == null) return;
                  await ref
                      .read(settingsRepoProvider)
                      .save(s.copyWith(locale: v));
                },
              ),
            ),

            // Provider
            _Section(
              title: t.ai_config,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: AiProvider.gemini,
                    groupValue: s.activeProvider,
                    title: Text(t.provider_label_gemini),
                    subtitle: Text(t.provider_desc_gemini),
                    onChanged: (v) async {
                      if (v == null) return;
                      await ref
                          .read(settingsRepoProvider)
                          .save(s.copyWith(activeProvider: v));
                      _loadApiKey(v);
                      setState(() {});
                    },
                  ),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: AiProvider.groq,
                    groupValue: s.activeProvider,
                    title: Text(t.provider_label_groq),
                    subtitle: Text(t.provider_desc_groq),
                    onChanged: (v) async {
                      if (v == null) return;
                      await ref
                          .read(settingsRepoProvider)
                          .save(s.copyWith(activeProvider: v));
                      _loadApiKey(v);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: AppSpace.sm),
                  TextField(
                    controller: _apiKeyCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: s.activeProvider == AiProvider.groq
                          ? t.groq_api_key
                          : t.gemini_api_key,
                      hintText: maskApiKey(_apiKeyCtrl.text),
                    ),
                    onChanged: (v) async {
                      await ref
                          .read(secureStoreProvider)
                          .setApiKey(s.activeProvider, v);
                    },
                  ),
                  const SizedBox(height: AppSpace.sm),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: s.activeProvider == AiProvider.groq
                        ? s.groqModel
                        : s.geminiModel,
                    decoration: InputDecoration(labelText: t.model),
                    items: (s.activeProvider == AiProvider.groq
                            ? GroqModel.all
                            : GeminiModel.all)
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(
                                (s.activeProvider == AiProvider.groq
                                        ? GroqModel.labels[m]
                                        : GeminiModel.labels[m]) ??
                                    m,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (v) async {
                      if (v == null) return;
                      final updated = s.activeProvider == AiProvider.groq
                          ? s.copyWith(groqModel: v)
                          : s.copyWith(geminiModel: v);
                      await ref
                          .read(settingsRepoProvider)
                          .save(updated);
                    },
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _testStatus == 'testing'
                            ? null
                            : () => _testKey(s),
                        child: Text(_testStatus == 'testing'
                            ? t.testing
                            : t.test_key),
                      ),
                      const SizedBox(width: AppSpace.sm),
                      if (_testStatus == 'ok')
                        Text(t.success,
                            style: const TextStyle(color: AppColors.primary)),
                      if (_testStatus == 'fail')
                        Text(t.test_failed,
                            style: const TextStyle(color: AppColors.accentRed)),
                    ],
                  ),
                ],
              ),
            ),

            // Profile
            _Section(
              title: t.user_profile,
              child: profileAsync.when(
                loading: () => const SizedBox(
                  height: 80,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (e, _) => Text('$e'),
                data: (p) => ProfileForm(
                  initial: p,
                  onSubmit: (Profile profile) async {
                    await ref.read(profileRepoProvider).save(profile);
                    if (context.mounted) {
                      showAppSnack(context, t.settings_saved);
                    }
                  },
                ),
              ),
            ),

            // Preferences
            _Section(
              title: t.preferences,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.show_macros),
                    value: s.showMacros,
                    onChanged: (v) async {
                      await ref
                          .read(settingsRepoProvider)
                          .save(s.copyWith(showMacros: v));
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.show_gi),
                    value: s.showGi,
                    onChanged: (v) async {
                      await ref
                          .read(settingsRepoProvider)
                          .save(s.copyWith(showGi: v));
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.diabetic_mode),
                    value: s.diabeticMode,
                    onChanged: (v) async {
                      await ref
                          .read(settingsRepoProvider)
                          .save(s.copyWith(diabeticMode: v));
                    },
                  ),
                  if (s.diabeticMode) ...[
                    TextField(
                      controller: _ratioCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: t.insulin_ratio,
                        helperText: t.insulin_ratio_help,
                        helperMaxLines: 2,
                        errorText: _ratioError,
                      ),
                      onChanged: (v) async {
                        final trimmed = v.trim();
                        if (trimmed.isEmpty) {
                          setState(() => _ratioError = null);
                          await ref
                              .read(settingsRepoProvider)
                              .save(s.copyWith(insulinRatio: 0));
                          return;
                        }
                        final n = double.tryParse(trimmed);
                        if (n == null || n < 1 || n > 100) {
                          setState(() => _ratioError = t.insulin_ratio_invalid);
                          return;
                        }
                        setState(() => _ratioError = null);
                        await ref
                            .read(settingsRepoProvider)
                            .save(s.copyWith(insulinRatio: n));
                      },
                    ),
                    const SizedBox(height: AppSpace.sm),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.show_insulin),
                      value: s.showInsulin,
                      onChanged: (v) async {
                        if (v && !s.insulinWarningShown) {
                          await showDialog<void>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(t.insulin_disclaimer_title),
                              content: Text(t.insulin_disclaimer_body),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: Text(t.ok),
                                ),
                              ],
                            ),
                          );
                          await ref.read(settingsRepoProvider).save(
                              s.copyWith(
                                  showInsulin: v, insulinWarningShown: true));
                        } else {
                          await ref
                              .read(settingsRepoProvider)
                              .save(s.copyWith(showInsulin: v));
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Allergens
            _Section(
              title: t.allergens,
              child: TextField(
                controller: _allergensCtrl,
                maxLines: 2,
                decoration: InputDecoration(hintText: t.allergens_hint),
                onChanged: (v) async {
                  await ref
                      .read(settingsRepoProvider)
                      .save(s.copyWith(allergens: v));
                },
              ),
            ),

            // Notifications
            _Section(
              title: t.notifications,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.notifications_enabled),
                    value: s.notificationsEnabled,
                    onChanged: (v) =>
                        _onNotificationsMasterToggle(v, s, t),
                  ),
                  if (s.notificationsEnabled) ...[
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      t.meal_reminders_help,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    _MealReminderRow(
                      label: t.reminder_breakfast,
                      offLabel: t.reminder_off,
                      setLabel: t.set_time,
                      current: s.breakfastReminderTime,
                      onChanged: (v) => ref
                          .read(settingsRepoProvider)
                          .save(s.copyWith(breakfastReminderTime: v)),
                    ),
                    _MealReminderRow(
                      label: t.reminder_lunch,
                      offLabel: t.reminder_off,
                      setLabel: t.set_time,
                      current: s.lunchReminderTime,
                      onChanged: (v) => ref
                          .read(settingsRepoProvider)
                          .save(s.copyWith(lunchReminderTime: v)),
                    ),
                    _MealReminderRow(
                      label: t.reminder_dinner,
                      offLabel: t.reminder_off,
                      setLabel: t.set_time,
                      current: s.dinnerReminderTime,
                      onChanged: (v) => ref
                          .read(settingsRepoProvider)
                          .save(s.copyWith(dinnerReminderTime: v)),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.notif_queue_completion),
                      value: s.notifyQueueCompletion,
                      onChanged: (v) => ref
                          .read(settingsRepoProvider)
                          .save(s.copyWith(notifyQueueCompletion: v)),
                    ),
                  ],
                ],
              ),
            ),

            // Photo quality + retention
            _Section(
              title: t.photo_quality,
              child: DropdownButtonFormField<String>(
                initialValue: s.photoQuality,
                items: [
                  DropdownMenuItem(
                      value: PhotoQuality.low, child: Text(t.low)),
                  DropdownMenuItem(
                      value: PhotoQuality.medium, child: Text(t.medium)),
                  DropdownMenuItem(
                      value: PhotoQuality.high, child: Text(t.high)),
                ],
                onChanged: (v) async {
                  if (v == null) return;
                  await ref
                      .read(settingsRepoProvider)
                      .save(s.copyWith(photoQuality: v));
                },
              ),
            ),
            _Section(
              title: t.data_retention,
              child: DropdownButtonFormField<int>(
                initialValue: s.retentionDays,
                items: retentionDaysOptions
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d == 0 ? t.unlimited : t.days_x(d)),
                        ))
                    .toList(),
                onChanged: (v) async {
                  if (v == null) return;
                  await ref
                      .read(settingsRepoProvider)
                      .save(s.copyWith(retentionDays: v));
                },
              ),
            ),
            const SizedBox(height: AppSpace.lg),
          ],
        );
      },
    );
  }

  Future<void> _loadApiKey(String provider) async {
    final k = await ref.read(secureStoreProvider).getApiKey(provider);
    if (mounted) {
      setState(() => _apiKeyCtrl.text = k ?? '');
    }
  }

  Future<void> _onNotificationsMasterToggle(
      bool v, AppSettings s, AppLocalizations t) async {
    if (v) {
      final granted = await NotificationService.requestPermissions();
      if (!granted) {
        if (mounted) showAppSnack(context, t.notif_permission_denied);
        return;
      }
      final needsDefaults = s.breakfastReminderTime.isEmpty &&
          s.lunchReminderTime.isEmpty &&
          s.dinnerReminderTime.isEmpty;
      await ref.read(settingsRepoProvider).save(
            s.copyWith(
              notificationsEnabled: true,
              breakfastReminderTime:
                  needsDefaults ? '08:00' : s.breakfastReminderTime,
              lunchReminderTime:
                  needsDefaults ? '13:00' : s.lunchReminderTime,
              dinnerReminderTime:
                  needsDefaults ? '19:00' : s.dinnerReminderTime,
            ),
          );
    } else {
      await ref
          .read(settingsRepoProvider)
          .save(s.copyWith(notificationsEnabled: false));
    }
  }

  Future<void> _testKey(s) async {
    final key = _apiKeyCtrl.text.trim();
    if (key.isEmpty) {
      setState(() => _testStatus = 'fail');
      return;
    }
    setState(() => _testStatus = 'testing');
    final analyzer = ref.read(analyzerProvider(s.activeProvider));
    final model = s.activeProvider == AiProvider.groq ? s.groqModel : s.geminiModel;
    final ok = await analyzer.validateApiKey(key, model);
    if (mounted) {
      setState(() => _testStatus = ok ? 'ok' : 'fail');
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textMain,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _MealReminderRow extends StatelessWidget {
  const _MealReminderRow({
    required this.label,
    required this.offLabel,
    required this.setLabel,
    required this.current,
    required this.onChanged,
  });

  final String label;
  final String offLabel;
  final String setLabel;
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final parsed = NotificationService.parseHHmm(current);
    final display = parsed == null ? offLabel : current;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(color: AppColors.textMain)),
          ),
          OutlinedButton(
            onPressed: () => _pickTime(context),
            child: Text(parsed == null ? setLabel : display),
          ),
          if (parsed != null) ...[
            const SizedBox(width: AppSpace.sm),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textMuted),
              tooltip: offLabel,
              onPressed: () => onChanged(''),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final parsed = NotificationService.parseHHmm(current);
    final initial = parsed == null
        ? const TimeOfDay(hour: 12, minute: 0)
        : TimeOfDay(hour: parsed.$1, minute: parsed.$2);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) return;
    onChanged(NotificationService.formatHHmm(picked.hour, picked.minute));
  }
}
