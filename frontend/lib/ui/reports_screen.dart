import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _isLoading = false;
  String? _lastDownloadedFile;

  Future<void> _downloadReport(String endpoint, String fileName) async {
    setState(() => _isLoading = true);

    try {
      final client = ApiClient(Dio(), const FlutterSecureStorage());
      final response = await client.dio.get(
        '${client.dio.options.baseUrl}$endpoint',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      // Save to downloads directory
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(response.data);

      setState(() {
        _lastDownloadedFile = file.path;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Отчёт сохранён: ${file.path}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
        title: const Text('Отчёты'),
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Доступные отчёты',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Выберите тип отчёта для скачивания в формате Excel',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                _ReportCard(
                  icon: Icons.inventory_2,
                  title: 'Отчёт по товарам',
                  description: 'Полный список товаров с ценами и запасами',
                  color: Colors.blue,
                  onTap: () => _downloadReport(
                    '/api/reports/products',
                    'products_report_${DateTime.now().millisecondsSinceEpoch}.xlsx',
                  ),
                ),
                const SizedBox(height: 16),
                _ReportCard(
                  icon: Icons.history,
                  title: 'Отчёт по транзакциям',
                  description: 'История всех складских операций',
                  color: Colors.green,
                  onTap: () => _downloadReport(
                    '/api/reports/transactions',
                    'transactions_report_${DateTime.now().millisecondsSinceEpoch}.xlsx',
                  ),
                ),
                const SizedBox(height: 16),
                _ReportCard(
                  icon: Icons.warning_amber,
                  title: 'Отчёт по низким запасам',
                  description: 'Товары с запасом меньше порогового значения',
                  color: Colors.orange,
                  onTap: () => _downloadReport(
                    '/api/reports/low-stock?threshold=10',
                    'low_stock_report_${DateTime.now().millisecondsSinceEpoch}.xlsx',
                  ),
                ),
                if (_lastDownloadedFile != null) ...[
                  const SizedBox(height: 32),
                  Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Последний скачанный файл',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[900],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _lastDownloadedFile!,
                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.download, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
