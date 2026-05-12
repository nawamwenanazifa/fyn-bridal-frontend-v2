import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get product data from GoRouter extra
    final Map<String, dynamic>? args = GoRouterState.of(context).extra as Map<String, dynamic>?;

    final Map<String, dynamic> product = args ?? {
      'name': 'Royal Silk Gomesi',
      'category': 'GOMESI HERITAGE',
      'price': 'UGX 1,200,000',
      'description': 'A masterpiece of traditional craftsmanship, this Royal Silk Gomesi features intricate hand-stitched embroidery and premium silk fabric sourced from the finest looms. Designed for the modern bride who honors her heritage.',
      'image': 'https://picsum.photos/seed/bridal_detail/800/1200',
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 500,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                product['image'] ?? 'https://picsum.photos/seed/bridal_detail/800/1200',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
              ),
            ),
            leading: IconButton(
              icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.heart, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(LucideIcons.share2, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (product['category'] ?? 'HERITAGE').toString().toUpperCase(),
                    style: const TextStyle(
                      letterSpacing: 2,
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['name'] ?? 'Untitled Piece',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product['price'] ?? 'Price on Request',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'THE DESIGN STORY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product['description'] ?? 'No description available for this bespoke piece.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Divider(color: Colors.black12),
                  const SizedBox(height: 24),
                  _buildFeatureRow(LucideIcons.scissors, 'Hand-stitched Embroidery'),
                  _buildFeatureRow(LucideIcons.gem, 'Premium Silk Fabric'),
                  _buildFeatureRow(LucideIcons.clock, '4-6 Weeks Production'),
                  const SizedBox(height: 120), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => context.push('/booking-form', extra: product),
                child: const Text(
                  'BOOK A FITTING',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(LucideIcons.messageCircle, color: AppColors.primary),
                onPressed: () => context.push('/chat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
