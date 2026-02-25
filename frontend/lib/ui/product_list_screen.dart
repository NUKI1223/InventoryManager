import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/import_export_provider.dart';
import 'add_product_screen.dart';
import 'search_screen.dart';
import '../providers/notification_provider.dart';
import '../utils/error_handler.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    final notifier = ref.read(productListProvider.notifier);
    if (!notifier.hasMore) return;

    setState(() => _isLoadingMore = true);
    try {
      await notifier.loadMore();
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(productListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            'Товары',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF60A5FA)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          Consumer(
            builder: (context, ref, _) {
              final unreadAsync = ref.watch(unreadCountProvider);
              return IconButton(
                icon: Badge(
                  label: unreadAsync.when(
                    data: (count) => Text('$count'),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  isLabelVisible: unreadAsync.maybeWhen(
                    data: (count) => count > 0,
                    orElse: () => false,
                  ),
                  child: const Icon(Icons.notifications, color: Color(0xFFF59E0B)),
                ),
                tooltip: 'Уведомления',
                onPressed: () => context.push('/notifications'),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF60A5FA)),
            onSelected: (value) async {
              switch (value) {
                case 'admin':
                  context.push('/admin');
                  break;
                case 'dashboard':
                  context.push('/dashboard');
                  break;
                case 'categories':
                  context.push('/categories');
                  break;
                case 'stats':
                  context.push('/stats');
                  break;
                case 'history':
                  context.push('/history');
                  break;
                case 'import':
                  final excelApi = ref.read(importExportProvider);
                  try {
                    await excelApi.importFromPicker();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Импорт выполнен'),
                        backgroundColor: Color(0xFF86EFAC),
                      ),
                    );
                    ref.read(productListProvider.notifier).fetchProducts();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка импорта: $e')),
                    );
                  }
                  break;
                case 'export':
                  final excelApi = ref.read(importExportProvider);
                  try {
                    final filePath = await excelApi.exportToXlsx();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Файл сохранён: $filePath'),
                        backgroundColor: Color(0xFF86EFAC),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка экспорта: $e')),
                    );
                  }
                  break;
                case 'profile':
                  context.push('/profile');
                  break;
                case 'logout':
                  ref.read(authNotifierProvider.notifier).logout();
                  context.go('/');
                  break;
              }
            },
            itemBuilder: (context) {
              final asyncIsAdmin = ref.read(isAdminProvider);
              return [
                if (asyncIsAdmin.valueOrNull == true)
                  const PopupMenuItem(
                    value: 'admin',
                    child: ListTile(
                      leading: Icon(Icons.admin_panel_settings, color: Color(0xFFFB7185)),
                      title: Text('Панель администратора'),
                    ),
                  ),
                const PopupMenuItem(
                  value: 'dashboard',
                  child: ListTile(
                    leading: Icon(Icons.dashboard, color: Color(0xFF6366F1)),
                    title: Text('Главная'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'categories',
                  child: ListTile(
                    leading: Icon(Icons.category, color: Color(0xFF60A5FA)),
                    title: Text('Категории'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'stats',
                  child: ListTile(
                    leading: Icon(Icons.bar_chart, color: Color(0xFF60A5FA)),
                    title: Text('Статистика'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'history',
                  child: ListTile(
                    leading: Icon(Icons.history, color: Color(0xFF60A5FA)),
                    title: Text('История'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'import',
                  child: ListTile(
                    leading: Icon(Icons.upload_file, color: Color(0xFF60A5FA)),
                    title: Text('Импорт Excel'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: Icon(Icons.download, color: Color(0xFF60A5FA)),
                    title: Text('Экспорт Excel'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person, color: Color(0xFF10B981)),
                    title: Text('Профиль'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Color(0xFFFB7185)),
                    title: Text('Выйти'),
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: asyncList.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Color(0xFF60A5FA),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Нет товаров',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Добавьте первый товар',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.read(productListProvider.notifier).fetchProducts(),
            color: const Color(0xFF60A5FA),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: list.length + 1,
              itemBuilder: (_, i) {
                if (i == list.length) {
                  final notifier = ref.read(productListProvider.notifier);
                  if (!notifier.hasMore) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: _isLoadingMore
                          ? const CircularProgressIndicator(
                        color: Color(0xFF60A5FA),
                      )
                          : Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF93C5FD), Color(0xFF60A5FA)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF93C5FD).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _loadMore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(Icons.expand_more, size: 20),
                          label: const Text(
                            'Загрузить ещё',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final p = list[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push('/products/${p.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFDBEAFE),
                                    Color(0xFFBFDBFE),
                                  ],
                                ),
                              ),
                              child: p.imagePath != null && p.imagePath!.isNotEmpty
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(p.imagePath!),
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : const Icon(
                                Icons.inventory_2,
                                size: 36,
                                color: Color(0xFF60A5FA),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Арт.: ${p.sku}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDBEAFE),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.inventory,
                                              size: 14,
                                              color: Color(0xFF60A5FA),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${p.currentStock}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF60A5FA),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (p.categoryName != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0FDF4),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.category,
                                                size: 14,
                                                color: Color(0xFF10B981),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                p.categoryName!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF10B981),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF60A5FA),
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Color(0xFFFB7185)),
                const SizedBox(height: 16),
                Text(
                  friendlyError(e),
                  style: const TextStyle(color: Color(0xFFFB7185)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.read(productListProvider.notifier).fetchProducts(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Повторить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF60A5FA),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF93C5FD), Color(0xFF60A5FA)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF93C5FD).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}
