import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/enrichment/link_preview_service.dart';
import '../../../data/enrichment/link_utils.dart';
import '../../../data/file_storage.dart';
import '../../../data/models/research_enums.dart';
import '../../../data/models/research_item.dart';
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

  final ResearchItem item;
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
                  if (item.stance != Stance.neutral) ...[
                    const SizedBox(width: 6),
                    _StanceBadge(stance: item.stance),
                  ],
                  if (item.credibility != Credibility.unknown) ...[
                    const SizedBox(width: 6),
                    _CredibilityBadge(credibility: item.credibility),
                  ],
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
  final ResearchItem item;

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
  final ResearchItem item;

  @override
  Widget build(BuildContext context) {
    final pending = item.previewTitle == item.sourceUrl &&
        item.previewImageUrl == null;
    final title = item.previewTitle ?? item.sourceUrl ?? 'Link';
    final isYt = item.sourceUrl != null &&
        LinkUtils.isYouTubeUrl(item.sourceUrl!);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewThumb(
          imageRef: item.previewImageUrl,
          pending: pending,
          youtube: isYt,
        ),
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
                isYt ? 'youtube.com' : domainOf(item.sourceUrl),
                style: CortexTheme.mono(
                  fontSize: 11,
                  color: isYt ? CortexColors.accent : CortexColors.muted,
                ),
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
  const _PreviewThumb({
    required this.imageRef,
    required this.pending,
    this.youtube = false,
  });

  final String? imageRef;
  final bool pending;
  final bool youtube;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (pending) {
      image = const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: CortexColors.accent,
          ),
        ),
      );
    } else if (imageRef == null) {
      image = Icon(
        youtube ? Icons.play_circle_outline : Icons.link,
        color: CortexColors.accent,
      );
    } else if (LinkPreviewService.isCachedLocalPath(imageRef)) {
      image = FutureBuilder<String>(
        future: FileStorage.absoluteFromRelative(imageRef!),
        builder: (context, snap) {
          if (!snap.hasData) {
            return Icon(
              youtube ? Icons.play_circle_outline : Icons.link,
              color: CortexColors.accent,
            );
          }
          return Image.file(
            File(snap.data!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              youtube ? Icons.play_circle_outline : Icons.link,
              color: CortexColors.accent,
            ),
          );
        },
      );
    } else {
      image = Image.network(
        imageRef!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          youtube ? Icons.play_circle_outline : Icons.link,
          color: CortexColors.accent,
        ),
      );
    }

    return Container(
      width: 72,
      height: 56,
      decoration: BoxDecoration(
        color: CortexColors.elevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CortexColors.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          if (youtube && !pending && imageRef != null)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white70,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageBody extends ConsumerWidget {
  const _ImageBody({required this.item});
  final ResearchItem item;

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
  final ResearchItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.previewImageUrl != null)
              _FullBleedThumb(imageRef: item.previewImageUrl!)
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
  final ResearchItem item;

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

class _FullBleedThumb extends StatelessWidget {
  const _FullBleedThumb({required this.imageRef});

  final String imageRef;

  @override
  Widget build(BuildContext context) {
    if (LinkPreviewService.isCachedLocalPath(imageRef)) {
      return FutureBuilder<String>(
        future: FileStorage.absoluteFromRelative(imageRef),
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
      );
    }
    return Image.network(
      imageRef,
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
  }
}

class _StanceBadge extends StatelessWidget {
  const _StanceBadge({required this.stance});

  final Stance stance;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (stance) {
      Stance.supports => ('▲', CortexColors.accent),
      Stance.refutes => ('▼', CortexColors.danger),
      Stance.neutral => ('—', CortexColors.muted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: CortexColors.elevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: CortexColors.hairline),
      ),
      child: Text(
        label,
        style: CortexTheme.mono(fontSize: 10, color: color),
      ),
    );
  }
}

class _CredibilityBadge extends StatelessWidget {
  const _CredibilityBadge({required this.credibility});

  final Credibility credibility;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: CortexColors.elevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: CortexColors.hairline),
      ),
      child: Text(
        credibility.name.toUpperCase(),
        style: CortexTheme.mono(fontSize: 9, color: CortexColors.muted),
      ),
    );
  }
}
