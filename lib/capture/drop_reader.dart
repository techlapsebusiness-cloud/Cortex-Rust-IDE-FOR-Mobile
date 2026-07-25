import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import '../data/models/item_type.dart';
import '../providers/items_provider.dart';
import 'capture_payload.dart';

/// Formats CORTEX accepts from OS drag-and-drop (§6).
const cortexDropFormats = <DataFormat<Object>>[
  Formats.plainText,
  Formats.uri,
  Formats.fileUri,
  Formats.png,
  Formats.jpeg,
  Formats.webp,
];

/// Reads a [PerformDropEvent] into capture payloads.
/// Call via `unawaited` from `onPerformDrop` so the platform thread stays free.
Future<List<CapturePayload>> readDropPayloads(PerformDropEvent event) async {
  final out = <CapturePayload>[];
  for (final item in event.session.items) {
    final reader = item.dataReader;
    if (reader == null) continue;
    final payload = await _readItem(reader);
    if (payload != null) out.add(payload);
  }
  return out;
}

Future<CapturePayload?> _readItem(DataReader reader) async {
  final png = await _readFileBytes(reader, Formats.png, 'image.png', 'image/png');
  if (png != null) return png;
  final jpeg =
      await _readFileBytes(reader, Formats.jpeg, 'image.jpg', 'image/jpeg');
  if (jpeg != null) return jpeg;
  final webp =
      await _readFileBytes(reader, Formats.webp, 'image.webp', 'image/webp');
  if (webp != null) return webp;

  if (reader.canProvide(Formats.fileUri)) {
    final uri = await _readValue<Uri>(reader, Formats.fileUri);
    if (uri != null) {
      final path = uri.toFilePath();
      final type = ItemsRepository.typeFromMime(null, path: path);
      return CapturePayload(
        type: type,
        filePath: path,
        fileName: path.split(RegExp(r'[/\\]')).last,
      );
    }
  }

  if (reader.canProvide(Formats.uri)) {
    final named = await _readValue<NamedUri>(reader, Formats.uri);
    final uri = named?.uri;
    if (uri != null) {
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        return CapturePayload(type: ItemType.link, sourceUrl: uri.toString());
      }
      if (uri.scheme == 'file') {
        final path = uri.toFilePath();
        final type = ItemsRepository.typeFromMime(null, path: path);
        return CapturePayload(
          type: type,
          filePath: path,
          fileName: path.split(RegExp(r'[/\\]')).last,
        );
      }
      final asString = uri.toString();
      if (ItemsRepository.looksLikeUrl(asString)) {
        return CapturePayload(type: ItemType.link, sourceUrl: asString);
      }
    }
  }

  if (reader.canProvide(Formats.plainText)) {
    final text = await _readValue<String>(reader, Formats.plainText);
    final trimmed = text?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (ItemsRepository.looksLikeUrl(trimmed)) {
      return CapturePayload(type: ItemType.link, sourceUrl: trimmed);
    }
    return CapturePayload(type: ItemType.text, text: trimmed);
  }

  return null;
}

Future<CapturePayload?> _readFileBytes(
  DataReader reader,
  FileFormat format,
  String fileName,
  String mimeType,
) async {
  if (!reader.canProvide(format)) return null;
  final bytes = await _readFileFormat(reader, format);
  if (bytes == null || bytes.isEmpty) return null;
  return CapturePayload(
    type: ItemType.image,
    bytes: bytes,
    fileName: fileName,
    mimeType: mimeType,
  );
}

Future<T?> _readValue<T extends Object>(
  DataReader reader,
  ValueFormat<T> format,
) {
  final completer = Completer<T?>();
  reader.getValue<T>(
    format,
    (value) {
      if (!completer.isCompleted) completer.complete(value);
    },
    onError: (error) {
      debugPrint('CORTEX drop value error: $error');
      if (!completer.isCompleted) completer.complete(null);
    },
  );
  return completer.future.timeout(
    const Duration(seconds: 8),
    onTimeout: () => null,
  );
}

Future<Uint8List?> _readFileFormat(DataReader reader, FileFormat format) {
  final completer = Completer<Uint8List?>();
  reader.getFile(
    format,
    (file) async {
      try {
        final bytes = await file.readAll();
        if (!completer.isCompleted) completer.complete(bytes);
      } catch (e) {
        debugPrint('CORTEX drop file read error: $e');
        if (!completer.isCompleted) completer.complete(null);
      }
    },
    onError: (error) {
      debugPrint('CORTEX drop file error: $error');
      if (!completer.isCompleted) completer.complete(null);
    },
  );
  return completer.future.timeout(
    const Duration(seconds: 15),
    onTimeout: () => null,
  );
}

/// Best-effort check that a file path is readable.
bool filePathExists(String path) {
  try {
    return File(path).existsSync();
  } catch (_) {
    return false;
  }
}
