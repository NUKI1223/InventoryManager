import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../api/product_api.dart';
import '../models/import_report.dart';
import 'product_provider.dart';

final importExportProvider = Provider<ImportExportService>((ref) {
  final api = ref.read(productApiProvider);
  return ImportExportService(ref, api);
});

class ImportExportService {
  final Ref ref;
  final ProductApi api;
  ImportExportService(this.ref, this.api);

  /// Get proper directory based on platform
  Future<Directory> _getExportDirectory() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      if (Platform.isAndroid) {
        var manageStatus = await Permission.manageExternalStorage.status;
        if (!manageStatus.isGranted) {
          await Permission.manageExternalStorage.request();
        }
      }

      try {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          return downloadsDir;
        }
      } catch (e) {
        print('Could not access Downloads: $e');
      }

      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final documentsDir = Directory('${externalDir.path}/Documents');
          if (!await documentsDir.exists()) {
            await documentsDir.create(recursive: true);
          }
          return documentsDir;
        }
      } catch (e) {
        print('Could not access external storage: $e');
      }

      return await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else {
      final downloadsDir = await getDownloadsDirectory();
      return downloadsDir ?? await getApplicationDocumentsDirectory();
    }
  }

  /// Export — saves to Downloads folder on Android, returns path
  Future<String> exportToXlsx({String? q}) async {
    final bytes = await api.exportProducts(q: q);
    final dir = await _getExportDirectory();
    final fileName = 'products_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final path = '${dir.path}/$fileName';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    print('File exported to: $path'); // Debug log
    return path;
  }

  /// Export with user-selected location
  Future<String?> exportToXlsxWithPicker({String? q}) async {
    final bytes = await api.exportProducts(q: q);
    final fileName = 'products_${DateTime.now().millisecondsSinceEpoch}.xlsx';


    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Excel File',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (outputPath == null) {
      return null;
    }
    if (!outputPath.endsWith('.xlsx')) {
      outputPath = '$outputPath.xlsx';
    }

    final file = File(outputPath);
    await file.writeAsBytes(bytes, flush: true);

    return outputPath;
  }

  /// Export and share via system share dialog
  Future<void> exportAndShare({String? q}) async {
    final path = await exportToXlsx(q: q);
    await Share.shareXFiles([XFile(path)], text: 'Products export');
  }

  Future<ImportReport?> importFromPicker({String mode = 'UPSERT'}) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );
    if (res == null || res.files.isEmpty) return null;
    final picked = res.files.first;
    final path = picked.path;
    if (path == null) throw Exception('File path is null');
    final report = await api.importProducts(path, mode: mode);
    await ref.read(productListProvider.notifier).fetchProducts();
    return report;
  }
}