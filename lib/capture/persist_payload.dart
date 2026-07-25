import 'dart:io';

import '../data/models/item.dart';
import '../data/models/item_type.dart';
import '../data/models/topic.dart';
import '../providers/items_provider.dart';
import 'capture_payload.dart';

Future<Item> persistCapturePayload(
  ItemsRepository repo,
  Topic topic,
  CapturePayload payload, {
  String? note,
  List<String> tags = const [],
}) async {
  switch (payload.type) {
    case ItemType.text:
      return repo.addText(
        topic: topic,
        text: payload.text ?? '',
        note: note,
        tags: tags,
        sourceUrl: payload.sourceUrl,
      );
    case ItemType.link:
      return repo.addLink(
        topic: topic,
        url: payload.sourceUrl ?? payload.text ?? '',
        note: note,
        tags: tags,
      );
    case ItemType.image:
    case ItemType.video:
    case ItemType.file:
      if (payload.bytes != null && payload.bytes!.isNotEmpty) {
        return repo.addFileFromBytes(
          topic: topic,
          bytes: payload.bytes!,
          type: payload.type,
          fileName: payload.fileName ?? 'capture.bin',
          mimeType: payload.mimeType,
          note: note,
          tags: tags,
          sourceUrl: payload.sourceUrl,
        );
      }
      final path = payload.filePath;
      if (path == null || path.isEmpty || !File(path).existsSync()) {
        throw StateError('Shared file unavailable for ${payload.type.name}');
      }
      return repo.addFileFromPath(
        topic: topic,
        path: path,
        type: payload.type,
        fileName: payload.fileName,
        mimeType: payload.mimeType,
        note: note,
        tags: tags,
        sourceUrl: payload.sourceUrl,
      );
  }
}
