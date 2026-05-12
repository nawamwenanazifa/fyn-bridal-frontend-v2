import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryContainer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('DIGITAL ATELIER', style: TextStyle(color: Colors.white70, letterSpacing: 4, fontSize: 12)),
            const SizedBox(height: 12),
            Text(
              'FYN BRIDALS', 
              style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 48),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
