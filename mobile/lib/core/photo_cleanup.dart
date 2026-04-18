import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Best-effort deletion of meal photos owned by the app.
///
/// To avoid touching user-owned files (e.g. originals picked from the gallery),
/// only files that live inside the app's documents directory are deleted.
class PhotoCleanup {
  const PhotoCleanup._();

  static Future<void> tryDelete(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final docs = await getApplicationDocumentsDirectory();
      final normalized = p.normalize(path);
      final docsRoot = p.normalize(docs.path);
      final isOwned = p.isWithin(docsRoot, normalized) ||
          p.equals(docsRoot, p.dirname(normalized));
      if (!isOwned) return;
      final file = File(normalized);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('PhotoCleanup.tryDelete failed for $path: $e');
    }
  }
}
