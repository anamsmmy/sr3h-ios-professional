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
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // جمع معلومات الجهاز الفريدة
      final deviceData = {
        'androidId': androidInfo.id,
        'manufacturer': androidInfo.manufacturer,
        'model': androidInfo.model,
        'version': androidInfo.version.release,
        'serial': androidInfo.serialNumber,
        'brand': androidInfo.brand,
        'product': androidInfo.product,
      };

      // تحويل البيانات إلى نص وتوليد hash
      final deviceString = deviceData.values.join('|');
      final bytes = utf8.encode(deviceString);
      final digest = sha256.convert(bytes);

      setState(() {
        _currentHardwareId = digest.toString();
      });

      print('🔐 Hardware ID generated: ${_currentHardwareId.substring(0, 16)}...');
    } catch (e) {
      print('❌ Error generating hardware ID: $e');
      // في حالة الخطأ، استخدم معرف بديل
      final fallbackId = DateTime.now().millisecondsSinceEpoch.toString();
      final bytes = utf8.encode(fallbackId);
      final digest = sha256.convert(bytes);
      setState(() {
        _currentHardwareId = digest.toString();
      });
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.videos,
    ].request();
  }

  Future<void> _verifyEmail() async {
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

  void _showImportantTips() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'نصائح هامة',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTipRow('🔹 لا تحرر الفيديو بعد التحويل أو تعدل عليه، حتى في TikTok'),
                  const SizedBox(height: 12),
                  _buildTipRow(
                      '🔹 رفع الفيديو الى TikTok من متصفح "Google Chrome" كـ"موقع مصمم للكمبيوتر"'),
                  const SizedBox(height: 12),
                  _buildTipRow('🔹 قبل رفع الفيديو إلى حسابك على TikTok، اختر دولة "اليابان"'),
                  const SizedBox(height: 12),
                  _buildTipRow('🔹 شغل VPN قبل رفع الفيديو، مثل التطبيق المجاني (Psiphon)'),
                  const SizedBox(height: 12),
                  _buildTipRow('🔹 أحيانًا TikTok يقرأ معلومات الشريحة SIM Card ليتعرف على بلدك'),
                  const SizedBox(height: 12),
                  _buildTipRow('✅ إذا لم تنجح الطريقة، أخرج الشريحة واعتمد على شبكة WiFi فقط'),
                ],
              ),
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickVideoFile();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipRow(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  Future<void> _pickVideoFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedVideoPath = result.files.single.path;
          _selectedVideoName = result.files.single.name;
          _isConverted = false; // إعادة تعيين حالة التحويل
          _convertedVideoPath = null;
          _conversionSuccessMessage = ''; // إخفاء رسالة النجاح السابقة
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم اختيار الفيديو: ${result.files.single.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ في اختيار الفيديو. يرجى المحاولة مرة أخرى'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickVideo() async {
    _showImportantTips();
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
      // Get Movies directory (Gallery) for Android and create SR3H folder
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Movies/SR3H');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        // Fallback to DCIM if Movies doesn't work
        if (!await directory.exists()) {
          directory = Directory('/storage/emulated/0/DCIM/SR3H');
          await directory.create(recursive: true);
        }
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        directory = Directory('${appDir.path}/SR3H');
        await directory.create(recursive: true);
      }

      // Create output filename with random number
      final random = Random();
      final randomNumber = random.nextInt(999999) + 100000; // 6-digit random number
      final outputPath = '${directory.path}/SR3H-$randomNumber.mp4';

      setState(() {
        _conversionProgress = 'جاري معالجة الفيديو...';
        _conversionProgressPercent = 0.2;
      });

      // The exact FFmpeg command requested
      final command = '-itsscale 2 -i "${_selectedVideoPath!}" -c:v copy -c:a copy "$outputPath"';

      print('🎬 تطبيق أمر FFmpeg: $command');

      await FFmpegKit.executeAsync(command, (ffmpeg.Session session) async {
        final returnCode = await session.getReturnCode();

        setState(() {
          _isConverting = false;
          _conversionProgress = '';
          _conversionProgressPercent = 1.0;
        });

        if (ReturnCode.isSuccess(returnCode)) {
          // Check if output file exists
          final outputFile = File(outputPath);
          if (await outputFile.exists()) {
            final fileSizeMB = (await outputFile.length()) / (1024 * 1024);

            setState(() {
              _isConverted = true;
              _convertedVideoPath = outputPath;
            });

            final outputFileName = outputPath.split('/').last;
            setState(() {
              _conversionSuccessMessage = '✅ تم تحويل الفيديو بنجاح!\n'
                  'الملف: $outputFileName\n'
                  'الحجم: ${fileSizeMB.toStringAsFixed(1)} MB\n'
                  '📁 تم الحفظ في ألبوم SR3H\n'
                  '🎬 يمكنك العثور على الفيديو بالضغط على زر "استعراض التحويلات" أو من خلال "مدير الملفات" على جهازك';
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
      }, (Log log) {
        // Update progress based on log messages
        final message = log.getMessage();
        setState(() {
          if (message.contains('time=')) {
            _conversionProgress = 'جاري المعالجة... ${message.split('time=')[1].split(' ')[0]}';
            _conversionProgressPercent = 0.6;
          } else if (message.contains('frame=')) {
            _conversionProgress = 'معالجة الإطارات...';
            _conversionProgressPercent = 0.4;
          }
        });
      }, (Statistics statistics) {
        // Update progress based on statistics
        if (statistics.getTime() > 0) {
          setState(() {
            _conversionProgressPercent = 0.8;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isConverting = false;
        _conversionProgress = '';
        _conversionProgressPercent = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في التحويل: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _openSR3HFolder() async {
    try {
      // محاولة فتح مجلد SR3H في مدير الملفات
      const sr3hPath = '/storage/emulated/0/Movies/SR3H';
      final uri = Uri.parse(
          'content://com.android.externalstorage.documents/document/primary%3AMovies%2FSR3H');

      // محاولة فتح المجلد مباشرة
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // إذا فشل، افتح تطبيق المعرض
        final galleryUri = Uri.parse('content://media/external/video/media');
        if (await canLaunchUrl(galleryUri)) {
          await launchUrl(galleryUri, mode: LaunchMode.externalApplication);
        } else {
          // كحل أخير، افتح مدير الملفات العام
          final fileManagerUri =
              Uri.parse('content://com.android.externalstorage.documents/document/primary%3A');
          if (await canLaunchUrl(fileManagerUri)) {
            await launchUrl(fileManagerUri, mode: LaunchMode.externalApplication);
          } else {
            throw Exception('لا يمكن فتح مدير الملفات');
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم فتح مجلد التحويلات SR3H'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يمكنك العثور على الفيديوهات في مجلد SR3H في تطبيق المعرض'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'حول التطبيق',
              style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'تطبيق سرعة لتصحيح معلومات الفيديو ليصبح 60 فريم على التيك توك',
                    style: TextStyle(fontFamily: 'Tajawal'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'اسم المطور: منصة سرعة',
                    style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'الموقع الإلكتروني: www.SR3H.com',
                    style: TextStyle(fontFamily: 'Tajawal', color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'الإصدار: 2.0.1',
                    style: TextStyle(fontFamily: 'Tajawal'),
                  ),
                  const SizedBox(height: 16),
                  if (_isAuthenticated) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'حالة التفعيل: مفعل ✅',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'البريد المفعل: $_authenticatedEmail',
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    '© 2025 جميع الحقوق محفوظة',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'إغلاق',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipsCard() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  const Text(
                    'نصائح قبل التحويل',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTipItem('أن يكون نوع الفيديو MP4'),
              _buildTipItem('عرض الفيديو 1080 بكسل'),
              _buildTipItem('ارتفاع الفيديو 1920 بكسل'),
              _buildTipItem('أن يكون الفيديو طولي'),
              _buildTipItem('أن يكون الفيديو 60 إطار في الثانية'),
              _buildTipItem('أن لا يحتوي الفيديو على شعار أو حقوق مكتوبة'),
              _buildTipItem('لأن الخوارزمية قد تحجبه من الاقتراحات'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tips_and_updates, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '💡 نصيحة: تجنب وجود فراغات سوداء في الأعلى أو الأسفل',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.code, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '🎬 نستخدم تقنية متقدمة لمعالجة الفيديو بجودة عالية',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          color: Colors.green,
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
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'محّول سرعة',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAboutDialog,
            tooltip: 'حول التطبيق',
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo - أكبر حجماً
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 300,
                    width: 300,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.video_library,
                            size: 160,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'محّول سرعة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          Text(
                            'الإصدار 2.0.1',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (!_isAuthenticated) ...[
                const Text(
                  'تفعيل التطبيق',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'أدخل بريدك الإلكتروني للتحقق من الاشتراك',
                  style: TextStyle(fontSize: 16, fontFamily: 'Tajawal'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    labelStyle: TextStyle(fontFamily: 'Tajawal'),
                    hintText: 'test@example.com',
                    hintStyle: TextStyle(fontFamily: 'Tajawal'),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontFamily: 'Tajawal'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'تفعيل التطبيق',
                          style: TextStyle(fontSize: 18, fontFamily: 'Tajawal'),
                        ),
                ),

                // عرض رسائل التفعيل
                if (_message.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isAuthenticated ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isAuthenticated ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text(
                      _message,
                      style: TextStyle(
                        color: _isAuthenticated ? Colors.green.shade700 : Colors.red.shade700,
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ] else ...[
                const Text(
                  'مرحباً بك في محوّل سرعة',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          _selectedVideoPath != null ? Icons.video_library : Icons.video_file,
                          size: 48,
                          color: _selectedVideoPath != null ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedVideoPath != null ? 'معلومات الفيديو' : 'اختيار الفيديو',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_selectedVideoName != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              _selectedVideoName!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade700,
                                fontFamily: 'Tajawal',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (_isConverting) ...[
                          LinearProgressIndicator(
                            value: _conversionProgressPercent,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _conversionProgress,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isConverting ? null : _pickVideo,
                                icon: const Text('🎬', style: TextStyle(fontSize: 20)),
                                label: Text(
                                  _selectedVideoPath != null ? 'تغيير الفيديو' : 'اختر ملف فيديو',
                                  style: const TextStyle(fontFamily: 'Tajawal'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            if (_selectedVideoPath != null) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isConverting
                                      ? null
                                      : (_isConverted ? _openSR3HFolder : _startConversion),
                                  icon: _isConverting
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Icon(_isConverted ? Icons.folder_open : Icons.play_arrow),
                                  label: Text(
                                    _isConverting
                                        ? 'جاري التحويل...'
                                        : (_isConverted ? 'استعراض التحويلات' : 'بدء التحويل'),
                                    style: const TextStyle(fontFamily: 'Tajawal'),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isConverted ? Colors.orange : Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tips Card - يظهر دائماً بعد التفعيل
                _buildTipsCard(),
              ],

              // رسالة نجاح التحويل
              if (_conversionSuccessMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _conversionSuccessMessage,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _conversionSuccessMessage = '';
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                        tooltip: 'إغلاق',
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Footer مع رابط الموقع
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      'محّول سرعة - تحويل الفيديو إلى 60 إطار',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'الإصدار 2.0.1',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'نرحب باقتراحاتكم و ملاحظاتكم من خلال منصة سرعة:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'www.SR3H.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'شكرا لدعمكم لنا، وثقتكم بنا',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
