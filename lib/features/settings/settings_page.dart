import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/export_service.dart';
import '../../data/file_storage.dart';
import '../../providers/isar_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/topics_provider.dart';
import '../../theme/cortex_colors.dart';
import '../../theme/cortex_theme.dart';
import '../../utils/format.dart';
import '../onboarding/onboarding_page.dart';

const _accentChoices = <int>[
  0xFF22D3EE,
  0xFF38BDF8,
  0xFF34D399,
  0xFFFBBF24,
  0xFFF87171,
  0xFFA78BFA,
];

final _storageProvider = FutureProvider<int>((ref) {
  return FileStorage.cortexStorageBytes();
});

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(topicsProvider).valueOrNull ?? [];
    final defaultId = ref.watch(defaultCaptureTopicIdProvider).valueOrNull;
    final accent =
        ref.watch(accentColorValueProvider).valueOrNull ?? 0xFF22D3EE;
    final storageAsync = ref.watch(_storageProvider);

    return Scaffold(
      backgroundColor: CortexColors.background,
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: CortexTheme.orbitron(fontSize: 16, color: CortexColors.accent),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'APPEARANCE',
            style:
                CortexTheme.orbitron(fontSize: 12, color: CortexColors.muted),
          ),
          const SizedBox(height: 12),
          Text('Accent', style: CortexTheme.body()),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              for (final c in _accentChoices)
                GestureDetector(
                  onTap: () async {
                    final repo =
                        ref.read(settingsRepositoryProvider).valueOrNull;
                    await repo?.setAccentValue(c);
                    ref.invalidate(sharedPrefsProvider);
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            accent == c ? CortexColors.text : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'CAPTURE',
            style:
                CortexTheme.orbitron(fontSize: 12, color: CortexColors.muted),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int?>(
            initialValue: topics.any((t) => t.id == defaultId) ? defaultId : null,
            dropdownColor: CortexColors.elevated,
            decoration:
                const InputDecoration(labelText: 'Default capture topic'),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('None (ask each time)'),
              ),
              for (final t in topics)
                DropdownMenuItem<int?>(
                  value: t.id,
                  child: Text(t.title),
                ),
            ],
            onChanged: (id) async {
              final repo = ref.read(settingsRepositoryProvider).valueOrNull;
              await repo?.setDefaultTopicId(id);
              ref.invalidate(sharedPrefsProvider);
            },
          ),
          const SizedBox(height: 28),
          Text(
            'STORAGE',
            style:
                CortexTheme.orbitron(fontSize: 12, color: CortexColors.muted),
          ),
          const SizedBox(height: 8),
          storageAsync.when(
            loading: () => Text('Calculating…', style: CortexTheme.mono()),
            error: (e, _) => Text(
              '$e',
              style: CortexTheme.mono(color: CortexColors.danger),
            ),
            data: (bytes) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Local files', style: CortexTheme.body()),
              subtitle: Text(
                formatBytes(bytes),
                style: CortexTheme.mono(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.ios_share, color: CortexColors.accent),
            title: Text('Export bundle', style: CortexTheme.body()),
            subtitle: Text(
              'JSON + files zip (re-importable)',
              style: CortexTheme.mono(fontSize: 11),
            ),
            onTap: () => _export(context, ref),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(Icons.unarchive_outlined, color: CortexColors.accent),
            title: Text('Import bundle', style: CortexTheme.body()),
            subtitle: Text(
              'Restore a CORTEX export zip',
              style: CortexTheme.mono(fontSize: 11),
            ),
            onTap: () => _import(context, ref),
          ),
          const SizedBox(height: 28),
          Text(
            'HELP',
            style:
                CortexTheme.orbitron(fontSize: 12, color: CortexColors.muted),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(Icons.school_outlined, color: CortexColors.accent),
            title: Text('Show App Pair tip again', style: CortexTheme.body()),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => OnboardingPage(
                    onDone: () => Navigator.of(context).pop(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Local-first · Android 13+ · Galaxy Z Fold 6',
            style: CortexTheme.mono(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final isar = ref.read(isarProvider).valueOrNull;
    if (isar == null) return;
    try {
      final file = await ExportService(isar).exportBundle();
      if (!context.mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/zip')],
          text: 'CORTEX export',
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'EXPORT FAILED: $e',
            style: CortexTheme.mono(color: CortexColors.danger),
          ),
        ),
      );
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    final path = picked?.files.firstOrNull?.path;
    if (path == null) return;
    final isar = ref.read(isarProvider).valueOrNull;
    if (isar == null) return;
    try {
      await ExportService(isar).importBundle(File(path));
      ref.invalidate(topicsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'IMPORT COMPLETE',
            style: CortexTheme.mono(color: CortexColors.text),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'IMPORT FAILED: $e',
            style: CortexTheme.mono(color: CortexColors.danger),
          ),
        ),
      );
    }
  }
}
