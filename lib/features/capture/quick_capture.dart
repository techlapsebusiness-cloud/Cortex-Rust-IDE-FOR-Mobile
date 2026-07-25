import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../capture/capture_payload.dart';
import '../../capture/persist_payload.dart';
import '../../data/models/item.dart';
import '../../data/models/topic.dart';
import '../../providers/capture_provider.dart';
import '../../providers/items_provider.dart';
import '../../providers/topics_provider.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';
import 'capture_sheet.dart';

/// Quick-add payloads into [topic] and offer Undo (§6 feed drop).
Future<void> quickAddWithUndo(
  BuildContext context,
  WidgetRef ref, {
  required Topic topic,
  required List<CapturePayload> payloads,
}) async {
  final repo = ref.read(itemsRepositoryProvider).valueOrNull;
  if (repo == null || payloads.isEmpty) return;

  final created = <Item>[];
  try {
    for (final payload in payloads) {
      created.add(await persistCapturePayload(repo, topic, payload));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'DROP FAILED: $e',
            style: CortexTheme.mono(color: CortexColors.danger),
          ),
        ),
      );
    }
    return;
  }

  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 5),
      content: Text(
        'ADDED ${created.length} → ${topic.title}',
        style: CortexTheme.mono(color: CortexColors.text),
      ),
      action: SnackBarAction(
        label: 'UNDO',
        textColor: CortexColors.accent,
        onPressed: () async {
          for (final item in created) {
            await repo.delete(item);
          }
        },
      ),
    ),
  );
}

/// Open CaptureSheet for drops onto the topics pane / a topic card.
Future<void> openCaptureForDrop(
  BuildContext context,
  WidgetRef ref, {
  required List<CapturePayload> payloads,
  int? targetTopicId,
}) async {
  if (payloads.isEmpty) return;
  enqueueCapture(ref, payloads: payloads, targetTopicId: targetTopicId);
  await showCaptureSheet(
    context,
    payloads: payloads,
    targetTopicId: targetTopicId ?? ref.read(selectedTopicIdProvider),
  );
  if (ref.read(pendingCaptureProvider) != null) {
    clearCapture(ref);
  }
}
