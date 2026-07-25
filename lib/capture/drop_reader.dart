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

/// Starts reading every drop item **synchronously** (no awaits), then resolves
/// payloads. Must be invoked directly from `onPerformDrop` — never after an
/// async gap / `unawaited`, or the DataReader is disposed.
Future<List<CapturePayload>> readDropPayloads(PerformDropEvent event) async {
  final pending = <_PendingItem>[];
  for (final item in event.session.items) {
    final reader = item.dataReader;
    if (reader == null) continue;
    pending.add(_PendingItem.start(reader));
  }
  final out = <CapturePayload>[];
  for (final p in pending) {
    final payload = await p.resolve();
    if (payload != null) out.add(payload);
  }
  return out;
}

/// All `getValue` / `getFile` calls happen in [start] with zero awaits.
class _PendingItem {
  _PendingItem._({
    required this.png,
    required this.jpeg,
    required this.webp,
    required this.fileUri,
    required this.namedUri,
    required this.plainText,
  });

  factory _PendingItem.start(DataReader reader) {
    return _PendingItem._(
      png: _startFile(reader, Formats.png),
      jpeg: _startFile(reader, Formats.jpeg),
      webp: _startFile(reader, Formats.webp),
      fileUri: _startValue<Uri>(reader, Formats.fileUri),
      namedUri: _startValue<NamedUri>(reader, Formats.uri),
      plainText: _startValue<String>(reader, Formats.plainText),
    );
  }

  final Future<Uint8List?> png;
  final Future<Uint8List?> jpeg;
  final Future<Uint8List?> webp;
  final Future<Uri?> fileUri;
  final Future<NamedUri?> namedUri;
  final Future<String?> plainText;

  Future<CapturePayload?> resolve() async {
    final pngBytes = await png;
    if (pngBytes != null && pngBytes.isNotEmpty) {
      return CapturePayload(
        type: ItemType.image,
        bytes: pngBytes,
        fileName: 'image.png',
        mimeType: 'image/png',
      );
    }
    final jpegBytes = await jpeg;
    if (jpegBytes != null && jpegBytes.isNotEmpty) {
      return CapturePayload(
        type: ItemType.image,
        bytes: jpegBytes,
        fileName: 'image.jpg',
        mimeType: 'image/jpeg',
      );
    }
    final webpBytes = await webp;
    if (webpBytes != null && webpBytes.isNotEmpty) {
      return CapturePayload(
        type: ItemType.image,
        bytes: webpBytes,
        fileName: 'image.webp',
        mimeType: 'image/webp',
      );
    }

    final file = await fileUri;
    if (file != null) {
      final path = file.toFilePath();
      final type = ItemsRepository.typeFromMime(null, path: path);
      return CapturePayload(
        type: type,
        filePath: path,
        fileName: path.split(RegExp(r'[/\\]')).last,
      );
    }

    final named = await namedUri;
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

    final text = (await plainText)?.trim();
    if (text != null && text.isNotEmpty) {
      if (ItemsRepository.looksLikeUrl(text)) {
        return CapturePayload(type: ItemType.link, sourceUrl: text);
      }
      return CapturePayload(type: ItemType.text, text: text);
    }

    return null;
  }
}

Future<T?> _startValue<T extends Object>(
  DataReader reader,
  ValueFormat<T> format,
) {
  if (!reader.canProvide(format)) return Future<T?>.value(null);

  final completer = Completer<T?>();
  try {
    // Must run before any await in the caller (super_clipboard invariant).
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
  } catch (e) {
    debugPrint('CORTEX drop getValue failed: $e');
    if (!completer.isCompleted) completer.complete(null);
  }
  return completer.future.timeout(
    const Duration(seconds: 8),
    onTimeout: () => null,
  );
}

Future<Uint8List?> _startFile(DataReader reader, FileFormat format) {
  if (!reader.canProvide(format)) return Future<Uint8List?>.value(null);

  final completer = Completer<Uint8List?>();
  try {
    reader.getFile(
      format,
      (file) {
        // Don't await here — schedule read without blocking getFile return.
        file.readAll().then((bytes) {
          if (!completer.isCompleted) completer.complete(bytes);
        }).catchError((Object e) {
          debugPrint('CORTEX drop file read error: $e');
          if (!completer.isCompleted) completer.complete(null);
        });
      },
      onError: (error) {
        debugPrint('CORTEX drop file error: $error');
        if (!completer.isCompleted) completer.complete(null);
      },
    );
  } catch (e) {
    debugPrint('CORTEX drop getFile failed: $e');
    if (!completer.isCompleted) completer.complete(null);
  }
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
