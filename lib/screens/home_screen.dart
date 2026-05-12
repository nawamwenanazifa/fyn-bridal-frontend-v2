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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _HomeContent(onBrowse: () => _onItemTapped(1)),
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
  final VoidCallback onBrowse;

  const _HomeContent({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section
          Container(
            height: 600,
            width: double.infinity,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&q=80&w=1200'),
                fit: BoxFit.cover,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.primary.withOpacity(0.8)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
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
                        onPressed: onBrowse, 
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
}