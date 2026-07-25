import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/file_storage.dart';
import '../../data/models/item.dart';
import '../../data/models/item_type.dart';
import '../../data/models/topic.dart';
import '../../providers/items_provider.dart';
import '../../providers/topics_provider.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';
import '../../utils/format.dart';
import 'widgets/type_badge.dart';

class ItemDetailPage extends ConsumerStatefulWidget {
  const ItemDetailPage({super.key, required this.itemId});

  final int itemId;

  @override
  ConsumerState<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends ConsumerState<ItemDetailPage> {
  late final TextEditingController _note;
  late final TextEditingController _tags;
  late final TextEditingController _text;
  var _hydrated = false;

  @override
  void initState() {
    super.initState();
    _note = TextEditingController();
    _tags = TextEditingController();
    _text = TextEditingController();
  }

  @override
  void dispose() {
    _note.dispose();
    _tags.dispose();
    _text.dispose();
    super.dispose();
  }

  void _hydrate(Item item) {
    if (_hydrated) return;
    _note.text = item.note ?? '';
    _tags.text = item.tags.join(', ');
    _text.text = item.text ?? '';
    _hydrated = true;
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(itemByIdProvider(widget.itemId));

    return itemAsync.when(
      loading: () => const Scaffold(
        backgroundColor: CortexColors.background,
        body: Center(
          child: CircularProgressIndicator(color: CortexColors.accent),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: CortexColors.background,
        appBar: AppBar(),
        body: Center(
          child: Text('$e', style: CortexTheme.mono(color: CortexColors.danger)),
        ),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            backgroundColor: CortexColors.background,
            appBar: AppBar(),
            body: Center(
              child: Text(
                'ITEM DELETED',
                style: CortexTheme.orbitron(color: CortexColors.muted),
              ),
            ),
          );
        }
        _hydrate(item);
        return _DetailScaffold(
          item: item,
          note: _note,
          tags: _tags,
          text: _text,
          onSave: () => _save(item),
          onDelete: () => _delete(item),
          onMove: () => _move(item),
          onShare: () => _share(item),
          onOpenSource: () => _openSource(item),
        );
      },
    );
  }

