import 'package:flutter/material.dart';
import 'dart:io';

class ErrorHandler {
  // Show error message to user
  static void showError(BuildContext context, String message, {String? title}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success message
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show warning message
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Handle API errors
  static String handleApiError(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Connection timeout. The server is taking too long to respond.';
    } else if (error.toString().contains('401')) {
      return 'Session expired. Please login again.';
    } else if (error.toString().contains('403')) {
      return 'You don\'t have permission to perform this action.';
    } else if (error.toString().contains('404')) {
      return 'Service not found. Please try again later.';
    } else if (error.toString().contains('500')) {
      return 'Server error. Our team has been notified.';
    } else if (error.toString().contains('Network error')) {
      return 'Unable to connect to server. Please check your connection.';
    } else {
      return error.toString().replaceAll('Exception:', '').trim();
    }
  }

  // Handle login errors specifically
  static String handleLoginError(dynamic error) {
    String errorMsg = handleApiError(error);
    if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
      return 'Invalid email or password. Please try again.';
    }
    return errorMsg;
  }

  // Handle registration errors
  static String handleRegistrationError(dynamic error) {
    String errorMsg = handleApiError(error);
    if (errorMsg.contains('422')) {
      return 'Please check all fields and try again.';
    } else if (errorMsg.contains('Validation failed')) {
      return 'Please fill all required fields correctly.';
    }
    return errorMsg;
  }
}