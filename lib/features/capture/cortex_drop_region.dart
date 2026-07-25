import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import '../../capture/capture_payload.dart';
import '../../capture/drop_reader.dart';
import '../../widgets/drop_target_frame.dart';

typedef CaptureDropHandler = FutureOr<void> Function(
  List<CapturePayload> payloads,
);

/// DropRegion with cyan hover pulse for CORTEX capture surfaces.
class CortexDropRegion extends ConsumerStatefulWidget {
  const CortexDropRegion({
    super.key,
    required this.onPayloads,
    required this.child,
    this.borderRadius = 0,
    this.hitTestBehavior = HitTestBehavior.opaque,
  });

  final CaptureDropHandler onPayloads;
  final Widget child;
  final double borderRadius;
  final HitTestBehavior hitTestBehavior;

  @override
  ConsumerState<CortexDropRegion> createState() => _CortexDropRegionState();
}

class _CortexDropRegionState extends ConsumerState<CortexDropRegion> {
  final ValueNotifier<bool> _hovering = ValueNotifier(false);
  var _busy = false;

  @override
  void dispose() {
    _hovering.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: cortexDropFormats,
      hitTestBehavior: widget.hitTestBehavior,
      onDropOver: (event) => DropOperation.copy,
      onDropEnter: (_) => _hovering.value = true,
      onDropLeave: (_) => _hovering.value = false,
      onDropEnded: (_) => _hovering.value = false,
      onPerformDrop: (event) async {
        // Stay inside onPerformDrop until getValue/getFile are registered.
        // Returning early disposes the DataReader.
        if (_busy) return;
        _busy = true;
        final messenger = ScaffoldMessenger.maybeOf(context);
        final onPayloads = widget.onPayloads;
        try {
          final payloads = await readDropPayloads(event);
          if (!mounted || payloads.isEmpty) return;
          await onPayloads(payloads);
        } catch (e, st) {
          debugPrint('CORTEX drop handle error: $e\n$st');
          messenger?.showSnackBar(
            SnackBar(content: Text('DROP FAILED: $e')),
          );
        } finally {
          _busy = false;
          _hovering.value = false;
        }
      },
      child: DropTargetFrame(
        activeListenable: _hovering,
        borderRadius: widget.borderRadius,
        child: widget.child,
      ),
    );
  }
}