  Future<void> _save(Item item) async {
    final repo = ref.read(itemsRepositoryProvider).valueOrNull;
    if (repo == null) return;
    await repo.updateMeta(
      item,
      note: _note.text,
      tags: _tags.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      text: item.type == ItemType.text ? _text.text : null,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SAVED', style: CortexTheme.mono(color: CortexColors.text)),
      ),
    );
  }

  Future<void> _delete(Item item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('DELETE ITEM'),
        content: Text(
          'Remove this capture permanently?',
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
    final repo = ref.read(itemsRepositoryProvider).valueOrNull;
    if (repo == null) return;
    await repo.delete(item);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _move(Item item) async {
    final topics = ref.read(topicsProvider).valueOrNull ?? [];
    await item.topic.load();
    if (!mounted) return;
    final currentId = item.topic.value?.id;
    final chosen = await showModalBottomSheet<Topic>(
      context: context,
      backgroundColor: CortexColors.elevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: CortexColors.hairline),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'MOVE TO TOPIC',
                style: CortexTheme.orbitron(
                  fontSize: 13,
                  color: CortexColors.accent,
                ),
              ),
            ),
            for (final t in topics)
              ListTile(
                enabled: t.id != currentId,
                title: Text(t.title, style: CortexTheme.body()),
                trailing: t.id == currentId
                    ? Text('CURRENT', style: CortexTheme.mono(fontSize: 10))
                    : null,
                onTap: () => Navigator.pop(ctx, t),
              ),
          ],
        ),
      ),
    );
    if (chosen == null) return;
    final repo = ref.read(itemsRepositoryProvider).valueOrNull;
    if (repo == null) return;
    await repo.moveToTopic(item, chosen);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'MOVED → ${chosen.title}',
          style: CortexTheme.mono(color: CortexColors.text),
        ),
      ),
    );
  }

  Future<void> _share(Item item) async {
    if (item.fileRelPath != null) {
      final abs = await FileStorage.absoluteFromRelative(item.fileRelPath!);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(abs, mimeType: item.mimeType, name: item.fileName)],
          text: item.note,
        ),
      );
      return;
    }
    final buffer = StringBuffer();
    if (item.text != null) buffer.writeln(item.text);
    if (item.sourceUrl != null) buffer.writeln(item.sourceUrl);
    if (item.note != null) buffer.writeln(item.note);
    await SharePlus.instance.share(ShareParams(text: buffer.toString().trim()));
  }

  Future<void> _openSource(Item item) async {
    final url = item.sourceUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'COULD NOT OPEN LINK',
            style: CortexTheme.mono(color: CortexColors.danger),
          ),
        ),
      );
    }
  }
}

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({
    required this.item,
    required this.note,
    required this.tags,
    required this.text,
    required this.onSave,
    required this.onDelete,
    required this.onMove,
    required this.onShare,
    required this.onOpenSource,
  });

  final Item item;
  final TextEditingController note;
  final TextEditingController tags;
  final TextEditingController text;
  final VoidCallback onSave;
  final VoidCallback onDelete;
  final VoidCallback onMove;
  final VoidCallback onShare;
  final VoidCallback onOpenSource;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CortexColors.background,
      appBar: AppBar(
        title: Text(
          'ITEM',
          style: CortexTheme.orbitron(fontSize: 14, color: CortexColors.accent),
        ),
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: onShare,
            icon: const Icon(Icons.ios_share, color: CortexColors.muted),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: CortexColors.muted),
            color: CortexColors.elevated,
            onSelected: (v) {
              switch (v) {
                case 'move':
                  onMove();
                case 'delete':
                  onDelete();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'move',
                child: Text('Move to topic', style: CortexTheme.body()),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete',
                  style: CortexTheme.body(color: CortexColors.danger),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              TypeBadge(type: item.type),
              const SizedBox(width: 10),
              Text(
                formatRelativeTime(item.createdAt),
                style: CortexTheme.mono(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MediaPreview(item: item),
          if (item.type == ItemType.text) ...[
            const SizedBox(height: 16),
            TextField(
              controller: text,
              maxLines: null,
              style: CortexTheme.body(),
              decoration: const InputDecoration(labelText: 'Text'),
            ),
          ],
          if (item.type == ItemType.link || item.sourceUrl != null) ...[
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.open_in_browser, color: CortexColors.accent),
              title: Text(
                item.previewTitle ?? item.sourceUrl ?? 'Source',
                style: CortexTheme.body(),
              ),
              subtitle: Text(
                domainOf(item.sourceUrl),
                style: CortexTheme.mono(fontSize: 11),
              ),
              onTap: item.sourceUrl != null ? onOpenSource : null,
            ),
          ],
          if (item.fileName != null) ...[
            const SizedBox(height: 8),
            Text(
              '${item.fileName} · ${formatBytes(item.fileSize)}',
              style: CortexTheme.mono(fontSize: 11),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: note,
            maxLines: 4,
            style: CortexTheme.body(),
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: tags,
            style: CortexTheme.mono(),
            decoration: const InputDecoration(
              labelText: 'Tags (comma-separated)',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onSave,
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

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    if (item.type == ItemType.image && item.fileRelPath != null) {
      return FutureBuilder<String>(
        future: FileStorage.absoluteFromRelative(item.fileRelPath!),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: CortexColors.accent),
              ),
            );
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InteractiveViewer(
              child: Image.file(
                File(snap.data!),
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      );
    }
    if (item.type == ItemType.video) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: CortexColors.elevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CortexColors.hairline),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_outline,
                  color: CortexColors.accent, size: 48),
              const SizedBox(height: 8),
              Text(
                item.fileName ?? 'Video',
                style: CortexTheme.mono(),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
