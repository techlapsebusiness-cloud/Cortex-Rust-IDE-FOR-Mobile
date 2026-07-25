import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Copies bytes into app documents under `cortex/<topicId>/<uuid>.<ext>`
/// and returns a path **relative** to the documents directory.
class FileStorage {
  FileStorage._();

  static const _uuid = Uuid();

  static Future<Directory> docsDir() => getApplicationDocumentsDirectory();

  static Future<String> absoluteFromRelative(String relPath) async {
    final docs = await docsDir();
    return p.join(docs.path, relPath);
  }

  static Future<StoredFile> copyFile({
    required File source,
    required int topicId,
    String? preferredName,
    String? mimeType,
  }) async {
    final docs = await docsDir();
    final ext = _extensionOf(source.path, preferredName);
    final fileName = preferredName ?? p.basename(source.path);
    final relPath = p.join('cortex', '$topicId', '${_uuid.v4()}$ext');
    final dest = File(p.join(docs.path, relPath));
    await dest.parent.create(recursive: true);
    await source.copy(dest.path);
    final size = await dest.length();
    final mime = mimeType ??
        lookupMimeType(dest.path) ??
        lookupMimeType(fileName) ??
        'application/octet-stream';
    return StoredFile(
      relativePath: relPath.replaceAll('\\', '/'),
      fileName: fileName,
      mimeType: mime,
      fileSize: size,
    );
  }

  static Future<StoredFile> writeBytes({
    required List<int> bytes,
    required int topicId,
    required String fileName,
    String? mimeType,
  }) async {
    final docs = await docsDir();
    final ext = p.extension(fileName);
    final relPath = p.join('cortex', '$topicId', '${_uuid.v4()}$ext');
    final dest = File(p.join(docs.path, relPath));
    await dest.parent.create(recursive: true);
    await dest.writeAsBytes(bytes, flush: true);
    final mime = mimeType ??
        lookupMimeType(fileName, headerBytes: bytes.take(32).toList()) ??
        'application/octet-stream';
    return StoredFile(
      relativePath: relPath.replaceAll('\\', '/'),
      fileName: fileName,
      mimeType: mime,
      fileSize: bytes.length,
    );
  }

  static Future<void> deleteRelative(String? relPath) async {
    if (relPath == null || relPath.isEmpty) return;
    // Only delete paths inside our cortex/ tree (never absolute or odd paths).
    final normalized = relPath.replaceAll('\\', '/');
    if (!normalized.startsWith('cortex/')) return;
    final abs = await absoluteFromRelative(normalized);
    final file = File(abs);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Bytes used by `cortex/` under the app documents directory.
  static Future<int> cortexStorageBytes() async {
    final docs = await docsDir();
    final root = Directory(p.join(docs.path, 'cortex'));
    if (!await root.exists()) return 0;
    var total = 0;
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  static String _extensionOf(String path, String? preferredName) {
    final fromPreferred =
        preferredName != null ? p.extension(preferredName) : '';
    if (fromPreferred.isNotEmpty) return fromPreferred;
    final fromPath = p.extension(path);
    return fromPath.isNotEmpty ? fromPath : '';
  }
}

class StoredFile {
  const StoredFile({
    required this.relativePath,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
  });

  final String relativePath;
  final String fileName;
  final String mimeType;
  final int fileSize;
}
