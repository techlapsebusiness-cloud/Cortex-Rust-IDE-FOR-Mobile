import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../data/models/item_type.dart';
import '../providers/items_provider.dart';

/// Normalized share / drop payload ready for CaptureSheet.
class CapturePayload {
  const CapturePayload({
    required this.type,
    this.text,
    this.sourceUrl,
    this.filePath,
    this.fileName,
    this.mimeType,
  });

  final ItemType type;
  final String? text;
  final String? sourceUrl;
  final String? filePath;
  final String? fileName;
  final String? mimeType;

  String get previewLabel {
    switch (type) {
      case ItemType.text:
        return text ?? 'Text';
      case ItemType.link:
        return sourceUrl ?? text ?? 'Link';
      case ItemType.image:
        return fileName ?? 'Image';
      case ItemType.video:
        return fileName ?? 'Video';
      case ItemType.file:
        return fileName ?? 'File';
    }
  }

  static List<CapturePayload> fromSharedMedia(List<SharedMediaFile> files) {
    final out = <CapturePayload>[];
    for (final f in files) {
      final mapped = _fromOne(f);
      if (mapped != null) out.add(mapped);
    }
    return out;
  }

  static CapturePayload? _fromOne(SharedMediaFile f) {
    final path = f.path;
    final mime = f.mimeType;
    final type = f.type;

    // Text / URL shares often arrive as SharedMediaType.text with path holding the string.
    if (type == SharedMediaType.text || type == SharedMediaType.url) {
      final content = (f.path.isNotEmpty ? f.path : (f.message ?? '')).trim();
      if (content.isEmpty) return null;
      if (ItemsRepository.looksLikeUrl(content) || type == SharedMediaType.url) {
        return CapturePayload(
          type: ItemType.link,
          sourceUrl: content,
          text: f.message,
        );
      }
      return CapturePayload(type: ItemType.text, text: content);
    }

    if (type == SharedMediaType.image ||
        (mime != null && mime.startsWith('image/'))) {
      return CapturePayload(
        type: ItemType.image,
        filePath: path,
        fileName: _basename(path),
        mimeType: mime,
        sourceUrl: f.message,
      );
    }

    if (type == SharedMediaType.video ||
        (mime != null && mime.startsWith('video/'))) {
      return CapturePayload(
        type: ItemType.video,
        filePath: path,
        fileName: _basename(path),
        mimeType: mime,
        sourceUrl: f.message,
      );
    }

    // Generic file
    if (path.isEmpty) {
      final msg = (f.message ?? '').trim();
      if (msg.isEmpty) return null;
      if (ItemsRepository.looksLikeUrl(msg)) {
        return CapturePayload(type: ItemType.link, sourceUrl: msg);
      }
      return CapturePayload(type: ItemType.text, text: msg);
    }

    final resolved = ItemsRepository.typeFromMime(mime, path: path);
    return CapturePayload(
      type: resolved,
      filePath: path,
      fileName: _basename(path),
      mimeType: mime,
      sourceUrl: f.message,
    );
  }

  static String _basename(String path) {
    final parts = path.split(RegExp(r'[/\\]'));
    return parts.isEmpty ? path : parts.last;
  }
}
