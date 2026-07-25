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
  var _hovering = false;

  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: cortexDropFormats,
      hitTestBehavior: widget.hitTestBehavior,
      onDropOver: (event) {
        // Formats advertised are enough on Android during hover.
        return DropOperation.copy;
      },
      onDropEnter: (_) {
        if (!_hovering) setState(() => _hovering = true);
      },
      onDropLeave: (_) {
        if (_hovering) setState(() => _hovering = false);
      },
      onDropEnded: (_) {
        if (_hovering) setState(() => _hovering = false);
      },
      onPerformDrop: (event) async {
        // Do not await DataReader callbacks here — process off the platform thread.
        unawaited(_handle(event));
      },
      child: DropTargetFrame(
        active: _hovering,
        borderRadius: widget.borderRadius,
        child: widget.child,
      ),
    );
  }

  Future<void> _handle(PerformDropEvent event) async {
    try {
      final payloads = await readDropPayloads(event);
      if (!mounted || payloads.isEmpty) return;
      await widget.onPayloads(payloads);
    } catch (e, st) {
      debugPrint('CORTEX drop handle error: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('DROP FAILED: $e')),
      );
    }
  }
}
