import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/permission_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      topTitle: 'THE REGAL EDITORIAL',
      subtitle: 'ATELIER SERVICES',
      title: 'Perfect Fit\nGuaranteed.',
      description: 'Get custom-tailored traditional wear with precise measurements for the perfect cultural celebration look. Our digital atelier ensures that heritage meets precision.',
      imageUrl: 'https://images.unsplash.com/photo-1594553924364-c81768393248?auto=format&fit=crop&q=80&w=800',
      primaryButtonText: 'START MEASUREMENT',
      secondaryButtonText: 'VIEW LOOKBOOK',
      showCloseOnLeft: true,
      features: [
        OnboardingFeature(title: 'Bespoke Design', description: 'Celebrate with made-to-measure traditional wear tailored to your heritage garment.'),
        OnboardingFeature(title: 'Cultural Authenticity', description: 'We honor traditions with meticulously sourced fabrics and time-tested weaving techniques.', isHighlighted: true),
        OnboardingFeature(title: 'Global Delivery', description: 'White-glove delivery to over 120 countries, ensuring your attire arrives in pristine condition.'),
      ],
      aiAnalysisText: '32-Point AI Analysis',
      aiAnalysisSubtext: 'Precision fit from 3D body scanning',
    ),
    OnboardingData(
      topTitle: 'FYN BRIDALS',
      subtitle: 'HERITAGE REFINED',
      title: 'Discover\nTraditional\nElegance.',
      description: 'Explore our exclusive collection of cultural attire for weddings, introductions, and special ceremonies. Crafted with the legacy of a digital atelier.',
      imageUrl: 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?auto=format&fit=crop&q=80&w=800',
      secondaryImageUrl: 'https://images.unsplash.com/photo-1595910358723-57448276b357?auto=format&fit=crop&q=80&w=400',
      primaryButtonText: 'BEGIN YOUR JOURNEY',
      secondaryButtonText: 'OUR COLLECTION',
      showSkip: true,
    ),
    OnboardingData(
      topTitle: 'Fyn Bridals',
      subtitle: 'HERITAGE REFINED',
      title: 'Easy Booking\n& Delivery.',
      description: 'Seamlessly book your favorite traditional wear and get it delivered ready for your special occasion. Our digital atelier brings the heritage of craftsmanship directly to your doorstep.',
      imageUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&q=80&w=800',
      primaryButtonText: 'GET STARTED',
      secondaryButtonText: 'Explore Collection',
      showCloseOnRight: true,
      showBottomNav: true,
      features: [
        OnboardingFeature(title: 'Curated Quality', description: 'Each piece is hand-selected by our atelier experts for impeccable finish.'),
        OnboardingFeature(title: 'Pristine Delivery', description: 'Sealed and sanitized packaging to ensure your wear arrives in gallery condition.'),
        OnboardingFeature(title: 'Flexible Booking', description: 'Secure your date months in advance with our seamless reservation system.'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      body: PageView.builder(
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
            currentPage: index,
            totalPages: _pages.length,
          );
        },
      ),
    );
  }
}

class OnboardingData {
  final String topTitle;
  final String subtitle;
  final String title;
  final String description;
  final String imageUrl;
  final String? secondaryImageUrl;
  final String primaryButtonText;
  final String secondaryButtonText;
  final List<OnboardingFeature>? features;
  final bool showSkip;
  final bool showCloseOnLeft;
  final bool showCloseOnRight;
  final bool showBottomNav;
  final String? aiAnalysisText;
  final String? aiAnalysisSubtext;

  OnboardingData({
    required this.topTitle,
    required this.subtitle,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.secondaryImageUrl,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    this.features,
    this.showSkip = false,
    this.showCloseOnLeft = false,
    this.showCloseOnRight = false,
    this.showBottomNav = false,
    this.aiAnalysisText,
    this.aiAnalysisSubtext,
  });
}

