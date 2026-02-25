import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'upload_image_screen.dart';
import 'adjust_stock_screen.dart';
import 'history_screen.dart';
import '../utils/error_handler.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productProvider(productId));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF60A5FA), size: 20),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Детали товара',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: product == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFFECDD3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFFB7185),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Товар не найден',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Card
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF93C5FD).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: product.imagePath != null && product.imagePath!.isNotEmpty
                    ? _buildImage(product)
                    : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFDBEAFE),
                        const Color(0xFFBFDBFE),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    size: 96,
                    color: Color(0xFF60A5FA),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Product Name Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF93C5FD).withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.qr_code, 'Артикул', product.sku),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.inventory, 'Запас', '${product.currentStock} шт'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.attach_money, 'Цена', '${product.price.toStringAsFixed(0)} ₸'),
                  if (product.categoryName != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.category, 'Категория', product.categoryName!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            const Text(
              'Действия',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            _buildActionButton(
              context,
              icon: Icons.image,
              label: 'Загрузить фото',
              color: const Color(0xFF60A5FA),
              onPressed: () => _onUploadPressed(context, ref, product),
            ),
            const SizedBox(height: 10),

            _buildActionButton(
              context,
              icon: Icons.edit,
              label: 'Изменить запас',
              color: const Color(0xFF86EFAC),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdjustStockScreen(productId: product.id)),
              ),
            ),
            const SizedBox(height: 10),

            _buildActionButton(
              context,
              icon: Icons.history,
              label: 'История изменений',
              color: const Color(0xFFA78BFA),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryScreen(productId: product.id)),
              ),
            ),
            const SizedBox(height: 10),

            _buildActionButton(
              context,
              icon: Icons.delete,
              label: 'Удалить товар',
              color: const Color(0xFFFB7185),
              onPressed: () => _confirmAndDelete(context, ref, product),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF60A5FA)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onPressed,
      }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: color.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(Product p) {
    final path = p.imagePath!;
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, size: 60),
        ),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, size: 60),
        ),
      );
    }
  }

  Future<void> _onUploadPressed(BuildContext context, WidgetRef ref, Product product) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => UploadImageScreen(productId: product.id)),
    );

    if (result == null) return;
    if (result is Product) {
      ref.read(productListProvider.notifier).updateProduct(result);
    } else if (result is String) {
      final updated = product.copyWith(imagePath: result);
      ref.read(productListProvider.notifier).updateProduct(updated);
    } else {
      await ref.read(productListProvider.notifier).fetchProducts();
    }
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Удалить товар',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Вы уверены, что хотите безвозвратно удалить "${product.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFB7185),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Удаление...'),
        duration: Duration(milliseconds: 800),
      ),
    );

    try {
      await ref.read(productApiProvider).deleteProduct(product.id);
      ref.read(productListProvider.notifier).removeProduct(product.id);
      context.go('/products');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Товар удалён'),
          backgroundColor: Color(0xFF86EFAC),
        ),
      );
    } catch (e) {
      final msg = friendlyError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления: $msg')),
      );
    }
  }
}