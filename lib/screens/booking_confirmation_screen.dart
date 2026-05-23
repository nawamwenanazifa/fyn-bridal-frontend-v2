import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../services/order_service.dart';
import '../services/error_handler.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;

  const BookingConfirmationScreen({super.key, required this.bookingDetails});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isProcessing = false;

  String _extractDate() {
    final raw = widget.bookingDetails['booking_date'] ?? '';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      final parts = raw.split(' ');
      return parts.isNotEmpty ? parts[0] : '';
    }
  }

  String _extractTime() {
    final raw = widget.bookingDetails['booking_date'] ?? '';
    try {
      final dt = DateTime.parse(raw);
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      final parts = raw.split(' ');
      return parts.length > 1 ? parts[1] : '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalAmount = _calculateTotalAmount();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: SafeArea(
        child: SingleChildScrollView(          // FIXED: wrap in scroll to prevent overflow
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 60),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'APPOINTMENT CONFIRMED',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Your fitting session at FYN Bridals has been successfully scheduled. We look forward to seeing you!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black.withOpacity(0.5), height: 1.6),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('SERVICE', widget.bookingDetails['service'] ?? 'Consultation'),
                      const Divider(height: 32),
                      _buildDetailRow('DATE', _extractDate()),
                      const Divider(height: 32),
                      _buildDetailRow('TIME', _extractTime()),
                      const Divider(height: 32),
                      _buildDetailRow('REFERENCE', '#${widget.bookingDetails['id'] ?? 'BK-001'}'),
                      const Divider(height: 32),
                      _buildDetailRow('TOTAL AMOUNT', 'UGX ${totalAmount.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : () => _proceedToCheckout(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isProcessing
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'PROCEED TO CHECKOUT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => context.go('/home'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'BACK TO HOME',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.push('/bookings'),
                        child: const Text(
                          'VIEW MY APPOINTMENTS',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateTotalAmount() {
    if (widget.bookingDetails['items'] != null) {
      final items = widget.bookingDetails['items'] as List;
      double subtotal = items.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']));
      return subtotal + 15000;
    }
    return 150000;
  }

  Future<void> _proceedToCheckout() async {
    final bookingId = widget.bookingDetails['id'];
    final totalAmount = _calculateTotalAmount();

    if (bookingId == null) {
      ErrorHandler.showError(context, 'Booking information not found');
      return;
    }

    setState(() => _isProcessing = true);

    if (mounted) {
      context.push('/checkout/$bookingId/$totalAmount');
    }

    setState(() => _isProcessing = false);
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black26,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}