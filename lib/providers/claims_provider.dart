import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../data/models/claim.dart';
import '../data/models/project.dart';
import '../data/models/research_enums.dart';
import '../data/models/research_item.dart';
import 'isar_provider.dart';

final projectClaimsProvider =
    StreamProvider.family<List<Claim>, int>((ref, projectId) {
  final isar = ref.watch(isarProvider);
  return isar.claims
      .filter()
      .project((q) => q.idEqualTo(projectId))
      .watch(fireImmediately: true)
      .map((list) {
    final sorted = [...list]
      ..sort((a, b) {
        final byIndex = a.sortIndex.compareTo(b.sortIndex);
        if (byIndex != 0) return byIndex;
        return b.createdAt.compareTo(a.createdAt);
      });
    return sorted;
  });
});

class EvidenceBalance {
  const EvidenceBalance({
    required this.supports,
    required this.refutes,
    required this.neutral,
    required this.weightedSupports,
    required this.weightedRefutes,
    required this.confidence,
    required this.status,
  });

  final int supports;
  final int refutes;
  final int neutral;
  final double weightedSupports;
  final double weightedRefutes;
  final int confidence;
  final ClaimStatus status;

  static EvidenceBalance fromEvidence(Iterable<ResearchItem> items) {
    var supports = 0;
    var refutes = 0;
    var neutral = 0;
    var wSup = 0.0;
    var wRef = 0.0;

    for (final i in items) {
      final w = _credWeight(i.credibility);
      switch (i.stance) {
        case Stance.supports:
          supports++;
          wSup += w;
        case Stance.refutes:
          refutes++;
          wRef += w;
        case Stance.neutral:
          neutral++;
      }
    }

    final total = wSup + wRef;
    final confidence = total <= 0
        ? 50
        : ((wSup / total) * 100).round().clamp(0, 100);

    final ClaimStatus status;
    if (supports == 0 && refutes == 0) {
      status = ClaimStatus.open;
    } else if (wSup >= wRef * 2 && supports >= 2) {
      status = ClaimStatus.supported;
    } else if (wRef >= wSup * 2 && refutes >= 2) {
      status = ClaimStatus.refuted;
    } else if (supports > 0 && refutes > 0) {
      status = ClaimStatus.inconclusive;
    } else if (supports > refutes) {
      status = ClaimStatus.supported;
    } else if (refutes > supports) {
      status = ClaimStatus.refuted;
    } else {
      status = ClaimStatus.inconclusive;
    }

    return EvidenceBalance(
      supports: supports,
      refutes: refutes,
      neutral: neutral,
      weightedSupports: wSup,
      weightedRefutes: wRef,
      confidence: confidence,
      status: status,
    );
  }

  static double _credWeight(Credibility c) => switch (c) {
        Credibility.high => 1.5,
        Credibility.medium => 1.0,
        Credibility.low => 0.5,
        Credibility.unknown => 0.75,
      };
}

class ClaimsRepository {
  ClaimsRepository(this._isar);

  final Isar _isar;

  Future<Claim> create({
    required Project project,
    required ClaimType type,
    required String statement,
  }) async {
    await project.claims.load();
    final claim = Claim()
      ..type = type
      ..statement = statement.trim()
      ..status = ClaimStatus.open
      ..confidence = 50
      ..createdAt = DateTime.now()
      ..sortIndex = project.claims.length;

    await _isar.writeTxn(() async {
      await _isar.claims.put(claim);
      claim.project.value = project;
      await claim.project.save();
      project.updatedAt = DateTime.now();
      await _isar.projects.put(project);
    });
    return claim;
  }

  Future<void> update(
    Claim claim, {
    String? statement,
    ClaimType? type,
    ClaimStatus? status,
    int? confidence,
  }) async {
    if (statement != null) claim.statement = statement.trim();
    if (type != null) claim.type = type;
    if (status != null) claim.status = status;
    if (confidence != null) claim.confidence = confidence.clamp(0, 100);
    await _isar.writeTxn(() async {
      await _isar.claims.put(claim);
      await claim.project.load();
      final p = claim.project.value;
      if (p != null) {
        p.updatedAt = DateTime.now();
        await _isar.projects.put(p);
      }
    });
  }

  Future<void> delete(Claim claim) async {
    await claim.evidence.load();
    await _isar.writeTxn(() async {
      for (final item in claim.evidence) {
        item.claim.value = null;
        await item.claim.save();
        item.stance = Stance.neutral;
        await _isar.researchItems.put(item);
      }
      await claim.project.load();
      final p = claim.project.value;
      await _isar.claims.delete(claim.id);
      if (p != null) {
        p.updatedAt = DateTime.now();
        await _isar.projects.put(p);
      }
    });
  }

  /// Recompute confidence/status from linked evidence and persist.
  Future<EvidenceBalance> recompute(Claim claim) async {
    await claim.evidence.load();
    final balance = EvidenceBalance.fromEvidence(claim.evidence);
    claim
      ..confidence = balance.confidence
      ..status = balance.status;
    await _isar.writeTxn(() async {
      await _isar.claims.put(claim);
    });
    return balance;
  }
}

final claimsRepositoryProvider = Provider<ClaimsRepository>((ref) {
  return ClaimsRepository(ref.watch(isarProvider));
});
