import 'package:flutter/material.dart';

class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = "https://vogdhlbcgokhqywyhfbn.supabase.co";
  static const String supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZvZ2RobGJjZ29raHF5d3loZmJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzMzkxMTIsImV4cCI6MjA2NzkxNTExMn0.sTd2WCZTGYp5zREcOYNwVia-hS-YKq-yDhi0fnEu_Uc";
  
  // Database
  static const String emailSubscriptionsTable = "email_subscriptions";
  
  // App Info
  static const String appName = "منصة سرعة – تحويل الفيديو إلى 60 إطار";
  static const String appVersion = "2.0.1";
  static const String developerName = "منصة سرعة";
  static const String website = "www.sr3h.com";
  static const String copyright = "© 2025 جميع الحقوق محفوظة";
  
  // Colors
  static const Color primaryColor = Color(0xFF4CAF50); // Green
  static const Color secondaryColor = Color(0xFF2196F3); // Blue
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Gray
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color subtitleColor = Color(0xFF666666);
  
  // FFmpeg Command
  static const String ffmpegCommand = "-itsscale 2 -i INPUT.mp4 -c:v copy -c:a copy OUTPUT-SR3H.mp4";
  
  // Storage
  static const String outputFolderName = "SR3H";
  
  // Video Requirements
  static const List<String> videoRequirements = [
    "أن يكون نوع الفيديو MP4",
    "عرض الفيديو 1080 بكسل",
    "ارتفاع الفيديو 1920 بكسل", 
    "أن يكون الفيديو طولي",
    "أن يكون الفيديو 60 إطار في الثانية",
    "أن لا يحتوي الفيديو على شعار أو حقوق مكتوبة",
    "لأن الخوارزمية قد تحجبه من الاقتراحات"
  ];
  
  static const String videoTip = "💡 نصيحة: تجنب وجود فراغات سوداء في الأعلى أو الأسفل";
  
  // App Description
  static const String appDescription = "برنامج لتحويل الفيديو إلى 60 إطار في الثانية، يساعد على تحويل مقاطع الفيديو العادية إلى فيديوهات سلسة بجودة عالية.";
}