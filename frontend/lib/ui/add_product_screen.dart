import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../utils/error_handler.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  bool _loading = false;
  bool _autoValidate = false;
  int? _selectedCategoryId;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _stockCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Название обязательно';
    }
    if (value.trim().length < 2) {
      return 'Минимум 2 символа';
    }
    if (value.trim().length > 100) {
      return 'Не более 100 символов';
    }
    return null;
  }

  String? _validateSKU(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Артикул обязателен';
    }
    if (value.trim().length < 2) {
      return 'Артикул: минимум 2 символа';
    }
    if (value.trim().length > 50) {
      return 'Артикул: не более 50 символов';
    }
    // Check if SKU contains only alphanumeric and dash/underscore
    final skuRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!skuRegex.hasMatch(value.trim())) {
      return 'Только буквы, цифры, - и _';
    }
    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Количество обязательно';
    }
    final stock = int.tryParse(value.trim());
    if (stock == null) {
      return 'Введите корректное число';
    }
    if (stock < 0) {
      return 'Количество не может быть отрицательным';
    }
    if (stock > 1000000) {
      return 'Не более 1 000 000';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Цена обязательна';
    }
    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'Введите корректную цену';
    }
    if (price < 0) {
      return 'Цена не может быть отрицательной';
    }
    if (price > 1000000) {
      return 'Цена не более 1 000 000';
    }
    // Check for reasonable decimal places
    if (value.contains('.')) {
      final parts = value.split('.');
      if (parts.length > 1 && parts[1].length > 2) {
        return 'Максимум 2 знака после запятой';
      }
    }
    return null;
  }

  Future<void> _submit() async {
    // Enable auto-validation after first submit attempt
    setState(() => _autoValidate = true);

    // Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Исправьте ошибки в форме'),
          backgroundColor: Color(0xFFFB7185),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final product = Product(
        id: 0,
        name: _nameCtrl.text.trim(),
        sku: _skuCtrl.text.trim(),
        currentStock: int.parse(_stockCtrl.text.trim()),
        price: double.parse(_priceCtrl.text.trim()),
        imagePath: null,
        categoryId: _selectedCategoryId,
      );

      final created = await ref.read(productApiProvider).addProduct(product);
      ref.read(productListProvider.notifier).addProduct(created);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Товар успешно добавлен!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        if (context.canPop()) context.pop(); else context.go('/products');
      }
    } catch (e) {
      final msg = friendlyError(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(msg)),
              ],
            ),
            backgroundColor: const Color(0xFFFB7185),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0,
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
          'Добавить товар',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _autoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Icons.add_shopping_cart,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Form Card
              Container(
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
                  children: [
                    _buildModernTextField(
                      controller: _nameCtrl,
                      label: 'Название товара',
                      hint: 'напр., Ноутбук Dell',
                      icon: Icons.label,
                      validator: _validateName,
                    ),
                    const SizedBox(height: 20),
                    _buildModernTextField(
                      controller: _skuCtrl,
                      label: 'Артикул (SKU)',
                      hint: 'напр., SKU-001',
                      icon: Icons.qr_code,
                      validator: _validateSKU,
                      helperText: 'Только буквы, цифры, - и _',
                    ),
                    const SizedBox(height: 20),
                    _buildModernTextField(
                      controller: _stockCtrl,
                      label: 'Количество',
                      hint: 'напр., 100',
                      icon: Icons.inventory,
                      keyboardType: TextInputType.number,
                      validator: _validateStock,
                    ),
                    const SizedBox(height: 20),
                    _buildModernTextField(
                      controller: _priceCtrl,
                      label: 'Цена (₸)',
                      hint: 'напр., 1299.99',
                      icon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _validatePrice,
                      helperText: 'Максимум 2 знака после запятой',
                    ),
                    const SizedBox(height: 20),
                    _buildCategoryDropdown(),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF93C5FD), Color(0xFF60A5FA)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF93C5FD).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Добавить товар',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final asyncCategories = ref.watch(categoryListProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
          ),
          child: asyncCategories.when(
            data: (categories) => DropdownButtonFormField<int?>(
              value: _selectedCategoryId,
              decoration: InputDecoration(
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.category, size: 20, color: Color(0xFF60A5FA)),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              hint: const Text('Выберите категорию', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Без категории')),
                ...categories.map((c) => DropdownMenuItem<int?>(
                      value: c.id,
                      child: Text(c.name),
                    )),
              ],
              onChanged: (value) => setState(() => _selectedCategoryId = value),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, __) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ошибка загрузки категорий: ${friendlyError(e)}',
                    style: const TextStyle(color: Color(0xFFFB7185)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => ref.invalidate(categoryListProvider),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFBFDBFE),
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
              helperText: helperText,
              helperStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
              ),
              errorStyle: const TextStyle(
                color: Color(0xFFFB7185),
                fontSize: 12,
                height: 1.2,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF60A5FA)),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}