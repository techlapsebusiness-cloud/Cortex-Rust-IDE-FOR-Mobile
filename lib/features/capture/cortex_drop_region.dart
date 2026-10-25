import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import '../../capture/capture_payload.dart';
import '../../capture/drop_reader.dart';
import '../../fx/drag_fx_controller.dart';
import '../../fx/hud_drop_overlay.dart';
import '../../widgets/drop_target_frame.dart';

typedef CaptureDropHandler = FutureOr<void> Function(
  List<CapturePayload> payloads,
);

/// DropRegion with cyan hover pulse + JARVIS HUD FX for CORTEX capture surfaces.
class CortexDropRegion extends ConsumerStatefulWidget {
  const CortexDropRegion({
    super.key,
    required this.onPayloads,
    required this.child,
    this.borderRadius = 0,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.enableHudFx = true,
  });

  final CaptureDropHandler onPayloads;
  final Widget child;
  final double borderRadius;
  final HitTestBehavior hitTestBehavior;

  /// Full HUD overlay (brackets / reticle / particles). Topics cards keep pulse only.
  final bool enableHudFx;

  @override
  ConsumerState<CortexDropRegion> createState() => _CortexDropRegionState();
}

class _CortexDropRegionState extends ConsumerState<CortexDropRegion> {
  final ValueNotifier<bool> _hovering = ValueNotifier(false);
  var _busy = false;
  var _validHoverHapticSent = false;

  @override
  void dispose() {
    _hovering.dispose();
    super.dispose();
  }

  DragFxController get _fx => ref.read(dragFxProvider.notifier);

  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: cortexDropFormats,
      hitTestBehavior: widget.hitTestBehavior,
      onDropEnter: (_) {
        _hovering.value = true;
        _validHoverHapticSent = false;
        if (widget.enableHudFx) {
          _fx.enter();
          HapticFeedback.selectionClick();
        }
      },
      onDropLeave: (_) {
        _hovering.value = false;
        _validHoverHapticSent = false;
        if (widget.enableHudFx) _fx.leave();
      },
      onDropEnded: (_) {
        _hovering.value = false;
        _validHoverHapticSent = false;
      },
      onDropOver: (event) {
        final ok = dropSessionHasWantedFormat(event.session);
        if (widget.enableHudFx) {
          _fx.track(event.position.local, valid: ok);
        }
        if (ok && !_validHoverHapticSent) {
          _validHoverHapticSent = true;
          HapticFeedback.lightImpact();
        }
        // Critical: Android rejects the drop if this returns none while hovering.
        return ok ? DropOperation.copy : DropOperation.none;
      },
      onPerformDrop: (event) async {
        // Stay inside onPerformDrop until getValue/getFile are registered.
        // Returning early disposes the DataReader.
        if (_busy) return;
        _busy = true;
        final messenger = ScaffoldMessenger.maybeOf(context);
        final onPayloads = widget.onPayloads;
        final dropPoint = event.position.local;
        try {
          final payloads = await readDropPayloads(event);
          if (!mounted) return;
          if (payloads.isEmpty) {
            debugPrint('CORTEX onPerformDrop: no payloads decoded');
            messenger?.showSnackBar(
              const SnackBar(content: Text('DROP FAILED: empty payload')),
            );
            if (widget.enableHudFx) _fx.leave();
            return;
          }
          if (widget.enableHudFx) {
            _fx.materialize(dropPoint);
            HapticFeedback.mediumImpact();
          }
          await onPayloads(payloads);
        } catch (e, st) {
          debugPrint('CORTEX drop handle error: $e\n$st');
          messenger?.showSnackBar(
            SnackBar(content: Text('DROP FAILED: $e')),
          );
          if (widget.enableHudFx) _fx.leave();
        } finally {
          _busy = false;
          _hovering.value = false;
        }
      },
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          DropTargetFrame(
            activeListenable: _hovering,
            borderRadius: widget.borderRadius,
            child: widget.child,
          ),
          if (widget.enableHudFx) const HudDropOverlay(),
        ],
      ),
    );
  }
}
