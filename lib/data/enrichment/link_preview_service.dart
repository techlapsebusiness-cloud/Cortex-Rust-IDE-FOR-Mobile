import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../file_storage.dart';
import '../models/item.dart';

/// Fetches Open Graph metadata async and caches into the Item (§5 / §11).
class LinkPreviewService {
  LinkPreviewService._();

  static const _uuid = Uuid();

  static Future<void> enrich(Item item, Isar isar) async {
    final url = item.sourceUrl?.trim();
    if (url == null || url.isEmpty) return;

    try {
      final data = await MetadataFetch.extract(url);
      if (data == null) return;

      String? imageRef = data.image;
      if (data.image != null && data.image!.trim().isNotEmpty) {
        final local = await cachePreviewImage(data.image!);
        if (local != null) imageRef = local;
      }

      final title = data.title?.trim();
      final description = data.description?.trim();

      final fresh = await isar.items.get(item.id);
      if (fresh == null) return;

      fresh
        ..previewTitle =
            (title != null && title.isNotEmpty) ? title : fresh.previewTitle
        ..previewDescription =
            (description != null && description.isNotEmpty) ? description : null
        ..previewImageUrl = imageRef ?? fresh.previewImageUrl
        ..rebuildSearchText();

      await isar.writeTxn(() async {
        await isar.items.put(fresh);
      });
    } catch (e, st) {
      debugPrint('CORTEX link preview failed: $e\n$st');
    }
  }

  /// Downloads an OG image into `cortex/previews/<uuid>.<ext>` (relative path).
  static Future<String?> cachePreviewImage(String imageUrl) async {
    try {
      final uri = Uri.tryParse(imageUrl);
      if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
        return null;
      }
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      if (res.bodyBytes.isEmpty) return null;

      final ext = _extFromUrlOrContentType(imageUrl, res.headers['content-type']);
      final docs = await FileStorage.docsDir();
      final relPath =
          p.join('cortex', 'previews', '${_uuid.v4()}$ext').replaceAll('\\', '/');
      final dest = File(p.join(docs.path, relPath));
      await dest.parent.create(recursive: true);
      await dest.writeAsBytes(res.bodyBytes, flush: true);
      return relPath;
    } catch (e) {
      debugPrint('CORTEX preview image cache failed: $e');
      return null;
    }
  }

  static String _extFromUrlOrContentType(String url, String? contentType) {
    final fromUrl = p.extension(Uri.tryParse(url)?.path ?? '');
    if (fromUrl.length >= 2 && fromUrl.length <= 5) return fromUrl;
    final ct = (contentType ?? '').toLowerCase();
    if (ct.contains('png')) return '.png';
    if (ct.contains('webp')) return '.webp';
    if (ct.contains('gif')) return '.gif';
    return '.jpg';
  }

  static bool isCachedLocalPath(String? ref) {
    if (ref == null || ref.isEmpty) return false;
    return !ref.startsWith('http://') && !ref.startsWith('https://');
  }
}
