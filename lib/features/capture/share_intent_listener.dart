import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../capture/capture_payload.dart';
import '../../providers/capture_provider.dart';
import 'capture_sheet.dart';

/// Listens for cold-start and warm share intents and opens CaptureSheet.
class ShareIntentListener extends ConsumerStatefulWidget {
  const ShareIntentListener({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  ConsumerState<ShareIntentListener> createState() =>
      _ShareIntentListenerState();
}

class _ShareIntentListenerState extends ConsumerState<ShareIntentListener> {
  StreamSubscription<List<SharedMediaFile>>? _sub;
  var _sheetOpen = false;
  var _bound = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureBound());
  }

  void _ensureBound() {
    if (_bound || !mounted) return;
    _bound = true;

    _sub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (files) => _onShared(files),
      onError: (Object err) {
        debugPrint('CORTEX share stream error: $err');
      },
    );

    ReceiveSharingIntent.instance.getInitialMedia().then((initial) {
      if (initial.isNotEmpty) _onShared(initial);
    }).catchError((Object e) {
      debugPrint('CORTEX initial share error: $e');
    });
  }

  Future<void> _onShared(List<SharedMediaFile> files) async {
    if (files.isEmpty) return;
    final payloads = CapturePayload.fromSharedMedia(files);
    await ReceiveSharingIntent.instance.reset();
    if (payloads.isEmpty || !mounted) return;

    enqueueCapture(ref, payloads: payloads);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    await _presentSheet(payloads, retries: 0);
  }

  Future<void> _presentSheet(
    List<CapturePayload> payloads, {
    required int retries,
  }) async {
    if (_sheetOpen) return;
    final nav = widget.navigatorKey.currentState;
    if (nav == null) {
      if (retries >= 30) return;
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      return _presentSheet(payloads, retries: retries + 1);
    }

    final targetId = ref.read(captureTargetProjectIdProvider);
    final stage = ref.read(captureTargetStageProvider);
    _sheetOpen = true;
    try {
      await showCaptureSheet(
        nav.context,
        payloads: payloads,
        targetProjectId: targetId,
        initialStage: stage,
      );
    } finally {
      _sheetOpen = false;
      if (ref.read(pendingCaptureProvider) != null) {
        clearCapture(ref);
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
