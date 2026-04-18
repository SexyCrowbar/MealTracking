import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/image_prep.dart';
import '../../ai/meal_analyzer.dart';
import '../../core/constants.dart';
import '../../core/photo_cleanup.dart';
import '../../core/theme.dart';
import '../../domain/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/dialogs.dart';
import 'dictation_service.dart';
import 'manual_entry_screen.dart';
import 'result_screen.dart';

class DescribeScreen extends ConsumerStatefulWidget {
  const DescribeScreen({super.key, this.image, this.initialText});

  final File? image;
  final String? initialText;

  @override
  ConsumerState<DescribeScreen> createState() => _DescribeScreenState();
}

class _DescribeScreenState extends ConsumerState<DescribeScreen> {
  final _textCtrl = TextEditingController();
  bool _busy = false;
  bool _handedOff = false;
  bool _listening = false;
  String _partialTranscript = '';

  @override
  void initState() {
    super.initState();
    final seed = widget.initialText?.trim();
    if (seed != null && seed.isNotEmpty) {
      _textCtrl.text = seed;
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    DictationService.instance.cancel();
    if (!_handedOff) {
      // Best-effort: we created or accepted ownership of this photo and never
      // passed it on to a saved meal or queued entry — drop it.
      PhotoCleanup.tryDelete(widget.image?.path);
    }
    super.dispose();
  }

  Future<void> _toggleDictation(String localeCode) async {
    final t = AppLocalizations.of(context);
    if (_listening) {
      await DictationService.instance.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final ok = await DictationService.instance.ensureAvailable();
    if (!ok) {
      if (mounted) showAppSnack(context, t.dictation_unavailable);
      return;
    }
    setState(() {
      _listening = true;
      _partialTranscript = '';
    });
    await DictationService.instance.start(
      localeId: _localeIdFor(localeCode),
      onPartial: (partial) {
        if (!mounted) return;
        setState(() => _partialTranscript = partial);
      },
      onFinal: (transcript) {
        if (!mounted) return;
        final clean = transcript.trim();
        if (clean.isNotEmpty) {
          final existing = _textCtrl.text;
          final separator = existing.isEmpty || existing.endsWith(' ') ? '' : ' ';
          _textCtrl.text = '$existing$separator$clean';
          _textCtrl.selection = TextSelection.collapsed(
            offset: _textCtrl.text.length,
          );
        }
        setState(() {
          _listening = false;
          _partialTranscript = '';
        });
      },
    );
  }

  String _localeIdFor(String code) {
    switch (code) {
      case 'uk':
        return 'uk_UA';
      case 'en':
      default:
        return 'en_US';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final settings = ref.watch(settingsStreamProvider).value;
    final providerKey = settings?.activeProvider ?? AiProvider.gemini;
    final providerName = providerKey == AiProvider.groq
        ? t.provider_label_groq
        : t.provider_label_gemini;
    final localeCode = settings?.locale ?? 'en';

    return Scaffold(
      appBar: AppBar(title: Text(t.ai_analysis)),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.md),
          children: [
            if (widget.image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.file(widget.image!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: AppSpace.md),
            ],
            TextField(
              controller: _textCtrl,
              minLines: widget.image == null ? 4 : 2,
              maxLines: widget.image == null ? 8 : 4,
              decoration: InputDecoration(
                labelText: widget.image == null
                    ? t.describe_meal_only
                    : t.describe_meal,
                suffixIcon: IconButton(
                  tooltip: _listening ? t.dictation_stop : t.dictation_start,
                  onPressed: () => _toggleDictation(localeCode),
                  icon: Icon(
                    _listening ? Icons.stop_circle : Icons.mic,
                    color: _listening ? AppColors.accentRed : AppColors.primary,
                  ),
                ),
              ),
            ),
            if (_listening) ...[
              const SizedBox(height: AppSpace.sm),
              Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Text(
                      _partialTranscript.isEmpty
                          ? t.dictation_listening
                          : _partialTranscript,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpace.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.tips_title,
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    _Tip(text: t.tip_ingredients),
                    _Tip(text: t.tip_portion),
                    _Tip(text: t.tip_method),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : () => _analyze(providerKey),
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_busy
                    ? t.analyzing
                    : t.analyze_btn(providerName)),
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _busy ? null : _openManual,
                child: Text(t.manual_instead),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _analyze(String providerKey) async {
    final t = AppLocalizations.of(context);
    final text = _textCtrl.text.trim();
    if (widget.image == null && text.isEmpty) {
      showAppSnack(context, t.enter_food_name);
      return;
    }
    final settings = ref.read(settingsStreamProvider).value;
    if (settings == null) return;
    final secure = ref.read(secureStoreProvider);
    final apiKey = await secure.getApiKey(providerKey);
    if (apiKey == null || apiKey.isEmpty) {
      if (mounted) showAppSnack(context, t.analysis_failed);
      return;
    }
    setState(() => _busy = true);
    try {
      final bytes = widget.image == null
          ? null
          : await ImagePrep.prepareForUpload(
              file: widget.image!,
              quality: settings.photoQuality,
            );
      final analyzer = ref.read(analyzerProvider(providerKey));
      final profile = await ref.read(profileRepoProvider).getProfile();
      final analysis = await analyzer.analyzeMeal(AnalysisRequest(
        imageBytes: bytes,
        textDescription: text.isEmpty ? null : text,
        apiKey: apiKey,
        model: settings.activeModel,
        allergens: settings.allergensList,
        profile: profile,
        diabeticRatio: settings.diabeticMode ? settings.insulinRatio : null,
      ));
      if (!mounted) return;
      _handedOff = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            analysis: analysis,
            hadText: text.isNotEmpty,
            hadImage: widget.image != null,
            imageFile: widget.image,
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('Meal analysis failed: $e\n$st');
      if (!mounted) return;
      final isOverloaded = e is AiAnalysisException && e.isOverloaded;
      if (isOverloaded) {
        await _showOverloadDialog(providerKey);
      } else {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(t.analysis_failed),
            content: SingleChildScrollView(child: Text(e.toString())),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(t.ok),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showOverloadDialog(String providerKey) async {
    final t = AppLocalizations.of(context);
    final providerName = providerKey == AiProvider.groq
        ? t.provider_label_groq
        : t.provider_label_gemini;
    final shouldQueue = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.overloaded_title),
        content: Text(t.overloaded_body(providerName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.queue_for_retry),
          ),
        ],
      ),
    );
    if (shouldQueue != true || !mounted) return;
    final text = _textCtrl.text.trim();
    await ref.read(queueServiceProvider).enqueueAndMaybeRun(
          imageFile: widget.image,
          textDescription: text.isEmpty ? null : text,
        );
    _handedOff = true;
    if (!mounted) return;
    showAppSnack(context, t.queued);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void _openManual() {
    // Manual flow ignores the photo; let dispose drop it.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ManualEntryScreen()),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.textMuted)),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
