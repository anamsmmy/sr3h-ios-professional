import 'dart:io';
import 'package:flutter/material.dart';

class NetworkUtils {
  
  /// Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
  
  /// Check connection to Supabase
  static Future<bool> canConnectToSupabase() async {
    try {
      final result = await InternetAddress.lookup('supabase.co');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
  
  /// Show network error dialog
  static void showNetworkErrorDialog(BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? 'خطأ في الاتصال'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message ?? 'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('إعادة المحاولة'),
              ),
          ],
        );
      },
    );
  }
  
  /// Show loading dialog with network check
  static void showLoadingWithNetworkCheck(
    BuildContext context, {
    String? message,
    required Future<void> Function() onExecute,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message ?? 'جاري التحميل...'),
            ],
          ),
        );
      },
    );
    
    try {
      // Check internet connection first
      final hasInternet = await hasInternetConnection();
      if (!hasInternet) {
        Navigator.of(context).pop(); // Close loading dialog
        showNetworkErrorDialog(
          context,
          title: 'لا يوجد اتصال بالإنترنت',
          message: 'يرجى التأكد من اتصالك بالإنترنت والمحاولة مرة أخرى',
          onRetry: () => showLoadingWithNetworkCheck(
            context,
            message: message,
            onExecute: onExecute,
            onSuccess: onSuccess,
            onError: onError,
          ),
        );
        return;
      }
      
      // Execute the function
      await onExecute();
      
      Navigator.of(context).pop(); // Close loading dialog
      onSuccess?.call();
      
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      onError?.call(e.toString());
    }
  }
  
  /// Get network status message
  static Future<String> getNetworkStatusMessage() async {
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      return 'لا يوجد اتصال بالإنترنت';
    }
    
    final canConnectSupabase = await canConnectToSupabase();
    if (!canConnectSupabase) {
      return 'لا يمكن الاتصال بخادم البيانات';
    }
    
    return 'الاتصال جيد';
  }
  
  /// Retry mechanism for network operations
  static Future<T?> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        await Future.delayed(delay);
      }
    }
    
    return null;
  }
}