class OnboardingFeature {
  final String title;
  final String description;
  final bool isHighlighted;

  OnboardingFeature({
    required this.title, 
    required this.description,
    this.isHighlighted = false,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final bool isLastPage;
  final PageController pageController;
  final int currentPage;
  final int totalPages;

  const OnboardingPage({
    super.key, 
    required this.data, 
    required this.isLastPage,
    required this.pageController,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Navigation
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                if (data.showCloseOnLeft)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.black54),
                    onPressed: () => context.go('/login'),
                  ),
                Expanded(
                  child: Center(
                    child: Text(
                      data.topTitle,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                if (data.showSkip)
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        color: Color(0xFF800020),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  )
                else if (data.showCloseOnRight)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.black54),
                    onPressed: () => context.go('/login'),
                  )
                else
                  const SizedBox(width: 40),
              ],
            ),
          ),
        ),
        // Page Indicator
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
              (index) => _buildDot(index),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Hero Image Area
                if (data.secondaryImageUrl != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 400,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            image: DecorationImage(
                              image: NetworkImage(data.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -40,
                          left: 20,
                          child: Container(
                            height: 180,
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage(data.secondaryImageUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    height: 400,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: NetworkImage(data.imageUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {},
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (data.aiAnalysisText != null)
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_awesome, size: 12, color: Color(0xFF800020)),
                                  const SizedBox(width: 8),
                                  Text(
                                    data.aiAnalysisText!,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 60), // Increased spacing
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.subtitle,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.black26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.title,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF800020),
                          fontFamily: 'Serif',
                           height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        data.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // AI Analysis Full Card (if present)
                      if (data.aiAnalysisSubtext != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black.withOpacity(0.05)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.memory, color: Color(0xFF800020)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data.aiAnalysisText!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text(data.aiAnalysisSubtext!, style: const TextStyle(fontSize: 10, color: Colors.black38)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (data.primaryButtonText == 'START MEASUREMENT') {
                              PermissionService.requestCamera();
                              // After permission, maybe move to next page anyway for demo
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 300), 
                                curve: Curves.easeInOut
                              );
                            } else if (isLastPage) {
                              context.go('/login');
                            } else {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 300), 
                                curve: Curves.easeInOut
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF800020),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: Text(
                            data.primaryButtonText,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(
                            data.secondaryButtonText.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 10,
                              letterSpacing: 2,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Features
                      if (data.features != null) ...[
                        ...data.features!.map((feature) => _buildFeatureItem(feature)),
                      ],
                      // Footer
                      if (isLastPage) ...[
                        const SizedBox(height: 60),
                        const Center(
                          child: Text(
                            'TRUSTED BY GLOBAL ATELIERS',
                            style: TextStyle(fontSize: 9, letterSpacing: 3, color: Colors.black26, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.center,
                          children: [
                            Text('VOGUE', style: TextStyle(fontSize: 12, color: Colors.black12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            Text('BAZAAR', style: TextStyle(fontSize: 12, color: Colors.black12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            Text('ELLE', style: TextStyle(fontSize: 12, color: Colors.black12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          ],
                        ),
                        const SizedBox(height: 80),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(OnboardingFeature feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: feature.isHighlighted ? const EdgeInsets.all(24) : EdgeInsets.zero,
      decoration: feature.isHighlighted ? BoxDecoration(
        color: const Color(0xFF800020),
        borderRadius: BorderRadius.circular(16),
      ) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome, 
                size: 16, 
                color: feature.isHighlighted ? Colors.white : const Color(0xFF800020)
              ),
              const SizedBox(width: 12),
              Text(
                feature.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: feature.isHighlighted ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            feature.description,
            style: TextStyle(
              fontSize: 12, 
              color: feature.isHighlighted ? Colors.white70 : Colors.black54, 
              height: 1.6
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 2,
      width: 30,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: currentPage == index ? const Color(0xFF800020) : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

