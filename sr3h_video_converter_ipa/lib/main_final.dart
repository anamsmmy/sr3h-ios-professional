import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://vogdhlbcgokhqywyhfbn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZvZ2RobGJjZ29raHF5d3loZmJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzMzkxMTIsImV4cCI6MjA2NzkxNTExMn0.sTd2WCZTGYp5zREcOYNwVia-hS-YKq-yDhi0fnEu_Uc',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محّول سرعة',
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
  String _conversionProgress = '';
  String? _authenticatedEmail;

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
      final response = await supabase
          .from('email_subscriptions')
          .select('email, is_active')
          .eq('email', _emailController.text.trim().toLowerCase())
          .maybeSingle();

      if (response == null) {
        setState(() {
          _message = 'البريد الإلكتروني غير مسجل في النظام';
          _isLoading = false;
        });
        return;
      }

      final isActive = response['is_active'] as bool? ?? false;

      if (!isActive) {
        setState(() {
          _message = 'الاشتراك غير مفعل. يرجى التواصل مع الدعم الفني';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isAuthenticated = true;
        _authenticatedEmail = _emailController.text.trim().toLowerCase();
        _message = 'تم التفعيل بنجاح! مرحباً بك في محّول سرعة';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _message = 'خطأ في الاتصال بالخادم. يرجى التحقق من الاتصال بالإنترنت';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickVideo() async {
    try {
      // Request permissions
      await Permission.storage.request();
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedVideoPath = result.files.single.path;
          _selectedVideoName = result.files.single.name;
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
    });

    try {
      // Get output directory
      final directory = await getExternalStorageDirectory();
      final outputDir = Directory('${directory!.path}/SR3H_Converted');
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      // Create output filename
      final inputFile = File(_selectedVideoPath!);
      final fileName = _selectedVideoName!.split('.').first;
      final extension = _selectedVideoName!.split('.').last;
      final outputPath = '${outputDir.path}/$fileName-SR3H.$extension';

      setState(() {
        _conversionProgress = 'جاري تحويل الفيديو إلى 60 إطار...';
      });

      // FFmpeg command to convert to 60fps
      final command = '-itsscale 2 -i "${_selectedVideoPath!}" -c:v copy -c:a copy "$outputPath"';
      
      await FFmpegKit.execute(command).then((session) async {
        final returnCode = await session.getReturnCode();
        
        if (ReturnCode.isSuccess(returnCode)) {
          setState(() {
            _isConverting = false;
            _conversionProgress = '';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم التحويل بنجاح! الملف محفوظ في: $outputPath'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          throw Exception('فشل في تحويل الفيديو');
        }
      });

    } catch (e) {
      setState(() {
        _isConverting = false;
        _conversionProgress = '';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في التحويل: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                  'برنامج لتحويل الفيديو إلى 60 إطار في الثانية، يساعد على تحويل مقاطع الفيديو العادية إلى فيديوهات سلسة بجودة عالية.',
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
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, 
               color: Colors.green.shade600, size: 16),
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
          'محّول سرعة - تحويل الفيديو إلى 60 إطار',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                  width: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.video_library,
                      size: 80,
                      color: Colors.green,
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
            ] else ...[
              const Text(
                'مرحباً بك!',
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
                        _selectedVideoPath != null ? 'الفيديو المختار' : 'اختيار الفيديو',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_selectedVideoName != null) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            _selectedVideoName!,
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Tajawal',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_isConverting) ...[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        Text(
                          _conversionProgress,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            color: Colors.blue,
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
                              icon: const Icon(Icons.folder_open),
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
                                onPressed: _isConverting ? null : _startConversion,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text(
                                  'بدء التحويل',
                                  style: TextStyle(fontFamily: 'Tajawal'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
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
              
              // Tips Card
              _buildTipsCard(),
            ],
            
            const SizedBox(height: 16),
            
            if (_message.isNotEmpty)
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
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const SizedBox(height: 24),
            
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
                    'www.SR3H.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}