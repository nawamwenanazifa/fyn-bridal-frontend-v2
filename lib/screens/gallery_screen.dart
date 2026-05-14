import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../core/theme.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> galleryItems = [
      {
        'id': 1,
        'title': 'Royal Gomesi',
        'imagePath': 'assets/images/gomesi.jpeg',
        'height': 600,
      },
      {
        'id': 2,
        'title': 'Changing Dress',
        'imagePath': 'assets/images/changing dress.jpeg',
        'height': 500,
      },
      {
        'id': 3,
        'title': 'Traditional Gomesi',
        'imagePath': 'assets/images/onboard1.png',
        'height': 550,
      },
      {
        'id': 4,
        'title': 'Elegant Design',
        'imagePath': 'assets/images/onboard2.png',
        'height': 450,
      },
      {
        'id': 5,
        'title': 'Modern Collection',
        'imagePath': 'assets/images/onboard3.png',
        'height': 500,
      },
    ];

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
        itemCount: galleryItems.length,
        itemBuilder: (context, index) {
          final item = galleryItems[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GalleryDetailScreen(
                    imagePath: item['imagePath'] as String,
                    title: item['title'] as String,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.asset(
                    item['imagePath'] as String,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: (item['height'] as int) / 2,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: (item['height'] as int) / 2,
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 40),
                      ),
                    ),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen detail page (Pinterest-style)
// ─────────────────────────────────────────────────────────────────────────────
class GalleryDetailScreen extends StatefulWidget {
  final String imagePath;
  final String title;

  const GalleryDetailScreen({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  State<GalleryDetailScreen> createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends State<GalleryDetailScreen> {
  bool _isLiked = false;
  int _likeCount = 128;
  int _commentCount = 34;
  bool _isSaved = false;

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSaved ? 'Saved to your collection!' : 'Removed from collection'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(title: widget.title),
    );
  }

  void _share() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share link copied!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showMore() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _MoreOption(icon: Icons.download_rounded, label: 'Download image', onTap: () => Navigator.pop(context)),
            _MoreOption(icon: Icons.report_outlined, label: 'Report', onTap: () => Navigator.pop(context)),
            _MoreOption(icon: Icons.block, label: 'Hide this', onTap: () => Navigator.pop(context)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  // Lens / visual search button (top-right corner of image, Pinterest style)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
                      tooltip: 'Visual search',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Visual search coming soon!'), duration: Duration(seconds: 1)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Image ────────────────────────────────────────────────────────
            Expanded(
              child: InteractiveViewer(
                child: Center(
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 60, color: Colors.white38),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom action bar ─────────────────────────────────────────────
            Container(
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary,
                          child: const Icon(Icons.person, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Karma',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Caption
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(
                      widget.title,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Action buttons row
                  Row(
                    children: [
                      // Like
                      _ActionBtn(
                        icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        label: '$_likeCount',
                        color: _isLiked ? Colors.redAccent : Colors.white,
                        onTap: _toggleLike,
                      ),
                      // Comment
                      _ActionBtn(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: '$_commentCount',
                        color: Colors.white,
                        onTap: _openComments,
                      ),
                      // Share
                      _ActionBtn(
                        icon: Icons.reply_rounded,
                        label: 'Share',
                        color: Colors.white,
                        onTap: _share,
                        flipHorizontal: true,
                      ),
                      // More
                      _ActionBtn(
                        icon: Icons.more_horiz_rounded,
                        label: '',
                        color: Colors.white,
                        onTap: _showMore,
                      ),

                      const Spacer(),

                      // Save button (Pinterest red)
                      GestureDetector(
                        onTap: _toggleSave,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: _isSaved ? Colors.grey[700] : const Color(0xFFE60023),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            _isSaved ? 'Saved' : 'Save',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable action button widget
// ─────────────────────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool flipHorizontal;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.flipHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(icon, color: color, size: 24);
    if (flipHorizontal) {
      iconWidget = Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(3.14159),
        child: iconWidget,
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            if (label.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: color, fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// More options list tile
// ─────────────────────────────────────────────────────────────────────────────
class _MoreOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MoreOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Comments bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _CommentsSheet extends StatefulWidget {
  final String title;
  const _CommentsSheet({required this.title});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _comments = [
    'This is absolutely gorgeous! 😍',
    'Where can I get this?',
    'ممكن فيديو لطريقة تفصيله ؟',
  ];

  void _addComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.add(text);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _comments.length,
                itemBuilder: (_, i) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Icon(Icons.person, color: AppColors.primary, size: 18),
                  ),
                  title: Text(_comments[i], style: const TextStyle(fontSize: 13)),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 8,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Add a comment…',
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _addComment,
                    child: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}