# دليل البدء السريع - منصة سرعة

## 🚀 البدء السريع

### 1. التحضير
```bash
# تأكد من تثبيت Flutter
flutter --version

# انتقل إلى مجلد المشروع
cd "m:/SR3H APK/sr3h_video_converter"

# تشغيل سكريبت الإعداد
setup_project.bat
```

### 2. إضافة الأصول
```bash
# انسخ الملفات التالية:
copy "M:\7j\copy2025\logo.png" "assets\images\logo.png"
copy "M:\7j\copy2025\icon.ico" "assets\icons\icon.ico"
```

### 3. إعداد قاعدة البيانات
```sql
-- في Supabase SQL Editor
CREATE TABLE email_subscriptions (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    subscription_start TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- إضافة بيانات تجريبية
INSERT INTO email_subscriptions (email, is_active) 
VALUES ('test@example.com', TRUE);
```

### 4. التشغيل
```bash
# للتطوير
run_dev.bat

# أو
flutter run

# لبناء APK
build_apk.bat

# أو
flutter build apk --release
```

## 📱 اختبار التطبيق

### 1. اختبار التفعيل
- افتح التطبيق
- أدخل: `test@example.com`
- يجب أن يتم التفعيل بنجاح

### 2. اختبار التحويل
- اختر ملف فيديو MP4
- اضغط "بدء التحويل"
- انتظر انتهاء العملية
- تحقق من مجلد SR3H

## 🔧 حل المشاكل السريع

### مشكلة: Flutter غير معرف
```bash
# أضف Flutter إلى PATH
# أو استخدم المسار الكامل
C:\flutter\bin\flutter run
```

### مشكلة: خطأ في الأذونات
```xml
<!-- تأكد من وجود الأذونات في AndroidManifest.xml -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### مشكلة: خطأ في Supabase
- تحقق من صحة URL و API Key
- تأكد من إنشاء الجدول
- تحقق من الاتصال بالإنترنت

### مشكلة: خطأ في FFmpeg
```bash
# تنظيف وإعادة بناء
flutter clean
flutter pub get
flutter build apk
```

## 📂 هيكل المشروع

```
sr3h_video_converter/
├── lib/
│   ├── main.dart              # نقطة البداية
│   ├── providers/             # إدارة الحالة
│   ├── screens/               # الشاشات
│   ├── widgets/               # المكونات
│   └── utils/                 # الأدوات المساعدة
├── android/                   # إعدادات Android
├── assets/                    # الأصول (صور، أيقونات)
├── build/                     # ملفات البناء
└── pubspec.yaml              # التبعيات
```

## 🎯 الميزات الرئيسية

- ✅ تفعيل عبر البريد الإلكتروني
- ✅ تحويل فيديو إلى 60 FPS
- ✅ واجهة عربية متجاوبة
- ✅ فحص متطلبات الفيديو
- ✅ حفظ في مجلد مخصص
- ✅ إحصائيات الاستخدام

## 📞 الدعم

للمساعدة السريعة:
1. راجع ملف INSTALLATION.md
2. تحقق من سجلات الأخطاء
3. زر موقع www.sr3h.com

---
© 2025 منصة سرعة