import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RECOVER ACCESS', style: Theme.of(context).textTheme.labelSmall),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 16),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Forgot Password?', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32)),
            const SizedBox(height: 16),
            const Text(
              'Enter your registered email address below. We will send you instructions to reset your secure atelier credentials.',
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 48),
            _buildTextField('EMAIL ADDRESS', 'your.name@atelier.com', context),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                onPressed: () {
                  // Show success dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Instructions Sent'),
                      content: const Text('Please check your inbox for the password recovery link.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            context.pop(); // Close dialog
                            context.pop(); // Go back to login
                          },
                          child: const Text('BACK TO LOGIN', style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('SEND RECOVERY LINK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, color: Colors.black38)),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black12),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.secondary)),
          ),
        ),
      ],
    );
  }
}
