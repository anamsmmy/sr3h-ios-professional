# دليل التثبيت والتشغيل - منصة سرعة

## المتطلبات الأساسية

### 1. تثبيت Flutter
```bash
# تحميل Flutter SDK من الموقع الرسمي
https://flutter.dev/docs/get-started/install/windows

# إضافة Flutter إلى PATH
# تأكد من إضافة مجلد flutter/bin إلى متغير البيئة PATH
```

### 2. تثبيت Android Studio
```bash
# تحميل وتثبيت Android Studio
https://developer.android.com/studio

# تثبيت Android SDK
# تثبيت Android SDK Command-line Tools
# تثبيت Android SDK Build-Tools
# تثبيت Android Emulator (اختياري)
```

### 3. إعداد الجهاز
```bash
# للاختبار على جهاز حقيقي:
# - تفعيل وضع المطور
# - تفعيل USB Debugging
# - تثبيت USB drivers

# للاختبار على المحاكي:
# - إنشاء Android Virtual Device (AVD)
# - تشغيل المحاكي
```

## خطوات التثبيت

### 1. إعداد المشروع
```bash
# انتقل إلى مجلد المشروع
cd "m:/SR3H APK/sr3h_video_converter"

# تشغيل سكريبت الإعداد
setup_project.bat

# أو يدوياً:
flutter pub get
flutter doctor
```

### 2. إضافة الأصول المطلوبة
```bash
# انسخ الملفات التالية:
# من: M:\7j\copy2025\logo.png
# إلى: assets/images/logo.png

# من: M:\7j\copy2025\icon.ico  
# إلى: assets/icons/icon.ico
```

### 3. إعداد قاعدة البيانات (Supabase)

#### إنشاء الجدول:
```sql
CREATE TABLE email_subscriptions (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    subscription_start TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### إضافة بيانات تجريبية:
```sql
INSERT INTO email_subscriptions (email, is_active) 
VALUES 
    ('test@example.com', TRUE),
    ('admin@sr3h.com', TRUE),
    ('demo@test.com', TRUE);
```

## التشغيل والاختبار

### 1. التشغيل في وضع التطوير
```bash
# تشغيل سكريبت التطوير
run_dev.bat

# أو يدوياً:
flutter run
```

### 2. بناء APK للإنتاج
```bash
# تشغيل سكريبت البناء
build_apk.bat

# أو يدوياً:
flutter build apk --release
```

### 3. مواقع ملفات APK
```
# ملف الإنتاج:
build/app/outputs/flutter-apk/app-release.apk

# ملف التطوير:
build/app/outputs/flutter-apk/app-debug.apk
```

## اختبار التطبيق

### 1. اختبار التفعيل
- افتح التطبيق
- أدخل بريد إلكتروني مسجل في قاعدة البيانات
- تأكد من ظهور رسالة التفعيل الناجح

### 2. اختبار تحويل الفيديو
- اختر ملف فيديو MP4
- تحقق من ظهور معلومات الفيديو
- اضغط على "بدء التحويل"
- انتظر انتهاء العملية
- تحقق من وجود الملف المحول في مجلد SR3H

### 3. اختبار الأذونات
- تأكد من طلب أذونات الوصول للملفات
- تحقق من إمكانية الوصول لمجلد الحفظ
- اختبر فتح الفيديو المحول

## حل المشاكل الشائعة

### 1. مشاكل Flutter
```bash
# تنظيف المشروع
flutter clean
flutter pub get

# إعادة تشغيل
flutter run
```

### 2. مشاكل Android
```bash
# تحديث Android SDK
flutter doctor --android-licenses

# إعادة بناء المشروع
flutter clean
flutter build apk
```

### 3. مشاكل FFmpeg
```bash
# تأكد من إضافة المكتبة في pubspec.yaml
ffmpeg_kit_flutter: ^6.0.3

# تحديث التبعيات
flutter pub get
```

### 4. مشاكل الأذونات
```xml
<!-- تأكد من وجود الأذونات في AndroidManifest.xml -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
```

## معلومات إضافية

### أوامر مفيدة
```bash
# فحص حالة Flutter
flutter doctor -v

# عرض الأجهزة المتصلة
flutter devices

# تشغيل على جهاز محدد
flutter run -d <device_id>

# بناء APK مع معلومات التصحيح
flutter build apk --debug

# عرض سجلات التطبيق
flutter logs
```

### هيكل المشروع
```
sr3h_video_converter/
├── lib/
│   ├── main.dart
│   ├── providers/
│   ├── screens/
│   ├── widgets/
│   └── utils/
├── android/
├── assets/
├── build/
└── pubspec.yaml
```

## الدعم الفني

للحصول على المساعدة:
- راجع ملف README.md
- تحقق من سجلات الأخطاء
- تواصل مع فريق التطوير

---
© 2025 منصة سرعة - جميع الحقوق محفوظة