import 'package:flutter/material.dart';

class LookbookScreen extends StatelessWidget {
  const LookbookScreen({super.key});

  final List<Map<String, String>> looks = const [
    {'title': 'Silk Minimalist', 'img': 'https://picsum.photos/seed/silk/400/600'},
    {'title': 'Lace Victorian', 'img': 'https://picsum.photos/seed/lace/400/500'},
    {'title': 'Modern Tulle', 'img': 'https://picsum.photos/seed/tulle/400/700'},
    {'title': 'Boho Chic', 'img': 'https://picsum.photos/seed/boho/400/400'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      appBar: AppBar(
        title: const Text('Couture Lookbook', style: TextStyle(color: Color(0xFF570013))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: looks.length,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(looks[index]['img']!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                looks[index]['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF570013)),
              ),
            ],
          );
        },
      ),
    );
  }
}
