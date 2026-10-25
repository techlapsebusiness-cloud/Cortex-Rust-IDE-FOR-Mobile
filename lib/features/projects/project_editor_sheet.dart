import 'package:flutter/material.dart';

import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';

const _projectColors = <int>[
  0xFF22D3EE,
  0xFF38BDF8,
  0xFF34D399,
  0xFFFBBF24,
  0xFFF87171,
  0xFFA78BFA,
  0xFFFB7185,
  0xFF2DD4BF,
];

Future<ProjectDraft?> showProjectEditorSheet(
  BuildContext context, {
  String? initialTitle,
  String? initialResearchQuestion,
  String? initialField,
  String? initialDescription,
  int initialColor = 0xFF22D3EE,
  String confirmLabel = 'CREATE',
}) {
  return showModalBottomSheet<ProjectDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: CortexColors.elevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      side: BorderSide(color: CortexColors.hairline),
    ),
    builder: (ctx) => _ProjectEditorSheet(
      initialTitle: initialTitle,
      initialResearchQuestion: initialResearchQuestion,
      initialField: initialField,
      initialDescription: initialDescription,
      initialColor: initialColor,
      confirmLabel: confirmLabel,
    ),
  );
}

class ProjectDraft {
  const ProjectDraft({
    required this.title,
    this.researchQuestion = '',
    this.field,
    this.description,
    required this.colorValue,
  });

  final String title;
  final String researchQuestion;
  final String? field;
  final String? description;
  final int colorValue;
}

class _ProjectEditorSheet extends StatefulWidget {
  const _ProjectEditorSheet({
    this.initialTitle,
    this.initialResearchQuestion,
    this.initialField,
    this.initialDescription,
    required this.initialColor,
    required this.confirmLabel,
  });

  final String? initialTitle;
  final String? initialResearchQuestion;
  final String? initialField;
  final String? initialDescription;
  final int initialColor;
  final String confirmLabel;

  @override
  State<_ProjectEditorSheet> createState() => _ProjectEditorSheetState();
}

class _ProjectEditorSheetState extends State<_ProjectEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _researchQuestion;
  late final TextEditingController _field;
  late final TextEditingController _description;
  late int _color;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initialTitle ?? '');
    _researchQuestion =
        TextEditingController(text: widget.initialResearchQuestion ?? '');
    _field = TextEditingController(text: widget.initialField ?? '');
    _description = TextEditingController(text: widget.initialDescription ?? '');
    _color = widget.initialColor;
  }

  @override
  void dispose() {
    _title.dispose();
    _researchQuestion.dispose();
    _field.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
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
            const SizedBox(height: 16),
            Text(
              widget.initialTitle == null ? 'NEW PROJECT' : 'EDIT PROJECT',
              style:
                  CortexTheme.orbitron(fontSize: 14, color: CortexColors.accent),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              autofocus: true,
              style: CortexTheme.body(),
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Rust async internals',
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _researchQuestion,
              style: CortexTheme.body(),
              decoration: const InputDecoration(
                labelText: 'Research question',
                hintText: 'What are you trying to find out?',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _field,
              style: CortexTheme.body(),
              decoration: const InputDecoration(
                labelText: 'Field (optional)',
                hintText: 'Security, Biology, UX…',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              style: CortexTheme.body(),
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Text('ACCENT', style: CortexTheme.mono(fontSize: 11)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final c in _projectColors)
                  GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _color == c
                              ? CortexColors.text
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: _color == c
                            ? [
                                BoxShadow(
                                  color: Color(c).withValues(alpha: 0.45),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: CortexColors.accent,
                foregroundColor: CortexColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.confirmLabel,
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

  void _submit() {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    Navigator.of(context).pop(
      ProjectDraft(
        title: title,
        researchQuestion: _researchQuestion.text.trim(),
        field: _field.text.trim().isEmpty ? null : _field.text.trim(),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        colorValue: _color,
      ),
    );
  }
}
