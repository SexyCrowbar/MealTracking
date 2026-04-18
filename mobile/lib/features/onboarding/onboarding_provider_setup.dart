import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../domain/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/dialogs.dart';
import 'onboarding_profile.dart';

class OnboardingProviderSetup extends ConsumerStatefulWidget {
  const OnboardingProviderSetup({super.key, required this.provider});
  final String provider;

  @override
  ConsumerState<OnboardingProviderSetup> createState() =>
      _OnboardingProviderSetupState();
}

class _OnboardingProviderSetupState
    extends ConsumerState<OnboardingProviderSetup> {
  final _keyCtrl = TextEditingController();
  bool _busy = false;

  String get _setupUrl => widget.provider == AiProvider.groq
      ? 'https://console.groq.com/keys'
      : 'https://aistudio.google.com/app/apikey';

  String _providerName(AppLocalizations t) => widget.provider == AiProvider.groq
      ? t.provider_label_groq
      : t.provider_label_gemini;

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final name = _providerName(t);
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.lg),
          children: [
            _Step(
              n: 1,
              title: t.onboarding_step_open(name),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openUrl,
                  icon: const Icon(Icons.open_in_browser),
                  label: Text(t.onboarding_open_browser),
                ),
              ),
            ),
            const SizedBox(height: AppSpace.md),
            _Step(
              n: 2,
              title: t.onboarding_step_create_key,
              child: const SizedBox(),
            ),
            const SizedBox(height: AppSpace.md),
            _Step(
              n: 3,
              title: t.onboarding_step_paste_key,
              child: Column(
                children: [
                  TextField(
                    controller: _keyCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: widget.provider == AiProvider.groq
                          ? t.groq_api_key
                          : t.gemini_api_key,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.paste),
                        onPressed: _paste,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _busy ? null : _continue,
                child: Text(_busy ? t.testing : t.onboarding_continue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl() async {
    final uri = Uri.parse(_setupUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) showAppSnack(context, _setupUrl);
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() => _keyCtrl.text = data!.text!.trim());
    }
  }

  Future<void> _continue() async {
    final t = AppLocalizations.of(context);
    final key = _keyCtrl.text.trim();
    if (key.isEmpty) {
      showAppSnack(context, t.test_failed);
      return;
    }
    setState(() => _busy = true);
    try {
      final analyzer = ref.read(analyzerProvider(widget.provider));
      final settings = await ref.read(settingsRepoProvider).load();
      final model = widget.provider == AiProvider.groq
          ? settings.groqModel
          : settings.geminiModel;
      final ok = await analyzer.validateApiKey(key, model);
      if (!ok) {
        if (mounted) showAppSnack(context, t.test_failed);
        return;
      }
      await ref.read(secureStoreProvider).setApiKey(widget.provider, key);
      await ref
          .read(settingsRepoProvider)
          .save(settings.copyWith(activeProvider: widget.provider));
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OnboardingProfile()),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.n, required this.title, required this.child});
  final int n;
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
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$n',
                    style: const TextStyle(
                      color: Color(0xFF0D1B2A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            child,
          ],
        ),
      ),
    );
  }
}
