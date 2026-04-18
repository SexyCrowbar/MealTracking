import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class SharedPayload {
  const SharedPayload({this.image, this.text});
  final File? image;
  final String? text;

  bool get isEmpty => image == null && (text == null || text!.isEmpty);
}

/// Listens to `receive_sharing_intent` and emits one `SharedPayload` per
/// shared event (cold-start initial intent + subsequent stream events).
class ShareIntakeService {
  ShareIntakeService._();
  static final ShareIntakeService instance = ShareIntakeService._();

  final StreamController<SharedPayload> _controller =
      StreamController<SharedPayload>.broadcast();
  StreamSubscription<List<SharedMediaFile>>? _sub;
  bool _initialConsumed = false;

  Stream<SharedPayload> get stream => _controller.stream;

  Future<void> init() async {
    if (_sub != null) return;
    _sub = ReceiveSharingIntent.instance.getMediaStream().listen(
      _emit,
      onError: (e) => debugPrint('Share stream error: $e'),
    );
    if (!_initialConsumed) {
      _initialConsumed = true;
      try {
        final initial = await ReceiveSharingIntent.instance.getInitialMedia();
        if (initial.isNotEmpty) {
          _emit(initial);
          ReceiveSharingIntent.instance.reset();
        }
      } catch (e) {
        debugPrint('Initial share intent failed: $e');
      }
    }
  }

  void _emit(List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    File? image;
    String? text;
    for (final f in files) {
      if (f.type == SharedMediaType.image && image == null) {
        image = File(f.path);
      } else if (f.type == SharedMediaType.text && text == null) {
        text = f.path;
      }
    }
    final payload = SharedPayload(image: image, text: text);
    if (!payload.isEmpty) _controller.add(payload);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    await _controller.close();
  }
}
