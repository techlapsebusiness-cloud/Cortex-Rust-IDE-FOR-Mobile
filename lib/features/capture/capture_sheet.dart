import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../capture/capture_payload.dart';
import '../../capture/persist_payload.dart';
import '../../data/models/claim.dart';
import '../../data/models/project.dart';
import '../../data/models/research_enums.dart';
import '../../providers/capture_provider.dart';
import '../../providers/claims_provider.dart';
import '../../providers/items_provider.dart';
import '../../providers/projects_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';
import '../projects/project_editor_sheet.dart';

Future<void> showCaptureSheet(
  BuildContext context, {
  required List<CapturePayload> payloads,
  int? targetProjectId,
  ResearchStage initialStage = ResearchStage.evidence,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: CortexColors.elevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      side: BorderSide(color: CortexColors.hairline),
    ),
    builder: (ctx) => CaptureSheet(
      payloads: payloads,
      initialProjectId: targetProjectId,
      initialStage: initialStage,
    ),
  );
}

class CaptureSheet extends ConsumerStatefulWidget {
  const CaptureSheet({
    super.key,
    required this.payloads,
    this.initialProjectId,
    this.initialStage = ResearchStage.evidence,
  });

  final List<CapturePayload> payloads;
  final int? initialProjectId;
  final ResearchStage initialStage;

  @override
  ConsumerState<CaptureSheet> createState() => _CaptureSheetState();
}

