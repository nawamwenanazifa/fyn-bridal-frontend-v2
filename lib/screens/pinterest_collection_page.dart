import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PinterestCollectionPage extends StatelessWidget {
  final String categoryName;
  final List<Map<String, dynamic>> products;

  const PinterestCollectionPage({
    super.key,
    required this.categoryName,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBE3),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF6B0020),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
            ],
            title: Text(
              categoryName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(
                          Icons.search,
                          size: 16,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Search ${categoryName.toLowerCase()} styles...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _PinCard(product: products[index]);
            },
          ),
        ),
      ),
    );
  }
}

class _PinCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _PinCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = product['image'];
    final String name = product['name'] ?? '';
    final double price = double.tryParse(product['price'].toString()) ?? 0;

    return GestureDetector(
      onTap: () {
        // Navigate to product detail
        Navigator.pushNamed(context, '/product-detail', arguments: product);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(imageUrl, index: product['id'] ?? 0),
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 7, 9, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B0020),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'UGX ${_formatPrice(price)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B0020),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl, {required int index}) {
    final heights = [130.0, 90.0, 160.0, 110.0, 140.0, 85.0, 120.0, 100.0];
    final h = heights[index % heights.length];

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: h,
        color: const Color(0xFFEDE8DF),
        child: const Center(
          child: Icon(Icons.checkroom, color: Color(0xFFBBAA99), size: 32),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: h,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF6B0020),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        height: h,
        color: const Color(0xFFEDE8DF),
        child: const Center(
          child: Icon(Icons.broken_image, color: Color(0xFFBBAA99)),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}