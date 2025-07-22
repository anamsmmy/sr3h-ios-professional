import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/video_provider.dart';
import '../utils/constants.dart';
import '../widgets/video_info_card.dart';
import '../widgets/requirements_card.dart';
import '../widgets/video_requirements_checker.dart';
import 'about_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'منصة سرعة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'about':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                  break;
                case 'logout':
                  _showLogoutDialog(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('عن البرنامج'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('تسجيل الخروج'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.video_settings,
                  size: 40,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Welcome message
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppConstants.primaryColor,
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'مرحباً بك!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تم تفعيل الاشتراك: ${authProvider.userEmail}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppConstants.subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Video Selection
            Consumer<VideoProvider>(
              builder: (context, videoProvider, child) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'اختيار الفيديو',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // File picker button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: videoProvider.status == ConversionStatus.processing
                                ? null
                                : () => videoProvider.pickVideo(),
                            icon: const Icon(Icons.video_file),
                            label: Text(
                              videoProvider.selectedVideo == null
                                  ? 'اختر ملف'
                                  : 'تغيير الملف',
                              style: const TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.secondaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        
                        // Selected file name
                        if (videoProvider.selectedVideo != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'تم اختيار: ${videoProvider.videoInfo?.fileName ?? ""}',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Video Info
            Consumer<VideoProvider>(
              builder: (context, videoProvider, child) {
                if (videoProvider.videoInfo != null) {
                  return Column(
                    children: [
                      VideoInfoCard(videoInfo: videoProvider.videoInfo!),
                      const SizedBox(height: 16),
                      VideoRequirementsChecker(videoInfo: videoProvider.videoInfo!),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            // Conversion Button and Status
            Consumer<VideoProvider>(
              builder: (context, videoProvider, child) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    
                    // Conversion Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: videoProvider.selectedVideo == null ||
                                videoProvider.status == ConversionStatus.processing
                            ? null
                            : () => videoProvider.startConversion(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _buildButtonContent(videoProvider),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Status and Progress
                    _buildStatusWidget(videoProvider, context),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Requirements Card
            const RequirementsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonContent(VideoProvider videoProvider) {
    switch (videoProvider.status) {
      case ConversionStatus.idle:
        return const Text(
          'اختر فيديو أولاً',
          style: TextStyle(fontSize: 18, color: Colors.white),
        );
      case ConversionStatus.ready:
        return const Text(
          'بدء التحويل',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        );
      case ConversionStatus.processing:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'جاري التحويل...',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        );
      case ConversionStatus.completed:
        return const Text(
          'تم التحويل بنجاح',
          style: TextStyle(fontSize: 18, color: Colors.white),
        );
      case ConversionStatus.error:
        return const Text(
          'إعادة المحاولة',
          style: TextStyle(fontSize: 18, color: Colors.white),
        );
    }
  }

  Widget _buildStatusWidget(VideoProvider videoProvider, BuildContext context) {
    switch (videoProvider.status) {
      case ConversionStatus.ready:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                '✅ جاهز للتحويل',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
        
      case ConversionStatus.processing:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: videoProvider.progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'التقدم: ${(videoProvider.progress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
        
      case ConversionStatus.completed:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppConstants.primaryColor,
                  size: 40,
                ),
                const SizedBox(height: 8),
                const Text(
                  'تم التحويل بنجاح!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openOutputFolder(videoProvider.outputPath),
                        icon: const Icon(Icons.folder_open),
                        label: const Text('فتح مجلد الحفظ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.secondaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openVideo(videoProvider.outputPath),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('فتح الفيديو'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        
      case ConversionStatus.error:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  videoProvider.errorMessage,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
        
      default:
        return const SizedBox.shrink();
    }
  }

  void _openOutputFolder(String? outputPath) async {
    if (outputPath == null) return;
    
    final directory = Directory(outputPath).parent;
    final uri = Uri.file(directory.path);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openVideo(String? outputPath) async {
    if (outputPath == null) return;
    
    final uri = Uri.file(outputPath);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Provider.of<VideoProvider>(context, listen: false).resetVideo();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (route) => false,
                );
              },
              child: const Text('تسجيل الخروج'),
            ),
          ],
        );
      },
    );
  }
}