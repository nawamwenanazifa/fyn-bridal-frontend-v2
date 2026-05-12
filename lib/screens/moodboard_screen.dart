import 'package:flutter/material.dart';

class MoodboardScreen extends StatelessWidget {
  const MoodboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      appBar: AppBar(title: const Text('Creative Moodboard')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Your Inspiration',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF570013)),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildMoodItem('https://picsum.photos/seed/m1/200/200'),
              _buildMoodItem('https://picsum.photos/seed/m2/200/200'),
              _buildMoodItem('https://picsum.photos/seed/m3/200/200'),
              _buildMoodItem('https://picsum.photos/seed/m4/200/200'),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: const Icon(Icons.add, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodItem(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
    );
  }
}
