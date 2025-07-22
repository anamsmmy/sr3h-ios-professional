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
        print('🔐 Using saved Hardware ID');
        return;
      }

      // إنشاء Hardware ID جديد للمرة الأولى فقط - ثابت ولا يتغير
      String hardwareId;

      if (Platform.isIOS) {
        // للـ iOS - استخدام معرف ثابت مبني على معلومات الجهاز
        final deviceInfo = DeviceInfoPlugin();
        final iosInfo = await deviceInfo.iosInfo;

        // جمع معلومات الجهاز الثابتة
        final deviceData = {
          'identifierForVendor': iosInfo.identifierForVendor ?? 'unknown',
          'model': iosInfo.model,
          'systemName': iosInfo.systemName,
          'name': iosInfo.name,
        };

        final deviceString = deviceData.values.join('|');
        final bytes = utf8.encode(deviceString);
        final digest = sha256.convert(bytes);
        hardwareId = digest.toString();
      } else {
        // للـ Android - استخدام معرف ثابت مبني على معلومات الجهاز
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

        final deviceString = deviceData.values.where((v) => v != null).join('|');
        final bytes = utf8.encode(deviceString);
        final digest = sha256.convert(bytes);
        hardwareId = digest.toString();
      }

      // حفظ Hardware ID ليبقى ثابت إلى الأبد
      await prefs.setString('device_hardware_id', hardwareId);

      setState(() {
        _currentHardwareId = hardwareId;
      });

      print('🔐 New Hardware ID generated and saved permanently');
    } catch (e) {
      print('❌ Error generating hardware ID: $e');

      // في حالة الخطأ، إنشاء معرف بديل ثابت
      final prefs = await SharedPreferences.getInstance();
      String? savedHardwareId = prefs.getString('device_hardware_id');

      if (savedHardwareId != null) {
        setState(() {
          _currentHardwareId = savedHardwareId;
        });
      } else {
        // إنشاء معرف بديل ثابت مبني على الوقت الحالي (سيبقى ثابت)
        final fallbackId = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
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
    if (Platform.isIOS) {
      await [
        Permission.photos,
        Permission.camera,
        Permission.microphone,
      ].request();
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
          _convertedVideoPath = null;
          _conversionSuccessMessage = '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في اختيار الفيديو: $e'),
          backgroundColor: Colors.red,
        ),
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
        outputPath = '${documentsDir.path}/SR3H_${randomNumber}.mp4';
      } else {
        // للـ Android - حفظ في DCIM/SR3H
        Directory? directory = Directory('/storage/emulated/0/DCIM/SR3H');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final random = Random();
        final randomNumber = random.nextInt(999999) + 100000;
        outputPath = '${directory.path}/SR3H_${randomNumber}.mp4';
      }

      setState(() {
        _conversionProgress = 'جاري معالجة الفيديو...';
        _conversionProgressPercent = 0.2;
      });

      // أمر FFmpeg لتحويل السرعة
      final command = '-itsscale 2 -i "$_selectedVideoPath" -c:v copy -c:a copy "$outputPath"';

      print('🎬 تطبيق أمر FFmpeg: $command');

      await FFmpegKit.executeAsync(command, (ffmpeg.Session session) async {
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
              print('📱 Video saved to gallery successfully');
            } catch (e) {
              print('⚠️ Could not save to gallery: $e');
            }

            setState(() {
              _isConverted = true;
              _convertedVideoPath = outputPath;
            });

            final outputFileName = outputPath.split('/').last;
            setState(() {
              _conversionSuccessMessage = '✅ تم تحويل الفيديو بنجاح!\n'
                  'الملف: $outputFileName\n'
                  'الحجم: ${fileSizeMB.toStringAsFixed(2)} MB\n'
                  '📱 تم حفظ الفيديو في معرض الصور - ألبوم SR3H';
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
        // تحديث التقدم
        setState(() {
          _conversionProgress = 'جاري المعالجة... ${log.getMessage()}';
        });
      }, (Statistics statistics) {
        // تحديث نسبة التقدم
        if (statistics.getTime() > 0) {
          setState(() {
            _conversionProgressPercent = 0.2 + (statistics.getTime() / 100000) * 0.8;
            if (_conversionProgressPercent > 1.0) _conversionProgressPercent = 1.0;
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
          content: Text('خطأ في التحويل: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        SnackBar(
          content: Text('لا يمكن فتح المعرض. يرجى البحث عن ألبوم SR3H في تطبيق الصور'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('محوّل سرعة'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isAuthenticated) ...[
              const Text(
                'مرحباً بك في محوّل سرعة',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'يرجى إدخال البريد الإلكتروني للتفعيل:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'البريد الإلكتروني',
                  hintText: 'example@email.com',
                ),
                onSubmitted: (_) => _verifyEmail(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('تفعيل', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
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
            ] else ...[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'مرحباً $_authenticatedEmail',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'تم تفعيل حسابك بنجاح',
                      style: TextStyle(fontSize: 16, color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // قسم اختيار الفيديو
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '📹 اختيار الفيديو',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: _isConverting ? null : _pickVideo,
                        icon: const Icon(Icons.video_library),
                        label: const Text('اختيار فيديو'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                      if (_selectedVideoName != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'الفيديو المختار: $_selectedVideoName',
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // قسم التحويل
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '⚡ تحويل السرعة',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: (_selectedVideoPath != null && !_isConverting)
                            ? _startConversion
                            : null,
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
                        label: Text(_isConverting ? 'جاري التحويل...' : 'بدء التحويل'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                      if (_isConverting) ...[
                        const SizedBox(height: 15),
                        LinearProgressIndicator(
                          value: _conversionProgressPercent,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _conversionProgress,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (_isConverted) ...[
                const SizedBox(height: 20),
                Card(
                  color: Colors.green.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 50),
                        const SizedBox(height: 10),
                        Text(
                          _conversionSuccessMessage,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: _openGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('فتح معرض الصور'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
