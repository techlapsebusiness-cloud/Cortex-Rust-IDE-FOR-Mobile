import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/enrichment/link_preview_service.dart';
import '../../../data/file_storage.dart';
import '../../../data/models/item.dart';
import '../../../data/models/item_type.dart';
import '../../../theme/cortex_colors.dart';
import '../../../theme/cortex_theme.dart';
import '../../../utils/format.dart';
import 'type_badge.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CortexColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: CortexColors.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  TypeBadge(type: item.type),
                  const Spacer(),
                  Text(
                    formatRelativeTime(item.createdAt),
                    style: CortexTheme.mono(fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              switch (item.type) {
                ItemType.text => _TextBody(item: item),
                ItemType.link => _LinkBody(item: item),
                ItemType.image => _ImageBody(item: item),
                ItemType.video => _VideoBody(item: item),
                ItemType.file => _FileBody(item: item),
              },
              if (item.note != null && item.note!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  item.note!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CortexTheme.body(
                    fontSize: 13,
                    color: CortexColors.muted,
                  ),
                ),
              ],
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final tag in item.tags.take(4))
                      Text(
                        '#$tag',
                        style: CortexTheme.mono(
                          fontSize: 10,
                          color: CortexColors.secondaryGlow,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TextBody extends StatelessWidget {
  const _TextBody({required this.item});
  final Item item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: CortexColors.accent.withValues(alpha: 0.6),
                width: 3,
              ),
            ),
            color: CortexColors.elevated.withValues(alpha: 0.5),
          ),
          child: Text(
            '"${item.text ?? ''}"',
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: CortexTheme.body(fontSize: 14),
          ),
        ),
        if (item.sourceUrl != null) ...[
          const SizedBox(height: 8),
          Text(
            domainOf(item.sourceUrl),
            style: CortexTheme.mono(fontSize: 11),
          ),
        ],
      ],
    );
  }
}

class _LinkBody extends StatelessWidget {
  const _LinkBody({required this.item});
  final Item item;

  @override
  Widget build(BuildContext context) {
    final pending = item.previewTitle == item.sourceUrl &&
        item.previewImageUrl == null;
    final title = item.previewTitle ?? item.sourceUrl ?? 'Link';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewThumb(imageRef: item.previewImageUrl, pending: pending),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pending)
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: CortexColors.elevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              else
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CortexTheme.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                domainOf(item.sourceUrl),
                style: CortexTheme.mono(fontSize: 11),
              ),
              if (item.previewDescription != null &&
                  item.previewDescription!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.previewDescription!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CortexTheme.body(
                    fontSize: 12,
                    color: CortexColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewThumb extends StatelessWidget {
  const _PreviewThumb({required this.imageRef, required this.pending});

  final String? imageRef;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: CortexColors.elevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CortexColors.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: pending
          ? const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CortexColors.accent,
                ),
              ),
            )
          : imageRef == null
              ? const Icon(Icons.link, color: CortexColors.accent)
              : LinkPreviewService.isCachedLocalPath(imageRef)
                  ? FutureBuilder<String>(
                      future: FileStorage.absoluteFromRelative(imageRef!),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const Icon(Icons.link, color: CortexColors.accent);
                        }
                        return Image.file(
                          File(snap.data!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.link, color: CortexColors.accent),
                        );
                      },
                    )
                  : Image.network(
                      imageRef!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.link, color: CortexColors.accent),
                    ),
    );
  }
}

class _ImageBody extends ConsumerWidget {
  const _ImageBody({required this.item});
  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String?>(
      future: item.fileRelPath == null
          ? Future.value(null)
          : FileStorage.absoluteFromRelative(item.fileRelPath!),
      builder: (context, snap) {
        final path = snap.data;
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: path == null
                ? Container(
                    color: CortexColors.elevated,
                    child: const Icon(Icons.image, color: CortexColors.muted),
                  )
                : Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: CortexColors.elevated,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: CortexColors.muted,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _VideoBody extends ConsumerWidget {
  const _VideoBody({required this.item});
  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.thumbRelPath != null)
              FutureBuilder<String>(
                future: FileStorage.absoluteFromRelative(item.thumbRelPath!),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return Container(
                      color: CortexColors.elevated,
                      child: const Icon(
                        Icons.videocam_outlined,
                        color: CortexColors.muted,
                        size: 36,
                      ),
                    );
                  }
                  return Image.file(
                    File(snap.data!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: CortexColors.elevated,
                      child: const Icon(
                        Icons.videocam_outlined,
                        color: CortexColors.muted,
                        size: 36,
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                color: CortexColors.elevated,
                child: const Icon(
                  Icons.videocam_outlined,
                  color: CortexColors.muted,
                  size: 36,
                ),
              ),
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CortexColors.background.withValues(alpha: 0.7),
                  border: Border.all(color: CortexColors.accent),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: CortexColors.accent,
                  size: 28,
                ),
              ),
            ),
            if (item.fileName != null)
              Positioned(
                left: 10,
                bottom: 10,
                right: 10,
                child: Text(
                  item.fileName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CortexTheme.mono(
                    fontSize: 11,
                    color: CortexColors.text,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FileBody extends StatelessWidget {
  const _FileBody({required this.item});
  final Item item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: CortexColors.elevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CortexColors.hairline),
          ),
          child: Icon(
            _iconForMime(item.mimeType),
            color: CortexColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.fileName ?? 'File',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: CortexTheme.body(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                formatBytes(item.fileSize),
                style: CortexTheme.mono(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _iconForMime(String? mime) {
    final m = (mime ?? '').toLowerCase();
    if (m.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (m.contains('zip') || m.contains('rar') || m.contains('7z')) {
      return Icons.folder_zip_outlined;
    }
    if (m.contains('audio')) return Icons.audiotrack;
    if (m.startsWith('text/')) return Icons.description_outlined;
    return Icons.insert_drive_file_outlined;
  }
}
