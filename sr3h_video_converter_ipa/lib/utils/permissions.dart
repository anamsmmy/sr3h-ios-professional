import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionsHelper {
  
  /// Request all necessary permissions for the app
  static Future<bool> requestAllPermissions() async {
    final permissions = [
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.videos,
    ];
    
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    // Check if all permissions are granted
    bool allGranted = true;
    for (var status in statuses.values) {
      if (status != PermissionStatus.granted) {
        allGranted = false;
        break;
      }
    }
    
    return allGranted;
  }
  
  /// Check if storage permissions are granted
  static Future<bool> hasStoragePermissions() async {
    final storageStatus = await Permission.storage.status;
    final manageStorageStatus = await Permission.manageExternalStorage.status;
    
    return storageStatus.isGranted || manageStorageStatus.isGranted;
  }
  
  /// Show permission dialog
  static void showPermissionDialog(BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onRetry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('فتح الإعدادات'),
            ),
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
  
  /// Request storage permission with user-friendly dialog
  static Future<bool> requestStoragePermissionWithDialog(BuildContext context) async {
    final hasPermission = await hasStoragePermissions();
    
    if (hasPermission) return true;
    
    // Show explanation dialog first
    bool shouldRequest = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إذن الوصول للملفات'),
          content: const Text(
            'يحتاج التطبيق إلى إذن الوصول للملفات لحفظ الفيديوهات المحولة وقراءة الفيديوهات المختارة.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    ) ?? false;
    
    if (!shouldRequest) return false;
    
    // Request permissions
    final granted = await requestAllPermissions();
    
    if (!granted && context.mounted) {
      showPermissionDialog(
        context,
        title: 'إذن مطلوب',
        message: 'يحتاج التطبيق إلى إذن الوصول للملفات للعمل بشكل صحيح. يرجى منح الإذن من إعدادات التطبيق.',
        onRetry: () => requestStoragePermissionWithDialog(context),
      );
    }
    
    return granted;
  }
}