import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/import_export_provider.dart';
import '../models/import_report.dart';
import 'package:open_file/open_file.dart';

class ImportExportSheet extends ConsumerWidget {
  const ImportExportSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Import / Export', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ]),
          const SizedBox(height: 6),
          ElevatedButton.icon(
            icon: const Icon(Icons.download_rounded),
            label: const Text('Export (.xlsx)'),
            onPressed: () async {
              Navigator.pop(context);
              final svc = ref.read(importExportProvider);
              final ctx = context;
              final scaffold = ScaffoldMessenger.of(ctx);
              scaffold.showSnackBar(const SnackBar(content: Text('Export started...')));
              try {
                final path = await svc.exportToXlsx();
                scaffold.showSnackBar(SnackBar(content: Text('Saved to $path')));
                await OpenFile.open(path);
              } catch (e) {
                scaffold.showSnackBar(SnackBar(content: Text('Export failed: $e')));
              }
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_rounded),
            label: const Text('Import (.xlsx)'),
            onPressed: () async {
              Navigator.pop(context);
              final svc = ref.read(importExportProvider);
              final scaffold = ScaffoldMessenger.of(context);
              scaffold.showSnackBar(const SnackBar(content: Text('Select file to import...')));
              try {
                final ImportReport? r = await svc.importFromPicker();
                if (r == null) {
                  scaffold.showSnackBar(const SnackBar(content: Text('Import cancelled')));
                  return;
                }
                final errors = r.errors.isEmpty ? 'No errors' : '${r.errors.length} error(s)';
                scaffold.showSnackBar(SnackBar(content: Text('Imported ${r.imported}, Updated ${r.updated}; $errors')));
                if (r.errors.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Import errors'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: r.errors.length,
                          itemBuilder: (_, i) => ListTile(
                            leading: Text('#${r.errors[i].row}'),
                            title: Text(r.errors[i].message),
                          ),
                        ),
                      ),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                    ),
                  );
                }
              } catch (e) {
                scaffold.showSnackBar(SnackBar(content: Text('Import failed: $e')));
              }
            },
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}
