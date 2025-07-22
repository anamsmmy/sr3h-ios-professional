import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      title: 'منصة سرعة',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Cairo',
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
  bool _isLoading = false;
  String _message = '';
  bool _isAuthenticated = false;

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
        _message = 'تم التفعيل بنجاح!';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _message = 'خطأ في الاتصال: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('منصة سرعة - تحويل الفيديو'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.video_library,
                size: 60,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 32),
            
            if (!_isAuthenticated) ...[
              // Authentication Section
              const Text(
                'تفعيل التطبيق',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'أدخل بريدك الإلكتروني للتحقق من الاشتراك',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  hintText: 'test@example.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 16),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'تفعيل التطبيق',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ] else ...[
              // Main App Section
              const Text(
                'مرحباً بك!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.video_file,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'اختيار الفيديو',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ميزة اختيار الفيديو ستكون متاحة في النسخة الكاملة'),
                            ),
                          );
                        },
                        child: const Text('اختر ملف فيديو'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Message
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
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const Spacer(),
            
            // App Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    'منصة سرعة - تحويل الفيديو إلى 60 إطار',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'الإصدار 2.0.1',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'للاختبار استخدم: test@example.com',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
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