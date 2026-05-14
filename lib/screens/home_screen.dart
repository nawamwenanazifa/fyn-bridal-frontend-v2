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
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _HomeContent(pageController: _pageController),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'GALLERY'),
          BottomNavigationBarItem(icon: Icon(Icons.category_outlined), activeIcon: Icon(Icons.category), label: 'CATEGORIES'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), 
            activeIcon: Icon(Icons.person), 
            label: 'PROFILE'
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final PageController pageController;

  const _HomeContent({required this.pageController});

  final List<String> _heroImages = const [
    'assets/images/gomesi.jpeg',
    'assets/images/changing dress.jpeg',
    'assets/images/onboard3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section with Local Images
          SizedBox(
            height: 600,
            width: double.infinity,
            child: Stack(
              children: [
                // Background Image Carousel
                PageView.builder(
                  controller: pageController,
                  itemCount: _heroImages.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      _heroImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      },
                    );
                  },
                ),
                // Dark Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.primary.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
                // Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    // Top Icons
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person_outline, color: Colors.white, size: 30),
                            onPressed: () {
                              if (AuthService.isAuthenticated) {
                                context.push('/profile');
                              } else {
                                context.push('/login');
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.message_outlined, color: Colors.white, size: 28),
                            onPressed: () => context.push('/messages'),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Hero Text
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to\nFyn Bridals', 
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Colors.white, 
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary, 
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                            ), 
                            onPressed: () {
                              context.push('/gallery');
                            }, 
                            child: const Text(
                              'BROWSE OUR LATEST DESIGNS', 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Quick Access to Services
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR ATELIER SERVICES', 
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildQuickAction(
                      context,
                      'BOOKINGS',
                      Icons.calendar_today,
                      '/bookings',
                    ),
                    const SizedBox(width: 16),
                    _buildQuickAction(
                      context,
                      'MESSAGES',
                      Icons.message_outlined,
                      '/messages',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildQuickAction(
                      context,
                      'PROFILE',
                      Icons.person_outline,
                      '/profile',
                    ),
                    const SizedBox(width: 16),
                    _buildQuickAction(
                      context,
                      'GALLERY',
                      Icons.photo_library_outlined,
                      '/gallery',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildQuickAction(
                      context,
                      'MOODBOARD',
                      Icons.palette_outlined,
                      '/moodboard',
                    ),
                    const SizedBox(width: 16),
                    _buildQuickAction(
                      context,
                      'LOOKBOOK',
                      Icons.auto_stories_outlined,
                      '/lookbook',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Featured Categories Section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FEATURED COLLECTIONS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildFeaturedCard(
                      context,
                      'Gomesi',
                      'assets/images/gomesi.jpeg',
                      '/collection',
                      'Gomesi',
                    ),
                    const SizedBox(width: 16),
                    _buildFeaturedCard(
                      context,
                      'Changing Dresses',
                      'assets/images/changing dress.jpeg',
                      '/collection',
                      'ChangingDresses',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, String route) {
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                title, 
                style: const TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, String title, String imagePath, String route, String category) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.push(route, extra: category);
        },
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}