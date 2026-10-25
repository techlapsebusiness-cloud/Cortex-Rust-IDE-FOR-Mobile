import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../capture/capture_payload.dart';
import '../data/models/project.dart';
import '../data/models/research_enums.dart';

/// Pending share/drop payloads waiting for CaptureSheet.
final pendingCaptureProvider =
    StateProvider<List<CapturePayload>?>((ref) => null);

/// Optional pre-selected project when opening CaptureSheet (e.g. drop on card).
final captureTargetProjectIdProvider = StateProvider<int?>((ref) => null);

/// Stage to apply when opening CaptureSheet / quick-add.
final captureTargetStageProvider =
    StateProvider<ResearchStage>((ref) => ResearchStage.evidence);

void enqueueCapture(
  WidgetRef ref, {
  required List<CapturePayload> payloads,
  int? targetProjectId,
  ResearchStage stage = ResearchStage.evidence,
}) {
  if (payloads.isEmpty) return;
  ref.read(captureTargetProjectIdProvider.notifier).state = targetProjectId;
  ref.read(captureTargetStageProvider.notifier).state = stage;
  ref.read(pendingCaptureProvider.notifier).state = payloads;
}

void clearCapture(WidgetRef ref) {
  ref.read(pendingCaptureProvider.notifier).state = null;
  ref.read(captureTargetProjectIdProvider.notifier).state = null;
  ref.read(captureTargetStageProvider.notifier).state = ResearchStage.evidence;
}

/// Recent projects for CaptureSheet chips (by updatedAt desc).
List<Project> recentProjects(List<Project> all, {int limit = 8}) {
  final sorted = [...all]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return sorted.take(limit).toList();
}
