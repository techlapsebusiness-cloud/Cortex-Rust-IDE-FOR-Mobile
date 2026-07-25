import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../capture/capture_payload.dart';
import '../../capture/persist_payload.dart';
import '../../data/models/item_type.dart';
import '../../data/models/topic.dart';
import '../../providers/capture_provider.dart';
import '../../providers/items_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/topics_provider.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';
import '../topics/topic_editor_sheet.dart';

Future<void> showCaptureSheet(
  BuildContext context, {
  required List<CapturePayload> payloads,
  int? targetTopicId,
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
      initialTopicId: targetTopicId,
    ),
  );
}

class CaptureSheet extends ConsumerStatefulWidget {
  const CaptureSheet({
    super.key,
    required this.payloads,
    this.initialTopicId,
  });

  final List<CapturePayload> payloads;
  final int? initialTopicId;

  @override
  ConsumerState<CaptureSheet> createState() => _CaptureSheetState();
}

class _CaptureSheetState extends ConsumerState<CaptureSheet> {
  final _note = TextEditingController();
  final _tags = TextEditingController();
  int? _topicId;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _topicId = widget.initialTopicId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _topicId ??= widget.initialTopicId ??
        ref.read(captureTargetTopicIdProvider) ??
        ref.read(selectedTopicIdProvider) ??
        ref.read(defaultCaptureTopicIdProvider).valueOrNull;
  }

  @override
  void dispose() {
    _note.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topics = ref.watch(topicsProvider).valueOrNull ?? [];
    final recent = recentTopics(topics);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    // Resolve default topic once topics load.
    if (_topicId == null && topics.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _topicId = topics.first.id);
      });
    }

    Topic? selected;
    for (final t in topics) {
      if (t.id == _topicId) {
        selected = t;
        break;
      }
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
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
          Text('TOPIC', style: CortexTheme.mono(fontSize: 11)),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final t in recent)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        t.title,
                        style: CortexTheme.mono(
                          fontSize: 11,
                          color: _topicId == t.id
                              ? CortexColors.background
                              : CortexColors.text,
                        ),
                      ),
                      selected: _topicId == t.id,
                      selectedColor: Color(t.colorValue),
                      backgroundColor: CortexColors.surface,
                      side: BorderSide(
                        color: Color(t.colorValue).withValues(alpha: 0.4),
                      ),
                      onSelected: (_) => setState(() => _topicId = t.id),
                    ),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 16, color: CortexColors.accent),
                  label: Text(
                    'New topic',
                    style: CortexTheme.mono(
                      fontSize: 11,
                      color: CortexColors.accent,
                    ),
                  ),
                  backgroundColor: CortexColors.surface,
                  side: const BorderSide(color: CortexColors.hairline),
                  onPressed: () => _createTopic(),
                ),
              ],
            ),
          ),
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
            onPressed: _saving || selected == null ? null : () => _save(selected!),
            style: FilledButton.styleFrom(
              backgroundColor: CortexColors.accent,
              foregroundColor: CortexColors.background,
              disabledBackgroundColor: CortexColors.muted.withValues(alpha: 0.3),
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
    );
  }

  Future<void> _createTopic() async {
    final draft = await showTopicEditorSheet(context);
    if (draft == null) return;
    final repo = ref.read(topicsRepositoryProvider).valueOrNull;
    if (repo == null) return;
    final topic = await repo.create(
      title: draft.title,
      description: draft.description,
      colorValue: draft.colorValue,
    );
    if (!mounted) return;
    setState(() => _topicId = topic.id);
    ref.read(selectedTopicIdProvider.notifier).state = topic.id;
  }

  Future<void> _save(Topic topic) async {
    final repo = ref.read(itemsRepositoryProvider).valueOrNull;
    if (repo == null) return;
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
          topic,
          payload,
          note: note,
          tags: tags,
        );
      }
      ref.read(selectedTopicIdProvider.notifier).state = topic.id;
      clearCapture(ref);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'CAPTURED → ${topic.title}',
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
