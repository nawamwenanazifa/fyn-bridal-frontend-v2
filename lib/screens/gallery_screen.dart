import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../core/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────
class GalleryItem {
  final int id;
  final String title;
  final String imagePath;
  final int height;
  final String category;

  const GalleryItem({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.height,
    required this.category,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Gallery items — category must be one of:
// 'Gomesi' | 'Busuuti' | 'Kanzu' | 'Wedding Gowns' | 'Accessories'
// ─────────────────────────────────────────────────────────────────────────────
const List<GalleryItem> _allItems = [
  GalleryItem(
    id: 1,
    title: 'Royal Gomesi',
    imagePath: 'assets/images/gomesi.jpeg',
    height: 600,
    category: 'Gomesi',
  ),
  GalleryItem(
    id: 2,
    title: 'Classic Busuuti',
    imagePath: 'assets/images/changing dress.jpeg',
    height: 500,
    category: 'Busuuti',
  ),
  GalleryItem(
    id: 3,
    title: 'Traditional Gomesi',
    imagePath: 'assets/images/onboard1.png',
    height: 550,
    category: 'Gomesi',
  ),
  GalleryItem(
    id: 4,
    title: 'Elegant Kanzu',
    imagePath: 'assets/images/onboard2.png',
    height: 450,
    category: 'Kanzu',
  ),
  GalleryItem(
    id: 5,
    title: 'Bridal Gown',
    imagePath: 'assets/images/onboard3.png',
    height: 500,
    category: 'Wedding Gowns',
  ),
  // ↑ Add more items here — just set category to one of the five above
];

// Fixed category order — matches the shop screen exactly
const List<String> _categories = [
  'All',
  'Gomesi',
  'Busuuti',
  'Kanzu',
  'Wedding Gowns',
  'Accessories',
];

// ─────────────────────────────────────────────────────────────────────────────
// Gallery Screen
// ─────────────────────────────────────────────────────────────────────────────
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _selectedCategory = 'All';

  List<GalleryItem> get _filtered {
    if (_selectedCategory == 'All') return _allItems;
    return _allItems.where((i) => i.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gallery'),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Category chips ───────────────────────────────────────────────
          _CategoryBar(
            categories: _categories,
            selected: _selectedCategory,
            onSelected: (cat) => setState(() => _selectedCategory = cat),
          ),

          // ── Grid / empty state ───────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_search_rounded,
                            size: 60,
                            color: AppColors.primary.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text(
                          'No items in "$_selectedCategory" yet',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : MasonryGridView.builder(
                    gridDelegate:
                        const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _GalleryCard(
                        item: item,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GalleryDetailScreen(
                              imagePath: item.imagePath,
                              title: item.title,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scrollable category chip bar
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryBar extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const _CategoryBar({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            final isSelected = cat == selected;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelected(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual gallery card
// ─────────────────────────────────────────────────────────────────────────────
class _GalleryCard extends StatelessWidget {
  final GalleryItem item;
  final VoidCallback onTap;

  const _GalleryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.asset(
              item.imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: item.height / 2,
              errorBuilder: (context, error, stackTrace) => Container(
                height: item.height / 2,
                color: AppColors.primary.withOpacity(0.1),
                child: const Center(
                    child: Icon(Icons.image_not_supported, size: 40)),
              ),
            ),
            // Category badge
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            // Title overlay
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
                  item.title,
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
  final int _commentCount = 34;
  bool _isSaved = false;

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _toggleSave() {
    setState(() => _isSaved = !_isSaved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSaved
            ? 'Saved to your collection!'
            : 'Removed from collection'),
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
          duration: Duration(seconds: 1)),
    );
  }

  void _showMore() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
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
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            _MoreOption(
                icon: Icons.download_rounded,
                label: 'Download image',
                onTap: () => Navigator.pop(context)),
            _MoreOption(
                icon: Icons.report_outlined,
                label: 'Report',
                onTap: () => Navigator.pop(context)),
            _MoreOption(
                icon: Icons.block,
                label: 'Hide this',
                onTap: () => Navigator.pop(context)),
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8)),
                    child: IconButton(
                      icon: const Icon(Icons.search_rounded,
                          color: Colors.white, size: 22),
                      tooltip: 'Visual search',
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                child: Center(
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                          child: Icon(Icons.broken_image,
                              size: 60, color: Colors.white38)),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person,
                              color: Colors.white, size: 18),
                        ),
                        SizedBox(width: 8),
                        Text('Karma',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    child: Text(widget.title,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ActionBtn(
                        icon: _isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        label: '$_likeCount',
                        color:
                            _isLiked ? Colors.redAccent : Colors.white,
                        onTap: _toggleLike,
                      ),
                      _ActionBtn(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: '$_commentCount',
                        color: Colors.white,
                        onTap: _openComments,
                      ),
                      _ActionBtn(
                        icon: Icons.reply_rounded,
                        label: 'Share',
                        color: Colors.white,
                        onTap: _share,
                        flipHorizontal: true,
                      ),
                      _ActionBtn(
                        icon: Icons.more_horiz_rounded,
                        label: '',
                        color: Colors.white,
                        onTap: _showMore,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _toggleSave,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: _isSaved
                                ? Colors.grey[700]
                                : const Color(0xFFE60023),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            _isSaved ? 'Saved' : 'Save',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
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

class _MoreOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MoreOption(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      onTap: onTap,
    );
  }
}

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
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            const Text('Comments',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _comments.length,
                itemBuilder: (_, i) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AppColors.primary.withOpacity(0.15),
                    child: const Icon(Icons.person,
                        color: AppColors.primary, size: 18),
                  ),
                  title: Text(_comments[i],
                      style: const TextStyle(fontSize: 13)),
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
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
                    child: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
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