import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/video_provider.dart';
import '../utils/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'عن البرنامج',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // App Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.video_settings,
                size: 50,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // App Name
            const Text(
              AppConstants.appName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Version
            const Text(
              'الإصدار ${AppConstants.appVersion}',
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.subtitleColor,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Activation Status
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
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: authProvider.isAuthenticated 
                                  ? AppConstants.primaryColor 
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'حالة التفعيل:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: authProvider.isAuthenticated 
                                ? Colors.green.shade50 
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: authProvider.isAuthenticated 
                                  ? Colors.green.shade200 
                                  : Colors.red.shade200,
                            ),
                          ),
                          child: Text(
                            authProvider.isAuthenticated ? 'مفعل' : 'غير مفعل',
                            style: TextStyle(
                              color: authProvider.isAuthenticated 
                                  ? Colors.green.shade700 
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (authProvider.isAuthenticated) ...[
                          const SizedBox(height: 8),
                          Text(
                            'البريد: ${authProvider.userEmail}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppConstants.subtitleColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // App Description
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.description, color: AppConstants.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'وصف البرنامج',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      AppConstants.appDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.subtitleColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'يستخدم البرنامج مكتبة FFmpeg لتحويل الفيديو',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppConstants.subtitleColor,
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
            
            // Developer Info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person, color: AppConstants.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'معلومات المطور',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInfoRow(Icons.business, 'اسم المطور', AppConstants.developerName),
                    const SizedBox(height: 12),
                    
                    _buildInfoRow(Icons.language, 'الموقع الإلكتروني', AppConstants.website, isClickable: true),
                    const SizedBox(height: 12),
                    
                    _buildInfoRow(Icons.copyright, 'الحقوق', AppConstants.copyright),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Statistics
            Consumer<VideoProvider>(
              builder: (context, videoProvider, child) {
                final conversionCount = videoProvider.getConversionCount();
                final lastConversionPath = videoProvider.getLastConversionPath();
                
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.analytics, color: AppConstants.primaryColor),
                            SizedBox(width: 8),
                            Text(
                              'إحصائيات الاستخدام',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildInfoRow(Icons.video_library, 'عدد الفيديوهات المحولة', '$conversionCount فيديو'),
                        
                        if (lastConversionPath != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.folder, 'آخر مجلد حفظ', lastConversionPath.split('/').last),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            // Contact Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _launchWebsite(),
                icon: const Icon(Icons.web),
                label: const Text(
                  'زيارة الموقع الإلكتروني',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isClickable = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppConstants.subtitleColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textColor,
                ),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: isClickable ? () => _launchWebsite() : null,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isClickable ? AppConstants.secondaryColor : AppConstants.subtitleColor,
                    decoration: isClickable ? TextDecoration.underline : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _launchWebsite() async {
    final uri = Uri.parse('https://${AppConstants.website}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}