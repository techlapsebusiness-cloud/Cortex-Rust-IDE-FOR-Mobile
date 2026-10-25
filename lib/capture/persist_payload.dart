import 'dart:io';

import '../data/models/claim.dart';
import '../data/models/project.dart';
import '../data/models/research_enums.dart';
import '../data/models/research_item.dart';
import '../providers/items_provider.dart';
import 'capture_payload.dart';

Future<ResearchItem> persistCapturePayload(
  ItemsRepository repo,
  Project project,
  CapturePayload payload, {
  ResearchStage stage = ResearchStage.evidence,
  String? note,
  List<String> tags = const [],
  Claim? claim,
  Stance stance = Stance.neutral,
  Credibility credibility = Credibility.unknown,
}) async {
  switch (payload.type) {
    case ItemType.text:
      return repo.addText(
        project: project,
        text: payload.text ?? '',
        stage: stage,
        note: note,
        tags: tags,
        sourceUrl: payload.sourceUrl,
        claim: claim,
        stance: stance,
        credibility: credibility,
      );
    case ItemType.link:
      return repo.addLink(
        project: project,
        url: payload.sourceUrl ?? payload.text ?? '',
        stage: stage,
        note: note,
        tags: tags,
        claim: claim,
        stance: stance,
        credibility: credibility,
      );
    case ItemType.image:
    case ItemType.video:
    case ItemType.file:
      if (payload.bytes != null && payload.bytes!.isNotEmpty) {
        return repo.addFileFromBytes(
          project: project,
          bytes: payload.bytes!,
          type: payload.type,
          fileName: payload.fileName ?? 'capture.bin',
          stage: stage,
          mimeType: payload.mimeType,
          note: note,
          tags: tags,
          sourceUrl: payload.sourceUrl,
          claim: claim,
          stance: stance,
          credibility: credibility,
        );
      }
      final path = payload.filePath;
      if (path == null || path.isEmpty || !File(path).existsSync()) {
        throw StateError('Shared file unavailable for ${payload.type.name}');
      }
      return repo.addFileFromPath(
        project: project,
        path: path,
        type: payload.type,
        stage: stage,
        fileName: payload.fileName,
        mimeType: payload.mimeType,
        note: note,
        tags: tags,
        sourceUrl: payload.sourceUrl,
        claim: claim,
        stance: stance,
        credibility: credibility,
      );
  }
}
