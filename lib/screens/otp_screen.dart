import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('IDENTITY VERIFICATION', style: Theme.of(context).textTheme.labelSmall), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text('Confirm Your Presence', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32)),
            const SizedBox(height: 16),
            const Text('A four-digit code has been sent to your registered atelier account.', textAlign: TextAlign.center),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => _buildOTPBox()),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 60)),
              onPressed: () => context.go('/home'),
              child: const Text('VERIFY ACCESS', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOTPBox() {
    return Container(
      width: 60, height: 80,
      decoration: const BoxDecoration(color: AppColors.surfaceLow, border: Border(bottom: BorderSide(color: AppColors.primary, width: 2))),
      child: const TextField(
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(counterText: "", border: InputBorder.none),
      ),
    );
  }
}
