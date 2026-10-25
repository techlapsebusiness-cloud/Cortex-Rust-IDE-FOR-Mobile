/// URL helpers for capture classification + preview enrichment.
abstract final class LinkUtils {
  /// Extract a YouTube video id from common URL shapes, or null.
  static String? youtubeVideoId(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.host.isEmpty) return null;
    final host = uri.host.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');

    if (host == 'youtu.be') {
      final id = uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
      return _validYtId(id);
    }

    if (host == 'youtube.com' ||
        host == 'm.youtube.com' ||
        host == 'music.youtube.com' ||
        host == 'youtube-nocookie.com') {
      final v = uri.queryParameters['v'];
      if (_validYtId(v) != null) return v;

      // /embed/ID, /shorts/ID, /live/ID, /v/ID
      final segs = uri.pathSegments;
      for (var i = 0; i < segs.length - 1; i++) {
        final kind = segs[i].toLowerCase();
        if (kind == 'embed' ||
            kind == 'shorts' ||
            kind == 'live' ||
            kind == 'v') {
          return _validYtId(segs[i + 1]);
        }
      }
    }
    return null;
  }

  static bool isYouTubeUrl(String url) => youtubeVideoId(url) != null;

  /// Prefer high-res; callers should fall back if download fails.
  static List<String> youtubeThumbnailCandidates(String videoId) {
    return [
      'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg',
      'https://i.ytimg.com/vi/$videoId/hqdefault.jpg',
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
    ];
  }

  static String? _validYtId(String? id) {
    if (id == null) return null;
    final cleaned = id.trim();
    // Standard YouTube ids are 11 chars; allow a bit of slack for variants.
    if (cleaned.length < 6 || cleaned.length > 20) return null;
    if (!RegExp(r'^[\w-]+$').hasMatch(cleaned)) return null;
    return cleaned;
  }
}
