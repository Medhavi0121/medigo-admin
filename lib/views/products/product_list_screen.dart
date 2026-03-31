import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/loading_widget.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../common/topbar.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final catProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Products',
              subtitle: '${provider.totalCount} total products',
              action: ElevatedButton.icon(
                onPressed: () => context.go('/products/add'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
              ),
            ),
            const SizedBox(height: 24),

            // Filters
            ContentCard(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: provider.setSearch,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.cardBorder),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  // Category filter
                  DropdownButton<String>(
                    value: provider.isLoading ? 'all' : (catProvider.allCategories.any((c) => c.id == provider.categoryFilter) ? provider.categoryFilter : 'all'),
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(10),
                    items: [
                      const DropdownMenuItem(
                          value: 'all', child: Text('All Categories')),
                      ...catProvider.allCategories.map((c) =>
                          DropdownMenuItem(
                              value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (v) =>
                        provider.setCategoryFilter(v ?? 'all'),
                  ),
                  // Status filter
                  DropdownButton<String>(
                    value: provider.statusFilter,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(10),
                    items: const [
                      DropdownMenuItem(
                          value: 'all', child: Text('All Status')),
                      DropdownMenuItem(
                          value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                          value: 'inactive', child: Text('Inactive')),
                    ],
                    onChanged: (v) =>
                        provider.setStatusFilter(v ?? 'all'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Table
            Expanded(
              child: ContentCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _ProductTableHeader(),
                    Expanded(
                      child: provider.isLoading
                          ? const LoadingWidget()
                          : provider.products.isEmpty
                              ? const EmptyWidget(
                                  message: 'No products found',
                                  icon: Icons.inventory_2_outlined)
                              : ListView.separated(
                                  itemCount: provider.products.length,
                                  separatorBuilder: (_, __) => const Divider(
                                      height: 1, color: AppColors.cardBorder),
                                  itemBuilder: (ctx, i) {
                                    final p = provider.products[i];
                                    return _ProductRow(
                                      product: p,
                                      onEdit: () => context
                                          .go('/products/${p.id}/edit'),
                                      onView: () => context
                                          .go('/products/${p.id}'),
                                      onDelete: () async {
                                        final ok =
                                            await Helpers.showConfirmDialog(
                                          ctx,
                                          title: 'Delete Product',
                                          message:
                                              'Delete "${p.name}" permanently?',
                                        );
                                        if (ok) provider.deleteProduct(p.id);
                                      },
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: _H('Product')),
          Expanded(flex: 2, child: _H('Category ID')),
          Expanded(child: _H('Price')),
          Expanded(child: _H('Status')),
          SizedBox(width: 100, child: _H('Actions')),
        ],
      ),
    );
  }
}

class _H extends StatelessWidget {
  final String label;
  const _H(this.label);
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary));
}

class _ProductRow extends StatelessWidget {
  final dynamic product;
  final VoidCallback onEdit;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const _ProductRow({
    required this.product,
    required this.onEdit,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imageUrls.isNotEmpty
                      ? Image.network(product.imageUrls[0],
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _PlaceholderImage())
                      : _PlaceholderImage(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(product.categoryId,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              DateFormatter.formatCurrency(product.price),
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: StatusBadge(
                status: product.status ? 'active' : 'inactive'),
          ),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined,
                      size: 18, color: AppColors.primary),
                  onPressed: onView,
                  tooltip: 'View',
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.accent),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: AppColors.error),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.inventory_2_outlined,
          color: AppColors.primary, size: 20),
    );
  }
}
