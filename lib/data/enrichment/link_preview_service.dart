import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../file_storage.dart';
import '../models/research_item.dart';
import 'link_utils.dart';

/// Fetches Open Graph / YouTube metadata async and caches into the item (§5 / §11).
class LinkPreviewService {
  LinkPreviewService._();

  static const _uuid = Uuid();
  static const _ua =
      'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/122.0.0.0 Mobile Safari/537.36 CORTEX/1.0';

  static Future<void> enrich(ResearchItem item, Isar isar) async {
    final url = item.sourceUrl?.trim();
    if (url == null || url.isEmpty) return;

    try {
      String? title;
      String? description;
      String? imageUrl;

      final ytId = LinkUtils.youtubeVideoId(url);
      if (ytId != null) {
        final oembed = await _fetchYoutubeOEmbed(url);
        title = oembed?.title;
        imageUrl = oembed?.thumbnailUrl;
        description = oembed?.authorName != null
            ? 'YouTube · ${oembed!.authorName}'
            : 'YouTube video';

        // Guaranteed thumbnail even if oEmbed fails.
        if (imageUrl == null || imageUrl.isEmpty) {
          imageUrl = await _firstReachable(
            LinkUtils.youtubeThumbnailCandidates(ytId),
          );
        }
      }

      // General web links (and YouTube title/desc fallback).
      if (title == null ||
          title.isEmpty ||
          imageUrl == null ||
          imageUrl.isEmpty ||
          ytId == null) {
        final data = await _safeMetadata(url);
        if (data != null) {
          title ??= data.title?.trim();
          description ??= data.description?.trim();
          if (imageUrl == null || imageUrl.isEmpty) {
            imageUrl = data.image?.trim();
          }
        }
      }

      String? imageRef = imageUrl;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final local = await cachePreviewImage(imageUrl);
        if (local != null) {
          imageRef = local;
        } else if (ytId != null) {
          // Try alternate YT CDN sizes if the first download failed.
          for (final alt in LinkUtils.youtubeThumbnailCandidates(ytId)) {
            if (alt == imageUrl) continue;
            final localAlt = await cachePreviewImage(alt);
            if (localAlt != null) {
              imageRef = localAlt;
              break;
            }
          }
        }
      }

      final fresh = await isar.researchItems.get(item.id);
      if (fresh == null) return;

      final nextTitle = (title != null && title.isNotEmpty) ? title : null;
      fresh
        ..previewTitle = nextTitle ?? fresh.previewTitle
        ..previewDescription =
            (description != null && description.isNotEmpty) ? description : null
        ..previewImageUrl = imageRef ?? fresh.previewImageUrl
        ..citation = _buildCitation(
          title: fresh.previewTitle,
          url: url,
          capturedAt: fresh.createdAt,
        );

      await isar.writeTxn(() async {
        await isar.researchItems.put(fresh);
      });
    } catch (e, st) {
      debugPrint('CORTEX link preview failed: $e\n$st');
    }
  }

  static Future<Metadata?> _safeMetadata(String url) async {
    try {
      return await MetadataFetch.extract(url);
    } catch (e) {
      debugPrint('CORTEX MetadataFetch failed: $e');
      return null;
    }
  }

  static Future<_YtOEmbed?> _fetchYoutubeOEmbed(String url) async {
    try {
      final endpoint = Uri.https('www.youtube.com', '/oembed', {
        'url': url,
        'format': 'json',
      });
      final res = await http
          .get(endpoint, headers: {'User-Agent': _ua})
          .timeout(const Duration(seconds: 10));
      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      final json = jsonDecode(res.body);
      if (json is! Map) return null;
      return _YtOEmbed(
        title: (json['title'] as String?)?.trim(),
        thumbnailUrl: (json['thumbnail_url'] as String?)?.trim(),
        authorName: (json['author_name'] as String?)?.trim(),
      );
    } catch (e) {
      debugPrint('CORTEX YouTube oEmbed failed: $e');
      return null;
    }
  }

  static Future<String?> _firstReachable(List<String> urls) async {
    for (final u in urls) {
      try {
        final res = await http
            .head(Uri.parse(u), headers: {'User-Agent': _ua})
            .timeout(const Duration(seconds: 6));
        if (res.statusCode >= 200 && res.statusCode < 300) return u;
        // Some CDNs reject HEAD — try GET range-ish via GET of next cache step.
        if (res.statusCode == 403 || res.statusCode == 405) return u;
      } catch (_) {
        continue;
      }
    }
    return urls.isEmpty ? null : urls.last;
  }

  /// Downloads an OG image into `cortex/previews/<uuid>.<ext>` (relative path).
  static Future<String?> cachePreviewImage(String imageUrl) async {
    try {
      final uri = Uri.tryParse(imageUrl);
      if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
        return null;
      }
      final res = await http
          .get(uri, headers: {'User-Agent': _ua})
          .timeout(const Duration(seconds: 12));
      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      if (res.bodyBytes.isEmpty) return null;
      // YouTube sometimes returns a tiny grey placeholder for missing maxres.
      if (res.bodyBytes.length < 1200 && imageUrl.contains('maxresdefault')) {
        return null;
      }

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

  static String _buildCitation({
    required String? title,
    required String url,
    required DateTime capturedAt,
  }) {
    final host = Uri.tryParse(url)?.host.replaceFirst(RegExp(r'^www\.'), '') ??
        url;
    final t = (title != null && title.isNotEmpty && title != url) ? title : host;
    final date =
        '${capturedAt.year}-${capturedAt.month.toString().padLeft(2, '0')}-${capturedAt.day.toString().padLeft(2, '0')}';
    return '$t. ($date). $host. $url';
  }
}

class _YtOEmbed {
  const _YtOEmbed({this.title, this.thumbnailUrl, this.authorName});
  final String? title;
  final String? thumbnailUrl;
  final String? authorName;
}
