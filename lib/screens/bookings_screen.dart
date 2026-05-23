import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late Future<List<dynamic>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = ApiService.getBookings(AuthService.token ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MY APPOINTMENTS', 
          style: Theme.of(context).textTheme.labelSmall,
        ), 
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No appointments found'));
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              // Fix: use service_type instead of service
              final serviceName = booking['service_type'] ?? booking['service'] ?? 'Consultation';
              final bookingDate = booking['booking_date'] ?? 'No date';
              final status = booking['status'] ?? 'upcoming';
              
              return _buildBookingCard(serviceName, bookingDate, status);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/booking-form'),
        backgroundColor: AppColors.primary,
        label: const Text(
          'SCHEDULE FITTING', 
          style: TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 1),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBookingCard(String title, String date, String status) {
    // Format date nicely from ISO string
    String formattedDate = date;
    try {
      if (date != 'No date' && date.isNotEmpty) {
        final parsedDate = DateTime.parse(date);
        formattedDate = '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} at ${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // Keep original if parsing fails
    }
    
    // Determine status color
    Color statusColor;
    Color statusBgColor;
    String statusText;
    
    switch (status.toLowerCase()) {
      case 'upcoming':
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.1);
        statusText = 'UPCOMING';
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        statusBgColor = Colors.blue.withOpacity(0.1);
        statusText = 'CONFIRMED';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusBgColor = Colors.red.withOpacity(0.1);
        statusText = 'CANCELLED';
        break;
      case 'completed':
        statusColor = Colors.purple;
        statusBgColor = Colors.purple.withOpacity(0.1);
        statusText = 'COMPLETED';
        break;
      default:
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.withOpacity(0.1);
        statusText = status.toUpperCase();
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate, 
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor, 
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText, 
              style: TextStyle(
                fontSize: 10, 
                fontWeight: FontWeight.bold, 
                color: statusColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}