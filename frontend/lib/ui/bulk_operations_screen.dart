import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../models/product.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';

class BulkOperationsScreen extends ConsumerStatefulWidget {
  const BulkOperationsScreen({super.key});

  @override
  ConsumerState<BulkOperationsScreen> createState() => _BulkOperationsScreenState();
}

class _BulkOperationsScreenState extends ConsumerState<BulkOperationsScreen> {
  final Set<int> _selectedIds = {};
  bool _isLoading = false;

  Future<void> _bulkDelete() async {
    if (_selectedIds.isEmpty) {
      _showMessage('Выберите товары для удаления');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Подтвердите удаление'),
        content: Text('Удалить ${_selectedIds.length} товаров?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final client = ApiClient(Dio(), const FlutterSecureStorage());
      await client.post('/api/bulk/delete', data: _selectedIds.toList());

      setState(() {
        _selectedIds.clear();
        _isLoading = false;
      });

      ref.invalidate(productListProvider);
      _showMessage('Товары удалены успешно', isError: false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Ошибка: $e');
    }
  }

  Future<void> _bulkUpdatePrice() async {
    if (_selectedIds.isEmpty) {
      _showMessage('Выберите товары');
      return;
    }

    final priceController = TextEditingController();
    final newPrice = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Обновить цену'),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Новая цена',
            prefixIcon: Icon(Icons.attach_money),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final price = double.tryParse(priceController.text);
              if (price == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Неверная цена')),
                );
                return;
              }
              if (price < 0 || price > 1000000) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Цена должна быть от 0 до 1,000,000')),
                );
                return;
              }
              Navigator.pop(ctx, price);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (newPrice == null) return;

    setState(() => _isLoading = true);

    try {
      final client = ApiClient(Dio(), const FlutterSecureStorage());
      await client.post('/api/bulk/update-price', data: {
        'productIds': _selectedIds.toList(),
        'newPrice': newPrice,
      });

      setState(() {
        _selectedIds.clear();
        _isLoading = false;
      });

      ref.invalidate(productListProvider);
      _showMessage('Цены обновлены успешно', isError: false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Ошибка: $e');
    }
  }

  Future<void> _bulkAdjustStock() async {
    if (_selectedIds.isEmpty) {
      _showMessage('Выберите товары');
      return;
    }

    final amountController = TextEditingController();
    String selectedType = 'INCOMING';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Корректировка запаса'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Тип операции'),
                items: const [
                  DropdownMenuItem(value: 'INCOMING', child: Text('Поступление')),
                  DropdownMenuItem(value: 'SALE', child: Text('Продажа')),
                  DropdownMenuItem(value: 'ADJUSTMENT', child: Text('Корректировка')),
                  DropdownMenuItem(value: 'DAMAGE', child: Text('Списание')),
                ],
                onChanged: (val) => setState(() => selectedType = val!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Изменение количества',
                  helperText: 'Используйте "-" для уменьшения',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final amount = int.tryParse(amountController.text);
                if (amount == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Неверное количество')),
                  );
                  return;
                }
                if (amount == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Количество не может быть нулевым')),
                  );
                  return;
                }
                if (amount < -1000000 || amount > 1000000) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Количество должно быть от -1,000,000 до 1,000,000')),
                  );
                  return;
                }
                Navigator.pop(ctx, {'type': selectedType, 'amount': amount});
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    setState(() => _isLoading = true);

    try {
      final client = ApiClient(Dio(), const FlutterSecureStorage());
      await client.post('/api/bulk/adjust-stock', data: {
        'productIds': _selectedIds.toList(),
        'changeAmount': result['amount'],
        'type': result['type'],
        'reference': 'BULK_OP',
        'note': 'Bulk operation from app',
      });

      setState(() {
        _selectedIds.clear();
        _isLoading = false;
      });

      ref.invalidate(productListProvider);
      _showMessage('Запасы обновлены успешно', isError: false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Ошибка: $e');
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF60A5FA), size: 20),
          ),
          onPressed: () => context.go('/products'),
        ),
        title: Text('Bulk операции (${_selectedIds.length})'),
        actions: [
          if (_selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Снять выделение',
              onPressed: () => setState(() => _selectedIds.clear()),
            ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('Нет товаров'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final isSelected = _selectedIds.contains(product.id);

              return CheckboxListTile(
                value: isSelected,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedIds.add(product.id);
                    } else {
                      _selectedIds.remove(product.id);
                    }
                  });
                },
                title: Text(product.name),
                subtitle: Text('SKU: ${product.sku} | Запас: ${product.currentStock}'),
                secondary: CircleAvatar(
                  child: Text('${product.currentStock}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Ошибка: $e')),
      ),
      bottomNavigationBar: _selectedIds.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _bulkAdjustStock,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Запас'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _bulkUpdatePrice,
                        icon: const Icon(Icons.attach_money),
                        label: const Text('Цена'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _bulkDelete,
                        icon: const Icon(Icons.delete),
                        label: const Text('Удалить'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
