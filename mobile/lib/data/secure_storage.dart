import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants.dart';

class SecureStore {
  SecureStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const _kApiKeyGemini = 'provider_apikey_gemini';
  static const _kApiKeyGroq = 'provider_apikey_groq';

  Future<String?> getApiKey(String provider) async {
    switch (provider) {
      case AiProvider.gemini:
        return _storage.read(key: _kApiKeyGemini);
      case AiProvider.groq:
        return _storage.read(key: _kApiKeyGroq);
    }
    return null;
  }

  Future<void> setApiKey(String provider, String key) async {
    switch (provider) {
      case AiProvider.gemini:
        await _storage.write(key: _kApiKeyGemini, value: key);
        break;
      case AiProvider.groq:
        await _storage.write(key: _kApiKeyGroq, value: key);
        break;
    }
  }

  Future<void> clearApiKey(String provider) async {
    switch (provider) {
      case AiProvider.gemini:
        await _storage.delete(key: _kApiKeyGemini);
        break;
      case AiProvider.groq:
        await _storage.delete(key: _kApiKeyGroq);
        break;
    }
  }

  Future<bool> hasAnyKey() async {
    final g = await _storage.read(key: _kApiKeyGemini);
    final q = await _storage.read(key: _kApiKeyGroq);
    return (g != null && g.isNotEmpty) || (q != null && q.isNotEmpty);
  }
}
