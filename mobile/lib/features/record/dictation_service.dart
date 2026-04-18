import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Thin wrapper around `speech_to_text` that owns a single speech instance and
/// exposes a simple start/stop interface.
class DictationService {
  DictationService._();
  static final DictationService instance = DictationService._();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _available = false;

  bool get isListening => _speech.isListening;

  Future<bool> ensureAvailable() async {
    if (_available) return true;
    try {
      _available = await _speech.initialize(
        onError: (e) => debugPrint('Dictation error: ${e.errorMsg}'),
        onStatus: (s) => debugPrint('Dictation status: $s'),
      );
    } catch (e) {
      debugPrint('Dictation init failed: $e');
      _available = false;
    }
    return _available;
  }

  Future<void> start({
    required String localeId,
    required void Function(String transcript) onFinal,
    void Function(String partial)? onPartial,
  }) async {
    if (!await ensureAvailable()) return;
    await _speech.listen(
      localeId: localeId,
      listenOptions: stt.SpeechListenOptions(
        partialResults: onPartial != null,
        listenMode: stt.ListenMode.dictation,
      ),
      onResult: (result) {
        if (result.finalResult) {
          onFinal(result.recognizedWords);
        } else if (onPartial != null) {
          onPartial(result.recognizedWords);
        }
      },
    );
  }

  Future<void> stop() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  Future<void> cancel() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }
}
