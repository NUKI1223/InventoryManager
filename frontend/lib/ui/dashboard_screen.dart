import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../models/product.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text('Главная'),
        backgroundColor: Colors.blue,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(lowStockProvider);
          ref.invalidate(zeroStockProvider);
          ref.invalidate(recentTransactionsProvider);
          ref.invalidate(categoryStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCategoryStatsSection(ref),
              const SizedBox(height: 16),
              _buildLowStockSection(ref),
              const SizedBox(height: 16),
              _buildZeroStockSection(ref),
              const SizedBox(height: 16),
              _buildRecentTransactionsSection(ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryStatsSection(WidgetRef ref) {
    final categoryStatsAsync = ref.watch(categoryStatsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.pie_chart, color: Colors.purple[700]),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Статистика по категориям',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            categoryStatsAsync.when(
              data: (stats) {
                if (stats.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text('Нет данных', style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return Column(
                  children: stats.map((stat) {
                    final category = stat['category'] ?? 'Unknown';
                    final productCount = stat['productCount'] ?? 0;
                    final totalStock = stat['totalStock'] ?? 0;
                    final totalValue = stat['totalValue'] ?? 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatChip(
                                Icons.inventory_2,
                                '$productCount товаров',
                                Colors.blue,
                              ),
                              _buildStatChip(
                                Icons.warehouse,
                                '$totalStock шт',
                                Colors.green,
                              ),
                              _buildStatChip(
                                Icons.attach_money,
                                '${totalValue.toStringAsFixed(0)} ₸',
                                Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Ошибка: $e', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockSection(WidgetRef ref) {
    final lowStockAsync = ref.watch(lowStockProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.warning_amber, color: Colors.orange[700]),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Низкий запас (< 10)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            lowStockAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text('Все товары в достаточном количестве'),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: products.take(5).map((p) {
                    final product = p as Product;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange[100],
                        child: Text('${product.currentStock}'),
                      ),
                      title: Text(product.name),
                      subtitle: Text('SKU: ${product.sku}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${product.currentStock} шт',
                          style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Ошибка: $e', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZeroStockSection(WidgetRef ref) {
    final zeroStockAsync = ref.watch(zeroStockProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.error_outline, color: Colors.red[700]),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Отсутствуют на складе',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            zeroStockAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text('Нет товаров с нулевым запасом'),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: products.take(5).map((p) {
                    final product = p as Product;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red[100],
                        child: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      ),
                      title: Text(product.name),
                      subtitle: Text('SKU: ${product.sku}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Нет в наличии',
                          style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Ошибка: $e', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsSection(WidgetRef ref) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.history, color: Colors.blue[700]),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Последние транзакции',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('Нет транзакций')),
                  );
                }

                return Column(
                  children: transactions.take(10).map((t) {
                    final type = t['transactionType'] ?? 'UNKNOWN';
                    final quantity = t['quantity'] ?? 0;
                    final timestamp = t['timestamp'] ?? '';

                    final isIncoming = type == 'INCOMING' || type == 'SALE_RETURN';
                    final icon = isIncoming ? Icons.arrow_downward : Icons.arrow_upward;
                    final color = isIncoming ? Colors.green : Colors.red;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.1),
                        child: Icon(icon, color: color),
                      ),
                      title: Text(type),
                      subtitle: Text(timestamp.toString().length >= 16
                          ? timestamp.toString().substring(0, 16)
                          : timestamp.toString()),
                      trailing: Text(
                        '${isIncoming ? '+' : '-'}$quantity',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Ошибка: $e', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
