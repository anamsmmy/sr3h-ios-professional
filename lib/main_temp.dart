import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/session.dart' as ffmpeg;
import 'package:ffmpeg_kit_flutter_new/log.dart';
import 'package:ffmpeg_kit_flutter_new/statistics.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/session.dart' as ffmpeg;
import 'package:ffmpeg_kit_flutter_new/log.dart';
import 'package:ffmpeg_kit_flutter_new/statistics.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://vogdhlbcgokhqywyhfbn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZvZ2RobGJjZ29raHF5d3loZmJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzMzkxMTIsImV4cCI6MjA2NzkxNTExMn0.sTd2WCZTGYp5zREcOYNwVia-hS-YKq-yDhi0fnEu_Uc',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محوّل سرعة',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Tajawal',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _message = '';
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _selectedVideoPath;
  String? _selectedVideoName;
  bool _isConverting = false;
  bool _isConverted = false;
  String _conversionProgress = '';
  String? _authenticatedEmail;
  double _conversionProgressPercent = 0.0;
  String _currentHardwareId = '';
  String? _convertedVideoPath;
  String _conversionSuccessMessage = '';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _generateHardwareId();
    _checkLastVerification();
  }

  Future<void> _checkLastVerification() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt('last_verification_check') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const dayInMillis = 24 * 60 * 60 * 1000; // 24 ساعة

    if (now - lastCheck > dayInMillis) {
      // مرت أكثر من 24 ساعة، نحتاج للتحقق مرة أخرى
      final savedEmail = prefs.getString('authenticated_email');
      if (savedEmail != null) {
        _emailController.text = savedEmail;
        await _verifyEmail();
      }
    } else {
      // لا نحتاج للتحقق، استخدم البيانات المحفوظة
      final savedEmail = prefs.getString('authenticated_email');
      final isAuth = prefs.getBool('is_authenticated') ?? false;

      if (savedEmail != null && isAuth) {
        setState(() {
          _isAuthenticated = true;
          _authenticatedEmail = savedEmail;
          _message = 'مرحباً بك في محوّل سرعة';
        });
      }
    }
  }

  Future<void> _generateHardwareId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // التحقق من وجود Hardware ID محفوظ مسبقاً
      String? savedHardwareId = prefs.getString('device_hardware_id');
      
      if (savedHardwareId != null && savedHardwareId.isNotEmpty) {
        // استخدام Hardware ID المحفوظ (ثابت)
        setState(() {
          _currentHardwareId = savedHardwareId;
        });
        print('🔐 Using saved Hardware ID: ...');
        return;
      }

      // إنشاء Hardware ID جديد للمرة الأولى فقط
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // جمع معلومات الجهاز الثابتة فقط
      final deviceData = {
        'androidId': androidInfo.id,
        'manufacturer': androidInfo.manufacturer,
        'model': androidInfo.model,
        'brand': androidInfo.brand,
        'product': androidInfo.product,
        'hardware': androidInfo.hardware,
        'device': androidInfo.device,
      };

      // تحويل البيانات إلى نص وتوليد hash ثابت
      final deviceString = deviceData.values.where((v) => v != null).join('|');
      final bytes = utf8.encode(deviceString);
      final digest = sha256.convert(bytes);
      
      final hardwareId = digest.toString();

      // حفظ Hardware ID ليبقى ثابت
      await prefs.setString('device_hardware_id', hardwareId);

      setState(() {
        _currentHardwareId = hardwareId;
      });

      print('🔐 New Hardware ID generated and saved: ...');
    } catch (e) {
      print('❌ Error generating hardware ID: ');
      
      final prefs = await SharedPreferences.getInstance();
      String? savedHardwareId = prefs.getString('device_hardware_id');
      
      if (savedHardwareId != null) {
        setState(() {
          _currentHardwareId = savedHardwareId;
        });
      } else {
        // إنشاء معرف بديل ثابت
        final fallbackId = 'fallback_';
        final bytes = utf8.encode(fallbackId);
        final digest = sha256.convert(bytes);
        final hardwareId = digest.toString();
        
        await prefs.setString('device_hardware_id', hardwareId);
        setState(() {
          _currentHardwareId = hardwareId;
        });
      }
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.videos,
      Permission.photos,
    ].request();
  }

  Future<void> _verifyEmail() async {
    // إخفاء لوحة المفاتيح فوراً
    FocusScope.of(context).unfocus();
    
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _message = 'يرجى إدخال البريد الإلكتروني';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final supabase = Supabase.instance.client;
      final email = _emailController.text.trim().toLowerCase();

      // البحث عن البريد الإلكتروني
      final response = await supabase
          .from('email_subscriptions')
          .select('email, is_active, hardware_id')
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        setState(() {
          _message = 'البريد الإلكتروني غير مسجل في النظام';
          _isLoading = false;
        });
        return;
      }

      final isActive = response['is_active'] as bool? ?? false;
      final existingHardwareId = response['hardware_id'] as String?;

      if (!isActive) {
        setState(() {
          _message = 'الاشتراك غير مفعل. يرجى التواصل مع الدعم الفني';
          _isLoading = false;
        });
        return;
      }

      // التحقق من hardware_id
      if (existingHardwareId == null || existingHardwareId.isEmpty) {
        // أول تفعيل - حفظ hardware_id
        await supabase.from('email_subscriptions').update({
          'hardware_id': _currentHardwareId,
          'last_check': DateTime.now().toIso8601String(),
        }).eq('email', email);

        setState(() {
          _isAuthenticated = true;
          _authenticatedEmail = email;
          _message = 'تم التفعيل بنجاح! مرحباً بك في محوّل سرعة';
          _isLoading = false;
        });
      } else if (existingHardwareId == _currentHardwareId) {
        // نفس الجهاز - تحديث آخر فحص
        await supabase.from('email_subscriptions').update({
          'last_check': DateTime.now().toIso8601String(),
        }).eq('email', email);

        // حفظ البيانات محلياً
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authenticated_email', email);
        await prefs.setBool('is_authenticated', true);
        await prefs.setInt('last_verification_check', DateTime.now().millisecondsSinceEpoch);

        setState(() {
          _isAuthenticated = true;
          _authenticatedEmail = email;
          _message = 'تم التحقق من التفعيل بنجاح';
          _isLoading = false;
        });
      } else {
        // جهاز مختلف - رفض التفعيل
        setState(() {
          _message = 'هذا الحساب مفعل على جهاز آخر. كل حساب يمكن تفعيله على جهاز واحد فقط';
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      setState(() {
        _message = 'خطأ في الاتصال بالخادم. يرجى التحقق من الاتصال بالإنترنت';
        _isLoading = false;
      });
    }
  }
