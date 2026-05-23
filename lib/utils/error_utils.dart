import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/error_handler.dart';

class ErrorUtils {
  // Global error handler for uncaught exceptions
  static void init() {
    if (kDebugMode) {
      // In debug mode, show errors in console
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.dumpErrorToConsole(details);
        _logError(details.exceptionAsString(), details.stack);
      };
    } else {
      // In release mode, handle errors gracefully
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.dumpErrorToConsole(details);
        _logError(details.exceptionAsString(), details.stack);
      };
    }
  }

  static void _logError(String error, StackTrace? stack) {
    print('ERROR: $error');
    if (stack != null) {
      print('STACK: $stack');
    }
  }

  // Show a generic error message
  static void showGenericError(BuildContext context) {
    ErrorHandler.showError(
      context,
      'Something went wrong. Please try again.',
    );
  }

  // Handle API response errors
  static bool handleApiResponse(
    BuildContext context,
    Map<String, dynamic> response,
  ) {
    if (response['success'] == true) {
      return true;
    }
    
    String message = response['message'] ?? 'An error occurred';
    ErrorHandler.showError(context, message);
    return false;
  }
}