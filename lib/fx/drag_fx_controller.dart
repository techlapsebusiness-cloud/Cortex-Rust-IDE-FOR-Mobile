import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// High-frequency pointer for the HUD reticle (avoids Riverpod rebuild storms).
final dragFxPointer = ValueNotifier<Offset>(Offset.zero);

enum DragFxPhase {
  idle,
  entering,
  tracking,
  dropping,
  leaving,
}

@immutable
class DragFxState {
  const DragFxState({
    this.phase = DragFxPhase.idle,
    this.pointer = Offset.zero,
    this.dropPoint = Offset.zero,
    this.validTarget = false,
    this.materializeItemIds = const {},
    this.enterAt,
    this.leaveAt,
    this.dropAt,
  });

  final DragFxPhase phase;
  final Offset pointer;
  final Offset dropPoint;
  final bool validTarget;
  final Set<int> materializeItemIds;
  final DateTime? enterAt;
  final DateTime? leaveAt;
  final DateTime? dropAt;

  bool get isActive =>
      phase != DragFxPhase.idle && phase != DragFxPhase.leaving;

  DragFxState copyWith({
    DragFxPhase? phase,
    Offset? pointer,
    Offset? dropPoint,
    bool? validTarget,
    Set<int>? materializeItemIds,
    DateTime? enterAt,
    DateTime? leaveAt,
    DateTime? dropAt,
    bool clearEnterAt = false,
    bool clearLeaveAt = false,
    bool clearDropAt = false,
  }) {
    return DragFxState(
      phase: phase ?? this.phase,
      pointer: pointer ?? this.pointer,
      dropPoint: dropPoint ?? this.dropPoint,
      validTarget: validTarget ?? this.validTarget,
      materializeItemIds: materializeItemIds ?? this.materializeItemIds,
      enterAt: clearEnterAt ? null : (enterAt ?? this.enterAt),
      leaveAt: clearLeaveAt ? null : (leaveAt ?? this.leaveAt),
      dropAt: clearDropAt ? null : (dropAt ?? this.dropAt),
    );
  }
}

class DragFxController extends StateNotifier<DragFxState> {
  DragFxController() : super(const DragFxState());

  void enter() {
    state = state.copyWith(
      phase: DragFxPhase.entering,
      enterAt: DateTime.now(),
      clearLeaveAt: true,
      clearDropAt: true,
      validTarget: false,
    );
    // Snap into tracking after ignite window.
    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      if (state.phase == DragFxPhase.entering) {
        state = state.copyWith(phase: DragFxPhase.tracking);
      }
    });
  }

  void track(Offset local, {required bool valid}) {
    dragFxPointer.value = local;
    if (state.phase == DragFxPhase.idle || state.phase == DragFxPhase.leaving) {
      enter();
    }
    final nextPhase = state.phase == DragFxPhase.entering
        ? DragFxPhase.entering
        : DragFxPhase.tracking;
    // Only notify Riverpod when phase/validity changes (pointer is ValueNotifier).
    if (state.phase == nextPhase &&
        state.validTarget == valid &&
        (state.pointer - local).distance < 24) {
      return;
    }
    state = state.copyWith(
      phase: nextPhase,
      pointer: local,
      validTarget: valid,
    );
  }

  void leave() {
    if (state.phase == DragFxPhase.idle) return;
    // Drop already committed — don't retract over the materialize burst.
    if (state.phase == DragFxPhase.dropping) return;
    state = state.copyWith(
      phase: DragFxPhase.leaving,
      leaveAt: DateTime.now(),
      validTarget: false,
    );
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      if (state.phase == DragFxPhase.leaving) {
        state = const DragFxState();
      }
    });
  }

  void materialize(Offset dropPoint) {
    dragFxPointer.value = dropPoint;
    state = state.copyWith(
      phase: DragFxPhase.dropping,
      dropPoint: dropPoint,
      pointer: dropPoint,
      dropAt: DateTime.now(),
      validTarget: true,
    );
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      if (state.phase == DragFxPhase.dropping) {
        // Keep materializeItemIds so new cards can still assemble.
        state = DragFxState(materializeItemIds: state.materializeItemIds);
      }
    });
  }

  void markMaterializing(Iterable<int> itemIds) {
    if (itemIds.isEmpty) return;
    state = state.copyWith(
      materializeItemIds: {...state.materializeItemIds, ...itemIds},
    );
  }

  void clearMaterialize(int itemId) {
    if (!state.materializeItemIds.contains(itemId)) return;
    final next = {...state.materializeItemIds}..remove(itemId);
    state = state.copyWith(materializeItemIds: next);
  }
}

final dragFxProvider =
    StateNotifierProvider<DragFxController, DragFxState>((ref) {
  return DragFxController();
});
