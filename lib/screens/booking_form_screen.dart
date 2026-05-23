import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/error_handler.dart';

class BookingFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const BookingFormScreen({super.key, this.product});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _requestsController;

  String _selectedService = 'Consultation';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isLoading = false;

  final List<String> _services = [
    'Consultation',
    'Purchase',
    'Custom Design',
    'Fitting',
    'Alterations',
  ];

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: AuthService.user?['phone'] ?? '');
    _emailController = TextEditingController(text: AuthService.user?['email'] ?? '');
    _addressController = TextEditingController();
    _requestsController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _requestsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final bookingDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final bookingData = {
        'service_type': _selectedService,
        'booking_date': bookingDateTime.toIso8601String(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'notes': _requestsController.text.trim(),
      };

      final result = await ApiService.bookAppointment(
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        serviceType: _selectedService,
        bookingDate: bookingDateTime.toIso8601String(),
        notes: _requestsController.text.trim(),
      );
      
      if (mounted) {
        ErrorHandler.showSuccess(context, 'Booking created successfully!');
        
        final fullDetails = Map<String, dynamic>.from(bookingData);
        
        // FIXED: safely extract id — handles both {data: {id: ...}} and {id: ...} shapes
        fullDetails['id'] = result['data']?['id'] ?? result['id'];
        fullDetails['service'] = _selectedService;
        
        context.push('/booking-confirmation', extra: fullDetails);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, 'Failed to create booking: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      appBar: AppBar(
        title: Text(
          'BOOK AN APPOINTMENT', 
          style: Theme.of(context).textTheme.labelSmall,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.product != null) ...[
                _buildSectionTitle('SELECTED PRODUCT'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.product!['image_url'] ?? 'https://picsum.photos/seed/dress/100/100',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], width: 60, height: 60),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.product!['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            Text('UGX ${widget.product!['price']}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              _buildSectionTitle('CONTACT INFORMATION'),
              _buildTextField('Phone Number', _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField('Email Address', _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              
              const SizedBox(height: 24),
              _buildSectionTitle('APPOINTMENT DETAILS'),
              
              DropdownButtonFormField<String>(
                value: _selectedService,
                decoration: _inputDecoration('Service Type', Icons.room_service_outlined),
                items: _services.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedService = val!),
                validator: (value) => value == null ? 'Please select a service type' : null,
              ),
              
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: IgnorePointer(
                        child: _buildTextField(
                          'Date',
                          TextEditingController(text: DateFormat('MMM dd, yyyy').format(_selectedDate)),
                          Icons.calendar_today_outlined,
                          enabled: false,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: IgnorePointer(
                        child: _buildTextField(
                          'Time',
                          TextEditingController(text: _selectedTime.format(context)),
                          Icons.access_time,
                          enabled: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('ADDITIONAL INFORMATION'),
              _buildTextField('Fitting Address (Optional)', _addressController, Icons.location_on_outlined),
              const SizedBox(height: 16),
              _buildTextField('Special Requests (Optional)', _requestsController, Icons.notes, maxLines: 3),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'CONFIRM BOOKING',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.black38,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      decoration: _inputDecoration(label, icon),
      validator: (value) {
        if (value == null || value.isEmpty) {
          if (label.contains('Optional')) return null;
          return 'Please enter $label';
        }
        if (label.contains('Email') && !value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: AppColors.primary.withOpacity(0.5)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      labelStyle: const TextStyle(fontSize: 14, color: Colors.black45),
    );
  }
}