import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../capture/capture_payload.dart';
import '../data/models/topic.dart';

/// Pending share/drop payloads waiting for CaptureSheet.
final pendingCaptureProvider =
    StateProvider<List<CapturePayload>?>((ref) => null);

/// Optional pre-selected topic when opening CaptureSheet (e.g. drop on card).
final captureTargetTopicIdProvider = StateProvider<int?>((ref) => null);

void enqueueCapture(
  WidgetRef ref, {
  required List<CapturePayload> payloads,
  int? targetTopicId,
}) {
  if (payloads.isEmpty) return;
  ref.read(captureTargetTopicIdProvider.notifier).state = targetTopicId;
  ref.read(pendingCaptureProvider.notifier).state = payloads;
}

void clearCapture(WidgetRef ref) {
  ref.read(pendingCaptureProvider.notifier).state = null;
  ref.read(captureTargetTopicIdProvider.notifier).state = null;
}

/// Recent topics for CaptureSheet chips (by updatedAt desc).
List<Topic> recentTopics(List<Topic> all, {int limit = 8}) {
  final sorted = [...all]
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return sorted.take(limit).toList();
}
