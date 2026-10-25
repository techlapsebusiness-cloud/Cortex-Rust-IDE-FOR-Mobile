import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/claim.dart';
import '../../data/models/project.dart';
import '../../data/models/research_enums.dart';
import '../../providers/claims_provider.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';

Future<void> showClaimsPanel(
  BuildContext context, {
  required Project project,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: CortexColors.elevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      side: BorderSide(color: CortexColors.hairline),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ClaimsPanel(
          project: project,
          scrollController: scrollController,
        );
      },
    ),
  );
}

class ClaimsPanel extends ConsumerWidget {
  const ClaimsPanel({
    super.key,
    required this.project,
    required this.scrollController,
  });

  final Project project;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(projectClaimsProvider(project.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'CLAIMS',
                  style: CortexTheme.orbitron(
                    fontSize: 14,
                    color: CortexColors.accent,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: CortexColors.accent),
                onPressed: () => _addClaim(context, ref),
              ),
            ],
          ),
        ),
        Expanded(
          child: claimsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: CortexColors.accent),
            ),
            error: (e, _) => Center(
              child: Text(
                '$e',
                style: CortexTheme.mono(color: CortexColors.danger),
              ),
            ),
            data: (claims) {
              if (claims.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No claims yet. Add a hypothesis or thesis to track evidence.',
                      textAlign: TextAlign.center,
                      style: CortexTheme.body(color: CortexColors.muted),
                    ),
                  ),
                );
              }
              return ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: claims.length,
                separatorBuilder: (_, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _ClaimTile(
                    claim: claims[index],
                    onEdit: () => _editClaim(context, ref, claims[index]),
                    onDelete: () => _deleteClaim(context, ref, claims[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _addClaim(BuildContext context, WidgetRef ref) async {
    final draft = await _claimDialog(context);
    if (draft == null) return;
    final repo = ref.read(claimsRepositoryProvider);
    await repo.create(
      project: project,
      type: draft.type,
      statement: draft.statement,
    );
  }

  Future<void> _editClaim(
    BuildContext context,
    WidgetRef ref,
    Claim claim,
  ) async {
    final draft = await _claimDialog(
      context,
      initialType: claim.type,
      initialStatement: claim.statement,
      confirmLabel: 'SAVE',
    );
    if (draft == null) return;
    final repo = ref.read(claimsRepositoryProvider);
    await repo.update(
      claim,
      type: draft.type,
      statement: draft.statement,
    );
  }

  Future<void> _deleteClaim(
    BuildContext context,
    WidgetRef ref,
    Claim claim,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('DELETE CLAIM'),
        content: Text(
          'Remove this claim? Linked evidence will be unlinked.',
          style: CortexTheme.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: CortexTheme.mono()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'DELETE',
              style: CortexTheme.mono(color: CortexColors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(claimsRepositoryProvider).delete(claim);
  }
}

class _ClaimTile extends StatelessWidget {
  const _ClaimTile({
    required this.claim,
    required this.onEdit,
    required this.onDelete,
  });

  final Claim claim;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EvidenceBalance>(
      future: () async {
        await claim.evidence.load();
        return EvidenceBalance.fromEvidence(claim.evidence);
      }(),
      builder: (context, snap) {
        final balance = snap.data;
        return Material(
          color: CortexColors.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onEdit,
            onLongPress: onDelete,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        claim.type.name.toUpperCase(),
                        style: CortexTheme.mono(
                          fontSize: 10,
                          color: CortexColors.accent,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${claim.confidence}%',
                        style: CortexTheme.mono(fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    claim.statement,
                    style: CortexTheme.body(fontSize: 14),
                  ),
                  if (balance != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '▲ ${balance.supports} supports · ▼ ${balance.refutes} refutes',
                      style: CortexTheme.mono(
                        fontSize: 11,
                        color: CortexColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ClaimDraft {
  const _ClaimDraft({required this.type, required this.statement});

  final ClaimType type;
  final String statement;
}

Future<_ClaimDraft?> _claimDialog(
  BuildContext context, {
  ClaimType initialType = ClaimType.hypothesis,
  String initialStatement = '',
  String confirmLabel = 'ADD',
}) {
  return showDialog<_ClaimDraft>(
    context: context,
    builder: (ctx) => _ClaimDialog(
      initialType: initialType,
      initialStatement: initialStatement,
      confirmLabel: confirmLabel,
    ),
  );
}

class _ClaimDialog extends StatefulWidget {
  const _ClaimDialog({
    required this.initialType,
    required this.initialStatement,
    required this.confirmLabel,
  });

  final ClaimType initialType;
  final String initialStatement;
  final String confirmLabel;

  @override
  State<_ClaimDialog> createState() => _ClaimDialogState();
}

class _ClaimDialogState extends State<_ClaimDialog> {
  late ClaimType _type;
  late final TextEditingController _statement;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _statement = TextEditingController(text: widget.initialStatement);
  }

  @override
  void dispose() {
    _statement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.confirmLabel == 'ADD' ? 'ADD CLAIM' : 'EDIT CLAIM',
        style: CortexTheme.orbitron(fontSize: 13, color: CortexColors.accent),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<ClaimType>(
            initialValue: _type,
            dropdownColor: CortexColors.elevated,
            decoration: const InputDecoration(labelText: 'Type'),
            items: ClaimType.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(t.name, style: CortexTheme.body()),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _type = v);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _statement,
            autofocus: true,
            maxLines: 3,
            style: CortexTheme.body(),
            decoration: const InputDecoration(
              labelText: 'Statement',
              hintText: 'What do you claim or hypothesize?',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('CANCEL', style: CortexTheme.mono()),
        ),
        FilledButton(
          onPressed: () {
            final text = _statement.text.trim();
            if (text.isEmpty) return;
            Navigator.pop(context, _ClaimDraft(type: _type, statement: text));
          },
          style: FilledButton.styleFrom(
            backgroundColor: CortexColors.accent,
            foregroundColor: CortexColors.background,
          ),
          child: Text(
            widget.confirmLabel,
            style: CortexTheme.orbitron(
              fontSize: 11,
              color: CortexColors.background,
            ),
          ),
        ),
      ],
    );
  }
}