class _CaptureSheetState extends ConsumerState<CaptureSheet> {
  final _note = TextEditingController();
  final _tags = TextEditingController();
  int? _projectId;
  late ResearchStage _stage;
  Claim? _claim;
  Stance _stance = Stance.neutral;
  Credibility _credibility = Credibility.unknown;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _projectId = widget.initialProjectId;
    _stage = widget.initialStage;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _projectId ??= widget.initialProjectId ??
        ref.read(captureTargetProjectIdProvider) ??
        ref.read(selectedProjectIdProvider) ??
        ref.read(defaultCaptureProjectIdProvider).valueOrNull;
  }

  @override
  void dispose() {
    _note.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider).valueOrNull ?? [];
    final recent = recentProjects(projects);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final claims = _projectId == null
        ? <Claim>[]
        : ref.watch(projectClaimsProvider(_projectId!)).valueOrNull ?? [];

    if (_projectId == null && projects.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _projectId = projects.first.id);
      });
    }

    Project? selected;
    for (final p in projects) {
      if (p.id == _projectId) {
        selected = p;
        break;
      }
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: CortexColors.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'CAPTURE',
              style: CortexTheme.orbitron(
                fontSize: 14,
                color: CortexColors.accent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.payloads.length} ITEM${widget.payloads.length == 1 ? '' : 'S'}',
              style: CortexTheme.mono(fontSize: 11),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.payloads.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return _PayloadPreview(payload: widget.payloads[index]);
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('PROJECT', style: CortexTheme.mono(fontSize: 11)),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final p in recent)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          p.title,
                          style: CortexTheme.mono(
                            fontSize: 11,
                            color: _projectId == p.id
                                ? CortexColors.background
                                : CortexColors.text,
                          ),
                        ),
                        selected: _projectId == p.id,
                        selectedColor: Color(p.colorValue),
                        backgroundColor: CortexColors.surface,
                        side: BorderSide(
                          color: Color(p.colorValue).withValues(alpha: 0.4),
                        ),
                        onSelected: (_) => setState(() {
                          _projectId = p.id;
                          _claim = null;
                        }),
                      ),
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.add,
                        size: 16, color: CortexColors.accent),
                    label: Text(
                      'New project',
                      style: CortexTheme.mono(
                        fontSize: 11,
                        color: CortexColors.accent,
                      ),
                    ),
                    backgroundColor: CortexColors.surface,
                    side: const BorderSide(color: CortexColors.hairline),
                    onPressed: () => _createProject(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('STAGE', style: CortexTheme.mono(fontSize: 11)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final stage in ResearchStage.values)
                  ChoiceChip(
                    label: Text(
                      stage.shortLabel,
                      style: CortexTheme.mono(
                        fontSize: 11,
                        color: _stage == stage
                            ? CortexColors.background
                            : CortexColors.text,
                      ),
                    ),
                    selected: _stage == stage,
                    selectedColor: CortexColors.accent,
                    backgroundColor: CortexColors.surface,
                    side: const BorderSide(color: CortexColors.hairline),
                    onSelected: (_) => setState(() => _stage = stage),
                  ),
              ],
            ),
            if (claims.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('CLAIM (optional)', style: CortexTheme.mono(fontSize: 11)),
              const SizedBox(height: 8),
              DropdownButtonFormField<Claim?>(
                initialValue: _claim,
                dropdownColor: CortexColors.elevated,
                decoration: const InputDecoration(
                  hintText: 'Link to claim…',
                ),
                items: [
                  const DropdownMenuItem<Claim?>(
                    value: null,
                    child: Text('None'),
                  ),
                  for (final c in claims)
                    DropdownMenuItem<Claim?>(
                      value: c,
                      child: Text(
                        c.statement,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CortexTheme.body(fontSize: 13),
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _claim = v),
              ),
              if (_claim != null) ...[
                const SizedBox(height: 10),
                Text('STANCE', style: CortexTheme.mono(fontSize: 11)),
                const SizedBox(height: 6),
                SegmentedButton<Stance>(
                  segments: const [
                    ButtonSegment(
                      value: Stance.supports,
                      label: Text('▲'),
                    ),
                    ButtonSegment(
                      value: Stance.neutral,
                      label: Text('—'),
                    ),
                    ButtonSegment(
                      value: Stance.refutes,
                      label: Text('▼'),
                    ),
                  ],
                  selected: {_stance},
                  onSelectionChanged: (s) =>
                      setState(() => _stance = s.first),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<Credibility>(
                  initialValue: _credibility,
                  dropdownColor: CortexColors.elevated,
                  decoration: const InputDecoration(labelText: 'Credibility'),
                  items: Credibility.values
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.name, style: CortexTheme.body()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _credibility = v);
                  },
                ),
              ],
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _note,
              style: CortexTheme.body(),
              decoration: const InputDecoration(labelText: 'Note (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tags,
              style: CortexTheme.mono(),
              decoration: const InputDecoration(
                labelText: 'Tags (comma-separated)',
                hintText: 'async, fold, ux',
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed:
                  _saving || selected == null ? null : () => _save(selected!),
              style: FilledButton.styleFrom(
                backgroundColor: CortexColors.accent,
                foregroundColor: CortexColors.background,
                disabledBackgroundColor:
                    CortexColors.muted.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CortexColors.background,
                      ),
                    )
                  : Text(
                      'SAVE',
                      style: CortexTheme.orbitron(
                        fontSize: 12,
                        color: CortexColors.background,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createProject() async {
    final draft = await showProjectEditorSheet(context);
    if (draft == null) return;
    final repo = ref.read(projectsRepositoryProvider);
    final project = await repo.create(
      title: draft.title,
      researchQuestion: draft.researchQuestion,
      field: draft.field,
      description: draft.description,
      colorValue: draft.colorValue,
    );
    if (!mounted) return;
    setState(() => _projectId = project.id);
    ref.read(selectedProjectIdProvider.notifier).state = project.id;
  }

  Future<void> _save(Project project) async {
    final repo = ref.read(itemsRepositoryProvider);
    setState(() => _saving = true);

    final note = _note.text.trim().isEmpty ? null : _note.text.trim();
    final tags = _tags.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    try {
      for (final payload in widget.payloads) {
        await persistCapturePayload(
          repo,
          project,
          payload,
          stage: _stage,
          note: note,
          tags: tags,
          claim: _claim,
          stance: _stance,
          credibility: _credibility,
        );
      }
      ref.read(selectedProjectIdProvider.notifier).state = project.id;
      clearCapture(ref);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'CAPTURED → ${project.title}',
            style: CortexTheme.mono(color: CortexColors.text),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'CAPTURE FAILED: $e',
            style: CortexTheme.mono(color: CortexColors.danger),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _PayloadPreview extends StatelessWidget {
  const _PayloadPreview({required this.payload});

  final CapturePayload payload;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CortexColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CortexColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            payload.type.name.toUpperCase(),
            style: CortexTheme.mono(fontSize: 10, color: CortexColors.accent),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _previewBody(),
          ),
        ],
      ),
    );
  }

  Widget _previewBody() {
    if (payload.type == ItemType.image &&
        payload.filePath != null &&
        File(payload.filePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(payload.filePath!),
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Text(
            payload.previewLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: CortexTheme.body(fontSize: 12),
          ),
        ),
      );
    }
    return Text(
      payload.previewLabel,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: CortexTheme.body(fontSize: 12),
    );
  }
}
