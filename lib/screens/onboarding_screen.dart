import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Updated image paths to use PNG files
  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Discover Traditional Elegance',
      description: 'Explore our exclusive collection of cultural attire for weddings, introductions, and special ceremonies.',
      imageAsset: 'assets/images/onboard1.png',  // Changed from .jpg to .png
      primaryButtonText: 'Next',
      showSkip: true,
    ),
    OnboardingData(
      title: 'Perfect Fit Guaranteed',
      description: 'Get custom-tailored traditional wear with precise measurements for the perfect cultural celebration look.',
      imageAsset: 'assets/images/onboard2.png',  // Changed from .jpg to .png
      primaryButtonText: 'Next',
      showSkip: true,
    ),
    OnboardingData(
      title: 'Easy Booking & Delivery',
      description: 'Seamlessly book your favorite traditional wear and get it delivered ready for your special occasion.',
      imageAsset: 'assets/images/onboard3.png',  // Already .png
      primaryButtonText: 'Get Started',
      showSkip: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Navigation - Skip Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_pages[_currentPage].showSkip)
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text(
                        'SKIP',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Page Indicator Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 30.0 : 8.0,
                height: 3.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: _currentPage == index 
                      ? AppColors.primary 
                      : AppColors.onSurfaceVariant.withOpacity(0.3),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return OnboardingPage(
                  data: _pages[index],
                  isLastPage: index == _pages.length - 1,
                  pageController: _pageController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imageAsset;
  final String primaryButtonText;
  final bool showSkip;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.primaryButtonText,
    this.showSkip = false,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final bool isLastPage;
  final PageController pageController;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.isLastPage,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Hero Image
            Container(
              height: 380,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  data.imageAsset,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading: ${data.imageAsset}');
                    return Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported, size: 50),
                            SizedBox(height: 8),
                            Text('Image not found'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              data.description,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isLastPage) {
                    context.go('/login');
                  } else {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  data.primaryButtonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}