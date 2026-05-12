import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../core/theme.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  // Sample gallery items - replace with your actual data
  final List<Map<String, dynamic>> _galleryItems = const [
    {
      'id': 1,
      'title': 'Royal Gomesi',
      'imageUrl': 'https://images.unsplash.com/photo-1583391733956-3750e0b4f5b4?w=400',
      'height': 600,
    },
    {
      'id': 2,
      'title': 'Elegant Busuuti',
      'imageUrl': 'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=400',
      'height': 400,
    },
    {
      'id': 3,
      'title': 'Modern Wedding Gown',
      'imageUrl': 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=400',
      'height': 550,
    },
    {
      'id': 4,
      'title': 'Traditional Kanzu',
      'imageUrl': 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400',
      'height': 450,
    },
    {
      'id': 5,
      'title': 'Bridal Accessories',
      'imageUrl': 'https://images.unsplash.com/photo-1617038220319-276d3cfab638?w=400',
      'height': 500,
    },
    {
      'id': 6,
      'title': 'Gomesi Special',
      'imageUrl': 'https://images.unsplash.com/photo-1585937421610-70a00c7e71f6?w=400',
      'height': 380,
    },
    {
      'id': 7,
      'title': 'Wedding Details',
      'imageUrl': 'https://images.unsplash.com/photo-1519741497674-611481863552?w=400',
      'height': 620,
    },
    {
      'id': 8,
      'title': 'Bridal Portrait',
      'imageUrl': 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=400',
      'height': 480,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'EDITORIAL GALLERY',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: MasonryGridView.builder(
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        padding: const EdgeInsets.all(16),
        itemCount: _galleryItems.length,
        itemBuilder: (context, index) {
          final item = _galleryItems[index];
          return GestureDetector(
            onTap: () {
              _showFullImage(context, item['imageUrl'] as String, item['title'] as String);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.network(
                    item['imageUrl'] as String,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: (item['height'] as double) / 2,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: (item['height'] as double) / 2,
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: (item['height'] as double) / 2,
                        color: AppColors.primary.withOpacity(0.05),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Text(
                        item['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.black.withOpacity(0.5),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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