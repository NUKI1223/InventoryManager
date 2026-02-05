import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';
import '../providers/product_provider.dart';
import '../utils/error_handler.dart';

// State provider to track selected product IDs
final selectedProductIdsProvider = StateProvider<List<int>?>((ref) => null);

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  bool _showSelector = false;

  @override
  Widget build(BuildContext context) {
    final selectedIds = ref.watch(selectedProductIdsProvider);
    final asyncStats = selectedIds == null || selectedIds.isEmpty
        ? ref.watch(statsProvider)
        : ref.watch(statsProviderWithProducts(selectedIds));
    final asyncProducts = ref.watch(productListProvider);

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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Statistics',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selectedIds != null && selectedIds.isNotEmpty
                    ? const Color(0xFF86EFAC).withOpacity(0.3)
                    : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.filter_list,
                color: selectedIds != null && selectedIds.isNotEmpty
                    ? const Color(0xFF10B981)
                    : const Color(0xFF60A5FA),
                size: 20,
              ),
            ),
            onPressed: () => setState(() => _showSelector = !_showSelector),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Product Selector
          if (_showSelector)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Select Products',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      if (selectedIds != null && selectedIds.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            ref.read(selectedProductIdsProvider.notifier).state = null;
                          },
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Clear'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFB7185),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  asyncProducts.when(
                    data: (products) {
                      if (products.isEmpty) {
                        return const Center(
                          child: Text(
                            'No products available',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        );
                      }
                      return Container(
                        constraints: const BoxConstraints(maxHeight: 250),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: products.length,
                          itemBuilder: (_, i) {
                            final p = products[i];
                            final isSelected = selectedIds?.contains(p.id) ?? false;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFDBEAFE)
                                    : const Color(0xFFF0F9FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF60A5FA)
                                      : const Color(0xFFBFDBFE),
                                  width: 1.5,
                                ),
                              ),
                              child: CheckboxListTile(
                                value: isSelected,
                                onChanged: (checked) {
                                  final currentIds = selectedIds?.toList() ?? [];
                                  if (checked == true) {
                                    currentIds.add(p.id);
                                  } else {
                                    currentIds.remove(p.id);
                                  }
                                  ref.read(selectedProductIdsProvider.notifier).state =
                                  currentIds.isEmpty ? null : currentIds;
                                },
                                title: Text(
                                  p.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                subtitle: Text(
                                  'SKU: ${p.sku}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                activeColor: const Color(0xFF60A5FA),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                      child: Text(
                        'Error loading products',
                        style: TextStyle(color: Color(0xFFFB7185)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (selectedIds != null && selectedIds.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF86EFAC).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF10B981),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${selectedIds.length} product(s) selected',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

          // Stats Display
          Expanded(
            child: asyncStats.when(
              data: (s) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Header Icon
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF93C5FD), Color(0xFF60A5FA)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF93C5FD).withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.bar_chart_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Info Banner
                      if (selectedIds != null && selectedIds.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF60A5FA),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF60A5FA),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Showing stats for ${selectedIds.length} selected product(s)',
                                  style: const TextStyle(
                                    color: Color(0xFF60A5FA),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Stats Cards
                      _buildStatCard(
                        icon: Icons.inventory_2,
                        label: 'Total Products',
                        value: '${s.totalProducts}',
                        color: const Color(0xFF60A5FA),
                        bgColor: const Color(0xFFDBEAFE),
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        icon: Icons.warehouse,
                        label: 'Total Stock',
                        value: '${s.totalStock}',
                        color: const Color(0xFF8B5CF6),
                        bgColor: const Color(0xFFE9D5FF),
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        icon: Icons.attach_money,
                        label: 'Inventory Value',
                        value: '\$${s.totalInventoryValue.toStringAsFixed(2)}',
                        color: const Color(0xFF10B981),
                        bgColor: const Color(0xFFD1FAE5),
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        icon: Icons.sync_alt,
                        label: 'Total Changes',
                        value: '${s.totalChanges}',
                        color: const Color(0xFFF59E0B),
                        bgColor: const Color(0xFFFEF3C7),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF60A5FA),
                ),
              ),
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
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                      ),
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
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
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}