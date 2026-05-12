import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || 
        _phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.register(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        _passwordController.text,
      );
      
      AuthService.setAuth(response['token'], response['user']);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Welcome to Fyn Bridals.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 350,
              width: double.infinity,
              child: Stack(
                children: [
                  Image.network(
                    'https://picsum.photos/seed/bridal_reg/800/600',
                    width: double.infinity, height: 350, fit: BoxFit.cover,
                  ),
                  Container(color: AppColors.primary.withOpacity(0.1)),
                  Positioned(
                    bottom: 30, left: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('THE DIGITAL ATELIER', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70)),
                        Text('Begin Your\nLegacy', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 32)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create Account', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  const Text('Join the house of Fyn Bridals to access bespoke couture consultations.', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () async {
                      final status = await ApiService.diagnosticPing();
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('System Diagnostic'),
                            content: Text(status.toString()),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CLOSE'))
                            ],
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.dvr, size: 14, color: Colors.blueGrey),
                    label: const Text('DIAGNOSE CONNECTION', style: TextStyle(fontSize: 10, color: Colors.blueGrey)),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField('FULL NAME', 'Genevieve Rose', _nameController),
                  _buildTextField('EMAIL ADDRESS', 'atelier@fynbridals.com', _emailController),
                  _buildTextField('PHONE NUMBER', '+1 (555) 000-0000', _phoneController),
                  _buildTextField('PASSWORD', '••••••••••••', _passwordController, isPassword: true),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('REGISTER ACCOUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/login'),
                      child: const Text('ALREADY HAVE AN ACCOUNT? LOGIN', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
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

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, color: Colors.black38)),
          TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black12),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.secondary)),
            ),
          ),
        ],
      ),
    );
  }
}
