import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../capture/capture_payload.dart';
import '../../capture/persist_payload.dart';
import '../../data/models/project.dart';
import '../../data/models/research_enums.dart';
import '../../data/models/research_item.dart';
import '../../fx/drag_fx_controller.dart';
import '../../providers/capture_provider.dart';
import '../../providers/items_provider.dart';
import '../../providers/projects_provider.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';
import 'capture_sheet.dart';

/// Quick-add payloads into [project] and offer Undo (stage view drops skip sheet).
Future<void> quickAddWithUndo(
  BuildContext context,
  WidgetRef ref, {
  required Project project,
  required List<CapturePayload> payloads,
  ResearchStage stage = ResearchStage.evidence,
}) async {
  final repo = ref.read(itemsRepositoryProvider);
  if (payloads.isEmpty) return;

  final created = <ResearchItem>[];
  try {
    for (final payload in payloads) {
      created.add(
        await persistCapturePayload(
          repo,
          project,
          payload,
          stage: stage,
        ),
      );
    }
    ref.read(dragFxProvider.notifier).markMaterializing(
          created.map((i) => i.id),
        );
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
        'ADDED ${created.length} → ${project.title}',
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

/// Open CaptureSheet for drops onto the projects pane / a project card.
Future<void> openCaptureForDrop(
  BuildContext context,
  WidgetRef ref, {
  required List<CapturePayload> payloads,
  int? targetProjectId,
  ResearchStage stage = ResearchStage.evidence,
}) async {
  if (payloads.isEmpty) return;
  enqueueCapture(
    ref,
    payloads: payloads,
    targetProjectId: targetProjectId,
    stage: stage,
  );
  await showCaptureSheet(
    context,
    payloads: payloads,
    targetProjectId: targetProjectId ??
        ref.read(selectedProjectIdProvider) ??
        ref.read(captureTargetProjectIdProvider),
    initialStage: ref.read(captureTargetStageProvider),
  );
  if (ref.read(pendingCaptureProvider) != null) {
    clearCapture(ref);
  }
}
