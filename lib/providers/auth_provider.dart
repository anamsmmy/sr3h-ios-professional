import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../utils/network_utils.dart';
import '../utils/app_settings.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String _userEmail = '';
  String _errorMessage = '';
  
  AuthProvider() {
    _loadSavedAuthState();
  }
  
  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String get userEmail => _userEmail;
  String get errorMessage => _errorMessage;
  
  // Check if email exists and is active in Supabase
  Future<bool> verifyEmail(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Check internet connection first
      final hasInternet = await NetworkUtils.hasInternetConnection();
      if (!hasInternet) {
        _setError('لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى');
        _setLoading(false);
        return false;
      }
      
      // Use retry mechanism for network operation
      final response = await NetworkUtils.retryOperation(() async {
        return await _supabase
            .from(AppConstants.emailSubscriptionsTable)
            .select('email, is_active, subscription_start')
            .eq('email', email.trim().toLowerCase())
            .maybeSingle();
      });
      
      if (response == null) {
        _setError('البريد الإلكتروني غير مسجل في النظام');
        _setLoading(false);
        return false;
      }
      
      final isActive = response['is_active'] as bool? ?? false;
      
      if (!isActive) {
        _setError('الاشتراك غير مفعل. يرجى التواصل مع الدعم الفني');
        _setLoading(false);
        return false;
      }
      
      // Authentication successful
      _userEmail = email.trim().toLowerCase();
      _isAuthenticated = true;
      
      // Save authentication state
      await AppSettings.saveUserEmail(_userEmail);
      await AppSettings.saveAuthenticationStatus(true);
      
      _setLoading(false);
      notifyListeners();
      return true;
      
    } catch (e) {
      String errorMessage = 'خطأ في الاتصال بالخادم';
      
      if (e.toString().contains('SocketException')) {
        errorMessage = 'خطأ في الاتصال بالإنترنت';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'خطأ في تنسيق البيانات';
      }
      
      _setError('$errorMessage: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  // Load saved authentication state
  void _loadSavedAuthState() {
    _isAuthenticated = AppSettings.getAuthenticationStatus();
    _userEmail = AppSettings.getUserEmail() ?? '';
    notifyListeners();
  }
  
  // Logout
  Future<void> logout() async {
    _isAuthenticated = false;
    _userEmail = '';
    _clearError();
    
    // Clear saved authentication state
    await AppSettings.clearUserData();
    
    notifyListeners();
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }
  
  // Clear error manually
  void clearError() {
    _clearError();
  }
}