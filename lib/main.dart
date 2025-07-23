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
import 'package:flutter_keychain/flutter_keychain.dart';
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
        scaffoldBackgroundColor: const Color(0xFFF8F5F7),
        fontFamily: 'Tajawal',
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(),
      ),
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

  String _conversionSuccessMessage = '';
  bool _showTipsOnce = true;

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
      // استخدام Keychain للحصول على UUID ثابت 100%
      String hardwareId = await _getPersistentUUID();

      setState(() {
        _currentHardwareId = hardwareId;
      });
    } catch (e) {
      // في حالة الخطأ، إنشاء معرف بديل ثابت
      setState(() {
        _currentHardwareId = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
      });
    }
  }

  /// الحصول على UUID ثابت من Keychain - يبقى حتى بعد حذف التطبيق
  Future<String> _getPersistentUUID() async {
    const String key = 'persistentUUID';

    try {
      // محاولة قراءة UUID الموجود
      String? existingUUID = await FlutterKeychain.get(key: key);

      if (existingUUID != null && existingUUID.isNotEmpty) {
        return existingUUID;
      }

      // إنشاء UUID جديد إذا لم يوجد
      String newUUID = _generateUUID();

      // حفظ في Keychain
      await FlutterKeychain.put(key: key, value: newUUID);

      return newUUID;
    } catch (e) {
      // في حالة فشل Keychain، استخدم SharedPreferences كبديل
      final prefs = await SharedPreferences.getInstance();
      String? savedUUID = prefs.getString('backup_uuid');

      if (savedUUID != null && savedUUID.isNotEmpty) {
        return savedUUID;
      }

      String newUUID = _generateUUID();
      await prefs.setString('backup_uuid', newUUID);
      return newUUID;
    }
  }

  /// توليد UUID فريد
  String _generateUUID() {
    var random = Random();
    var values = List<int>.generate(16, (i) => random.nextInt(256));

    // تعديل البايتات لتتوافق مع UUID v4
    values[6] = (values[6] & 0x0f) | 0x40; // Version 4
    values[8] = (values[8] & 0x3f) | 0x80; // Variant bits

    var hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await [Permission.photos, Permission.camera, Permission.microphone].request();
    } else {
      await [
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.videos,
        Permission.photos,
      ].request();
    }
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

        // حفظ البيانات محلياً
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authenticated_email', email);
        await prefs.setBool('is_authenticated', true);
        await prefs.setInt('last_verification_check', DateTime.now().millisecondsSinceEpoch);

        setState(() {
          _isAuthenticated = true;
          _authenticatedEmail = email;
          _message = 'تم التفعيل بنجاح! مرحباً بك في محوّل سرعة';
          _isLoading = false;
        });
      } else if (existingHardwareId == _currentHardwareId) {
        // نفس الجهاز - تحديث آخر فحص
        await supabase
            .from('email_subscriptions')
            .update({'last_check': DateTime.now().toIso8601String()}).eq('email', email);

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

  void _showImportantTips() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFFF8F5F7),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'نصائح هامة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TipItem(
                      icon: '🔹',
                      text: 'لا تحرر الفيديو بعد التحويل أو تعدل عليه. ضع في TikTok كما هو.',
                    ),
                    TipItem(
                      icon: '🔹',
                      text: 'رفع الفيديو من متصفح "Google Chrome" في موقع TikTok المصمم للكمبيوتر.',
                    ),
                    TipItem(
                      icon: '🔹',
                      text: 'عند رفع الفيديو إلى حسابك على TikTok، اختر دولة "اليابان".',
                    ),
                    TipItem(
                      icon: '🔹',
                      text: 'شغّل VPN قبل رفع الفيديو، مثل التطبيق المجاني (Psiphon).',
                    ),
                    TipItem(
                      icon: '🔹',
                      text: 'أحيانًا TikTok يقرأ معلومات الشريحة SIM Card ليتعرف على بلدك.',
                    ),
                    TipItem(
                      icon: '✅',
                      text: 'إذا لم تنجح الطريقة، أخرج الشريحة واعتمد على شبكة WiFi فقط.',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _pickVideo();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('إغلاق', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedVideoPath = result.files.single.path;
          _selectedVideoName = result.files.single.name;
          _isConverted = false;
          _conversionSuccessMessage = '';
        });

        // إظهار Snackbar للتأكيد
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم اختيار الفيديو: $_selectedVideoName'),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في اختيار الفيديو: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _startConversion() async {
    if (_selectedVideoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار ملف فيديو أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isConverting = true;
      _conversionProgress = 'جاري التحضير للتحويل...';
      _conversionProgressPercent = 0.1;
    });

    try {
      // إنشاء مسار الحفظ
      String outputPath;

      if (Platform.isIOS) {
        // للـ iOS - حفظ في Documents
        final documentsDir = await getApplicationDocumentsDirectory();
        final random = Random();
        final randomNumber = random.nextInt(999999) + 100000;
        outputPath = '${documentsDir.path}/SR3H-$randomNumber.mp4';
      } else {
        // للـ Android - حفظ في DCIM/SR3H
        Directory? directory = Directory('/storage/emulated/0/DCIM/SR3H');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final random = Random();
        final randomNumber = random.nextInt(999999) + 100000;
        outputPath = '${directory.path}/SR3H-$randomNumber.mp4';
      }

      setState(() {
        _conversionProgress = 'جاري معالجة الفيديو...';
        _conversionProgressPercent = 0.2;
      });

      // أمر FFmpeg لتحويل السرعة
      final command = '-itsscale 2 -i "$_selectedVideoPath" -c:v copy -c:a copy "$outputPath"';

      await FFmpegKit.executeAsync(
        command,
        (ffmpeg.Session session) async {
          final returnCode = await session.getReturnCode();

          setState(() {
            _isConverting = false;
            _conversionProgress = '';
            _conversionProgressPercent = 1.0;
          });

          if (ReturnCode.isSuccess(returnCode)) {
            // التحقق من وجود الملف المحول
            final outputFile = File(outputPath);
            if (await outputFile.exists()) {
              final fileSizeMB = (await outputFile.length()) / (1024 * 1024);

              // حفظ الفيديو في المعرض
              try {
                if (Platform.isIOS) {
                  // للـ iOS - حفظ في Photos
                  await GallerySaver.saveVideo(outputPath, albumName: 'SR3H');
                } else {
                  // للـ Android - حفظ في المعرض
                  await GallerySaver.saveVideo(outputPath, albumName: 'SR3H');
                }
              } catch (e) {}

              setState(() {
                _isConverted = true;
              });

              final outputFileName = outputPath.split('/').last;
              setState(() {
                _conversionSuccessMessage = '✅ تم تحويل الفيديو بنجاح!\n'
                    'الملف: $outputFileName\n'
                    'الحجم: ${fileSizeMB.toStringAsFixed(1)} MB\n'
                    '📁 تم الحفظ في الاستوديو';
              });
            } else {
              throw Exception('الملف المحول غير موجود');
            }
          } else {
            final logs = await session.getAllLogs();
            String errorMessage = 'فشل في تحويل الفيديو';
            if (logs.isNotEmpty) {
              errorMessage += '\nالخطأ: ${logs.last.getMessage()}';
            }
            throw Exception(errorMessage);
          }
        },
        (Log log) {
          // تحديث التقدم
          setState(() {
            _conversionProgress = 'جاري المعالجة... ${log.getMessage()}';
          });
        },
        (Statistics statistics) {
          // تحديث نسبة التقدم
          if (statistics.getTime() > 0) {
            setState(() {
              _conversionProgressPercent = 0.2 + (statistics.getTime() / 100000) * 0.8;
              if (_conversionProgressPercent > 1.0) _conversionProgressPercent = 1.0;
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _isConverting = false;
        _conversionProgress = '';
        _conversionProgressPercent = 0.0;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في التحويل: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _openGallery() async {
    try {
      if (Platform.isIOS) {
        // للـ iOS - فتح تطبيق الصور
        const url = 'photos-redirect://';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          // إذا لم يعمل، جرب فتح الإعدادات
          await launchUrl(Uri.parse('app-settings:'));
        }
      } else {
        // للـ Android - فتح المعرض
        const url = 'content://media/external/images/media';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          // جرب فتح تطبيق المعرض
          await launchUrl(Uri.parse('content://media/external/video/media'));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن فتح المعرض. يرجى البحث عن ألبوم SR3H في تطبيق الصور'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFFF8F5F7),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'حول التطبيق',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'تطبيق سرعة لتصحيح معلومات الفيديو ليصبح 60 فريم على التيك توك',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                const Text(
                  'اسم المطوّر: منصة سرعة',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    const url = 'https://www.SR3H.com';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    }
                  },
                  child: const Text(
                    'الموقع الإلكتروني: www.SR3H.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'رقم الإصدار: 2.0.1',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'حالة التفعيل: مفعل',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _authenticatedEmail ?? '',
                        style: const TextStyle(fontSize: 16, color: Colors.green),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '© 2025 جميع الحقوق محفوظة',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('إغلاق', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'محوّل سرعة',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white),
            onPressed: _isAuthenticated ? _showAboutDialog : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isAuthenticated) ...[
              // قسم الشعار
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Image.asset('assets/images/logo.png', height: 80, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 30),

              // قسم تفعيل الاشتراك
              const Text(
                'تفعيل التطبيق',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'أدخل بريدك الإلكتروني للتحقق من الاشتراك',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // حقل البريد الإلكتروني
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'البريد الإلكتروني',
                  hintText: 'example@email.com',
                  prefixIcon: Icon(Icons.email),
                ),
                onSubmitted: (_) => _verifyEmail(),
              ),
              const SizedBox(height: 20),

              // زر التفعيل
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'تفعيل التطبيق',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // رسالة الحالة
              if (_message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: _message.contains('بنجاح') || _message.contains('مرحباً')
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    border: Border.all(
                      color: _message.contains('بنجاح') || _message.contains('مرحباً')
                          ? Colors.green
                          : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _message,
                    style: TextStyle(
                      color: _message.contains('بنجاح') || _message.contains('مرحباً')
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 40),

              // معلومات أسفل الواجهة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'محوّل سرعة - تحويل الفيديو إلى 60 إطار',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'الإصدار: 2.0.1',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'نرحب باقتراحاتكم و ملاحظاتكم من خلال منصة سرعة.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        const url = 'https://www.SR3H.com';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        }
                      },
                      child: const Text(
                        'www.SR3H.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'شكرًا لدعمكم لنا، وثقتكم بنا',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // الصفحة الرئيسية بعد التفعيل

              // قسم الشعار
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Image.asset('assets/images/logo.png', height: 80, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 20),

              // رسالة الترحيب
              const Text(
                'مرحباً بك في محوّل سرعة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2E7D32),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // قسم اختيار/معلومات الفيديو
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _selectedVideoName != null ? Icons.videocam : Icons.description,
                            color: const Color(0xFF4CAF50),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedVideoName != null ? 'معلومات الفيديو' : 'اختيار الفيديو',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (_selectedVideoName == null) ...[
                        // زر اختيار الفيديو
                        ElevatedButton.icon(
                          onPressed: _isConverting
                              ? null
                              : () {
                                  if (_showTipsOnce) {
                                    _showImportantTips();
                                    _showTipsOnce = false;
                                  } else {
                                    _pickVideo();
                                  }
                                },
                          icon: const Icon(Icons.movie),
                          label: const Text('اختر ملف فيديو 🎬'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ] else ...[
                        // عرض اسم الفيديو المختار
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Text(
                            _selectedVideoName!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // الأزرار
                        Row(
                          children: [
                            // زر تغيير الفيديو
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isConverting
                                    ? null
                                    : () {
                                        if (_showTipsOnce) {
                                          _showImportantTips();
                                          _showTipsOnce = false;
                                        } else {
                                          _pickVideo();
                                        }
                                      },
                                icon: const Icon(Icons.movie),
                                label: const Text('تغيير الفيديو'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // زر بدء التحويل أو استعراض التحويلات
                            Expanded(
                              child: _isConverted
                                  ? ElevatedButton.icon(
                                      onPressed: _openGallery,
                                      icon: const Icon(Icons.folder),
                                      label: const Text('استعراض التحويلات'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: _isConverting ? null : _startConversion,
                                      icon: _isConverting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.play_arrow),
                                      label: Text(
                                        _isConverting ? 'جاري التحويل...' : 'بدء التحويل',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4CAF50),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),

                        // شريط التقدم
                        if (_isConverting) ...[
                          const SizedBox(height: 15),
                          LinearProgressIndicator(
                            value: _conversionProgressPercent,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _conversionProgress,
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // قسم النصائح قبل التحويل
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'نصائح قبل التحويل',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Column(
                        children: [
                          TipItem(icon: '✅', text: 'أن يكون نوع الفيديو MP4'),
                          TipItem(icon: '✅', text: 'عرض الفيديو 1080 بكسل'),
                          TipItem(icon: '✅', text: 'ارتفاع الفيديو 1920 بكسل'),
                          TipItem(icon: '✅', text: 'أن يكون الفيديو طولي'),
                          TipItem(icon: '✅', text: 'أن يكون الفيديو 60 إطار في الثانية'),
                          TipItem(icon: '✅', text: 'أن لا يحتوي الفيديو على شعارات أو حقوق مكتوبة'),
                          TipItem(
                            icon: '✅',
                            text: 'أن لا يحتوي الفيديو على فلاتر أو تأثيرات غير واقعية',
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // نصيحة إضافية
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'نصيحة: تجنب وجود فراغات سوداء في الأعلى أو الأسفل',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
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

              const SizedBox(height: 20),

              // ملاحظة تقنية
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.videocam, color: Colors.green, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'نستخدم تقنية متقدمة لمعالجة الفيديو بجودة عالية',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // صندوق النجاح
              if (_isConverted) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 50),
                      const SizedBox(height: 10),
                      Text(
                        _conversionSuccessMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // معلومات أسفل الواجهة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'محوّل سرعة - تحويل الفيديو إلى 60 إطار',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'نرحب باقتراحاتكم و ملاحظاتكم من خلال منصة سرعة.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        const url = 'https://www.SR3H.com';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        }
                      },
                      child: const Text(
                        'www.SR3H.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'شكرًا لدعمكم لنا، وثقتكم بنا',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TipItem extends StatelessWidget {
  final String icon;
  final String text;

  const TipItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
