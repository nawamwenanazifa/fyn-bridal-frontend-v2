import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/gallery_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const _HomeContent(),
      const GalleryScreen(),
      const CategoriesScreen(),
      AuthService.isAuthenticated ? const ProfileScreen() : const LoginScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'gallery'),
          BottomNavigationBarItem(icon: Icon(Icons.category_outlined), activeIcon: Icon(Icons.category), label: 'categories'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'profile'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final List<String> _heroImages = const [
    'assets/images/gomesi.jpeg',
    'assets/images/changing dress.jpeg',
    'assets/images/onboard3.png',
  ];

  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 1.0);
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (_currentPage != page && page >= 0 && page < _heroImages.length) {
        setState(() => _currentPage = page);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section
          SizedBox(
            height: 450,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full-bleed image carousel
                PageView.builder(
                  controller: _pageController,
                  itemCount: _heroImages.length,
                  onPageChanged: (index) {
                    if (index >= 0 && index < _heroImages.length) {
                      setState(() => _currentPage = index);
                    }
                  },
                  itemBuilder: (context, index) {
                    if (index >= _heroImages.length) return const SizedBox();
                    return Image.asset(
                      _heroImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withOpacity(0.2),
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 40, color: Colors.white54),
                        ),
                      ),
                    );
                  },
                ),

                // Dark gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        AppColors.primary.withOpacity(0.55),
                        AppColors.primary.withOpacity(0.90),
                      ],
                      stops: const [0.0, 0.50, 0.75, 1.0],
                    ),
                  ),
                ),

                // Top bar icons
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _iconButton(Icons.person_outline, () {
                            if (AuthService.isAuthenticated) {
                              context.push('/profile');
                            } else {
                              context.push('/login');
                            }
                          }),
                          const SizedBox(width: 8),
                          _iconButton(Icons.message_outlined,
                              () => context.push('/messages')),
                        ],
                      ),
                    ),
                  ),
                ),

                // Page indicator dots
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _heroImages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentPage == i ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? Colors.white
                              : Colors.white54,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),

                // Hero text + CTA at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome to\nFyn Bridals',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0)),
                            elevation: 0,
                          ),
                          onPressed: () => context.push('/gallery'),
                          child: const Text(
                            'BROWSE OUR LATEST DESIGNS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quick Access Services
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR ATELIER SERVICES',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  _buildQuickAction(context, 'BOOKINGS', Icons.calendar_today, '/bookings'),
                  const SizedBox(width: 12),
                  _buildQuickAction(context, 'MESSAGES', Icons.message_outlined, '/messages'),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _buildQuickAction(context, 'PROFILE', Icons.person_outline, '/profile'),
                  const SizedBox(width: 12),
                  _buildQuickAction(context, 'GALLERY', Icons.photo_library_outlined, '/gallery'),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _buildQuickAction(context, 'MOODBOARD', Icons.palette_outlined, '/moodboard'),
                  const SizedBox(width: 12),
                  _buildQuickAction(context, 'LOOKBOOK', Icons.auto_stories_outlined, '/lookbook'),
                ]),
              ],
            ),
          ),

          // Featured Collections
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FEATURED COLLECTIONS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  _buildFeaturedCard(context, 'Gomesi',
                      'assets/images/gomesi.jpeg', '/collection', 'Gomesi'),
                  const SizedBox(width: 12),
                  _buildFeaturedCard(
                      context,
                      'Changing Dresses',
                      'assets/images/changing dress.jpeg',
                      '/collection',
                      'ChangingDresses'),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black.withOpacity(0.3),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
      BuildContext context, String title, IconData icon, String route) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (route == '/profile' && !AuthService.isAuthenticated) {
            context.push('/login');
          } else {
            context.push(route);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, String title,
      String imagePath, String route, String category) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(route, extra: category),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}