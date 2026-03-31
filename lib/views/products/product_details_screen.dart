import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../common/topbar.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final product = provider.products.firstWhere(
      (p) => p.id == productId,
      orElse: () => ProductModel(
        id: productId,
        name: '',
        description: '',
        price: 0,
        categoryId: '',
        imageUrls: [],
        patientCount: 0,
        dailyPatientCount: 0,
        experience: 0,
        rating: 0,
        reviewCount: 0,
        bookedCount: 0,
        status: false,
        attributes: [],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(onPressed: () => context.go('/products'), icon: const Icon(Icons.arrow_back)),
                const SizedBox(width: 8),
                const Text('Product Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => context.go('/products/$productId/edit'),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit Product'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 700;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _ProductInfoCard(product: product)),
                    const SizedBox(width: 16),
                    Expanded(child: _ProductStatsCard(product: product)),
                  ],
                );
              }
              return Column(
                children: [
                  _ProductInfoCard(product: product),
                  const SizedBox(height: 16),
                  _ProductStatsCard(product: product),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ProductInfoCard extends StatelessWidget {
  final ProductModel product;
  const _ProductInfoCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      title: 'Product Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrls[0],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.inventory_2_outlined, size: 60, color: AppColors.primary),
                ),
              ),
            )
          else
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.inventory_2_outlined, size: 60, color: AppColors.primary)),
            ),
          const SizedBox(height: 20),
          Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(product.categoryId,
                    style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: product.status ? 'active' : 'inactive'),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(product.description, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
          const Divider(height: 32, color: AppColors.cardBorder),
          _DetailRow(label: 'Product ID', value: product.id),
          const SizedBox(height: 8),
          _DetailRow(label: 'Experience', value: '${product.experience} years'),
        ],
      ),
    );
  }
}

class _ProductStatsCard extends StatelessWidget {
  final ProductModel product;
  const _ProductStatsCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ContentCard(
          child: Column(
            children: [
              _StatTile(
                icon: Icons.attach_money,
                color: AppColors.success,
                label: 'Price',
                value: '\$${product.price}',
              ),
              const Divider(height: 24, color: AppColors.cardBorder),
              _StatTile(
                icon: Icons.people_outline,
                color: AppColors.primary,
                label: 'Total Patients',
                value: '${product.patientCount}',
              ),
              const Divider(height: 24, color: AppColors.cardBorder),
              _StatTile(
                icon: Icons.star_border,
                color: Colors.orange,
                label: 'Rating',
                value: '${product.rating} (${product.reviewCount} reviews)',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ContentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quick Actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/products/${ product.id}/edit'),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit Product'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final provider = context.read<ProductProvider>();
                    final ok = await Helpers.showConfirmDialog(
                      context,
                      title: 'Delete Product',
                      message: 'Delete "${product.name}" permanently?',
                    );
                    if (ok && context.mounted) {
                      await provider.deleteProduct(product.id);
                      context.go('/products');
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete Product'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _StatTile({required this.icon, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label:', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
