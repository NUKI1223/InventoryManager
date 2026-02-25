import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/search_provider.dart';
import '../providers/category_provider.dart';
import '../utils/error_handler.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String initialQuery;
  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _sort = 'name,asc';
  int? _selectedCategoryId;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.initialQuery;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchNotifierProvider.notifier).search(q: _ctrl.text.trim(), sort: _sort, page: 0);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onSubmit() => ref.read(searchNotifierProvider.notifier).search(
    q: _ctrl.text.trim(),
    sort: _sort,
    categoryId: _selectedCategoryId,
    page: 0,
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0, // ✅ Fixed spacing
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
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
          ),
          child: TextField(
            controller: _ctrl,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _onSubmit(),
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'Поиск товаров...',
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Color(0xFF60A5FA), size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _showFilters
                    ? const Color(0xFF86EFAC).withOpacity(0.3)
                    : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.tune,
                color: _showFilters
                    ? const Color(0xFF10B981)
                    : const Color(0xFF60A5FA),
                size: 20,
              ),
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Modern Filter Panel
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _showFilters ? null : 0,
            child: _showFilters
                ? Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.sort,
                          color: Color(0xFF60A5FA),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Сортировка',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSortChip('Название ↑', 'name,asc', Icons.sort_by_alpha),
                      _buildSortChip('Название ↓', 'name,desc', Icons.sort_by_alpha),
                      _buildSortChip('Цена ↑', 'price,asc', Icons.arrow_upward),
                      _buildSortChip('Цена ↓', 'price,desc', Icons.arrow_downward),
                      _buildSortChip('Запас ↑', 'currentStock,asc', Icons.trending_up),
                      _buildSortChip('Запас ↓', 'currentStock,desc', Icons.trending_down),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.category, color: Color(0xFF10B981), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Категория',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Consumer(
                    builder: (context, ref, _) {
                      final asyncCats = ref.watch(categoryListProvider);
                      return asyncCats.when(
                        data: (cats) => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildCategoryChip('Все', null),
                            ...cats.map((c) => _buildCategoryChip(c.name, c.id)),
                          ],
                        ),
                        loading: () => const SizedBox(height: 32, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                        error: (_, __) => const Text('Ошибка загрузки категорий'),
                      );
                    },
                  ),
                ],
              ),
            )
                : const SizedBox.shrink(),
          ),

          // Search Results
          Expanded(
            child: state.when(
              data: (page) {
                if (page.content.isEmpty) {
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
                            Icons.search_off,
                            size: 64,
                            color: Color(0xFF60A5FA),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Ничего не найдено',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Попробуйте другие слова',
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
                  onRefresh: () async => ref.read(searchNotifierProvider.notifier).refresh(),
                  color: const Color(0xFF60A5FA),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: page.content.length + 1,
                    itemBuilder: (ctx, i) {
                      if (i == page.content.length) {
                        // Load more button - пагинация уже работает!
                        if (page.number + 1 < page.totalPages) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Container(
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
                                  onPressed: () => ref.read(searchNotifierProvider.notifier).nextPage(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                        } else {
                          return const SizedBox.shrink();
                        }
                      }
                      final p = page.content[i];
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
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
                                      ),
                                    ),
                                    child: p.imagePath != null && p.imagePath!.isNotEmpty
                                        ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(File(p.imagePath!), fit: BoxFit.cover),
                                    )
                                        : const Icon(Icons.inventory_2, color: Color(0xFF60A5FA), size: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Запас: ${p.currentStock} • Арт.: ${p.sku}',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
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
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF60A5FA))),
              error: (e, _) => Center(
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
                    Text(
                      friendlyError(e),
                      style: const TextStyle(color: Color(0xFF64748B)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, int? id) {
    final isSelected = _selectedCategoryId == id;
    return InkWell(
      onTap: () {
        setState(() => _selectedCategoryId = id);
        _onSubmit();
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFF6EE7B7), Color(0xFF10B981)])
              : null,
          color: isSelected ? null : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFA7F3D0),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value, IconData icon) {
    final isSelected = _sort == value;
    return InkWell(
      onTap: () {
        setState(() => _sort = value);
        _onSubmit();
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFF93C5FD), Color(0xFF60A5FA)],
          )
              : null,
          color: isSelected ? null : const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFBFDBFE),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF93C5FD).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF60A5FA),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}