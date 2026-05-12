import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EDITORIAL GALLERY', style: Theme.of(context).textTheme.labelSmall), centerTitle: true),
      body: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => context.push('/product-detail'),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network('https://picsum.photos/seed/bridal_$index/400/${index.isEven ? 600 : 400}', fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
