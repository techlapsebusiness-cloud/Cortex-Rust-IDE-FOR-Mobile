import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/project.dart';
import '../../data/models/research_enums.dart';
import '../../providers/items_provider.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';

Future<void> showManualAddSheet(
  BuildContext context, {
  required Project project,
  ResearchStage stage = ResearchStage.evidence,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: CortexColors.elevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      side: BorderSide(color: CortexColors.hairline),
    ),
    builder: (ctx) => _ManualAddSheet(project: project, stage: stage),
  );
}

class _ManualAddSheet extends ConsumerStatefulWidget {
  const _ManualAddSheet({required this.project, required this.stage});

  final Project project;
  final ResearchStage stage;

  @override
  ConsumerState<_ManualAddSheet> createState() => _ManualAddSheetState();
}

class _ManualAddSheetState extends ConsumerState<_ManualAddSheet> {
  late ResearchStage _stage;

  @override
  void initState() {
    super.initState();
    _stage = widget.stage;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
              'ADD TO PROJECT',
              style: CortexTheme.orbitron(
                fontSize: 13,
                color: CortexColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            Text(widget.project.title, style: CortexTheme.mono(fontSize: 11)),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            _AddTile(
              icon: Icons.notes,
              label: 'Text note',
              onTap: () async {
                Navigator.pop(context);
                await _addText(context);
              },
            ),
            _AddTile(
              icon: Icons.link,
              label: 'Paste link',
              onTap: () async {
                Navigator.pop(context);
                await _addLink(context);
              },
            ),
            _AddTile(
              icon: Icons.image_outlined,
              label: 'Image from gallery',
              onTap: () async {
                Navigator.pop(context);
                await _addImage(context);
              },
            ),
            _AddTile(
              icon: Icons.attach_file,
              label: 'File',
              onTap: () async {
                Navigator.pop(context);
                await _addFile(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addText(BuildContext context) async {
    final result = await _promptFields(
      context,
      title: 'TEXT NOTE',
      primaryLabel: 'Note',
      primaryHint: 'Captured thought…',
      multiline: true,
    );
    if (result == null) return;
    final repo = ref.read(itemsRepositoryProvider);
    await repo.addText(
      project: widget.project,
      text: result.primary,
      stage: _stage,
      note: result.note,
      tags: result.tags,
    );
  }

  Future<void> _addLink(BuildContext context) async {
    final result = await _promptFields(
      context,
      title: 'PASTE LINK',
      primaryLabel: 'URL',
      primaryHint: 'https://…',
    );
    if (result == null) return;
    final repo = ref.read(itemsRepositoryProvider);
    final raw = result.primary.trim();
    if (ItemsRepository.looksLikeUrl(raw)) {
      await repo.addLink(
        project: widget.project,
        url: raw,
        stage: _stage,
        note: result.note,
        tags: result.tags,
      );
    } else {
      await repo.addText(
        project: widget.project,
        text: raw,
        stage: _stage,
        note: result.note,
        tags: result.tags,
      );
    }
  }

  Future<void> _addImage(BuildContext context) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    if (!context.mounted) return;
    final meta = await _promptFields(
      context,
      title: 'IMAGE CAPTURE',
      skipPrimary: true,
    );
    final repo = ref.read(itemsRepositoryProvider);
    await repo.addFileFromPath(
      project: widget.project,
      path: x.path,
      type: ItemsRepository.typeFromMime(x.mimeType, path: x.name),
      stage: _stage,
      fileName: x.name,
      mimeType: x.mimeType,
      note: meta?.note,
      tags: meta?.tags ?? const [],
    );
  }

  Future<void> _addFile(BuildContext context) async {
    final picked = await FilePicker.platform.pickFiles(withData: false);
    if (picked == null || picked.files.isEmpty) return;
    final f = picked.files.first;
    if (f.path == null) return;
    if (!context.mounted) return;
    final meta = await _promptFields(
      context,
      title: 'FILE CAPTURE',
      skipPrimary: true,
    );
    final repo = ref.read(itemsRepositoryProvider);
    final type = ItemsRepository.typeFromMime(null, path: f.path ?? f.name);
    await repo.addFileFromPath(
      project: widget.project,
      path: f.path!,
      type: type,
      stage: _stage,
      fileName: f.name,
      note: meta?.note,
      tags: meta?.tags ?? const [],
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: CortexColors.accent),
      title: Text(label, style: CortexTheme.body()),
      onTap: onTap,
    );
  }
}

class _FieldResult {
  const _FieldResult({
    required this.primary,
    this.note,
    this.tags = const [],
  });

  final String primary;
  final String? note;
  final List<String> tags;
}

Future<_FieldResult?> _promptFields(
  BuildContext context, {
  required String title,
  String? primaryLabel,
  String? primaryHint,
  bool multiline = false,
  bool skipPrimary = false,
}) {
  return showModalBottomSheet<_FieldResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: CortexColors.elevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      side: BorderSide(color: CortexColors.hairline),
    ),
    builder: (ctx) => _FieldsSheet(
      title: title,
      primaryLabel: primaryLabel,
      primaryHint: primaryHint,
      multiline: multiline,
      skipPrimary: skipPrimary,
    ),
  );
}

class _FieldsSheet extends StatefulWidget {
  const _FieldsSheet({
    required this.title,
    this.primaryLabel,
    this.primaryHint,
    this.multiline = false,
    this.skipPrimary = false,
  });

  final String title;
  final String? primaryLabel;
  final String? primaryHint;
  final bool multiline;
  final bool skipPrimary;

  @override
  State<_FieldsSheet> createState() => _FieldsSheetState();
}

class _FieldsSheetState extends State<_FieldsSheet> {
  final _primary = TextEditingController();
  final _note = TextEditingController();
  final _tags = TextEditingController();

  @override
  void dispose() {
    _primary.dispose();
    _note.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style:
                CortexTheme.orbitron(fontSize: 13, color: CortexColors.accent),
          ),
          const SizedBox(height: 14),
          if (!widget.skipPrimary)
            TextField(
              controller: _primary,
              autofocus: true,
              maxLines: widget.multiline ? 5 : 1,
              style: CortexTheme.body(),
              decoration: InputDecoration(
                labelText: widget.primaryLabel,
                hintText: widget.primaryHint,
              ),
            ),
          if (!widget.skipPrimary) const SizedBox(height: 12),
          TextField(
            controller: _note,
            style: CortexTheme.body(),
            decoration: const InputDecoration(labelText: 'Note (optional)'),
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
            onPressed: () {
              if (!widget.skipPrimary && _primary.text.trim().isEmpty) return;
              Navigator.pop(
                context,
                _FieldResult(
                  primary: _primary.text,
                  note: _note.text,
                  tags: _tags.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: CortexColors.accent,
              foregroundColor: CortexColors.background,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              'SAVE',
              style: CortexTheme.orbitron(
                fontSize: 12,
                color: CortexColors.background,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
