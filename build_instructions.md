# تعليمات بناء APK - منصة سرعة

## 📱 إنشاء ملف APK

نظراً لأن Flutter غير مثبت على النظام الحالي، إليك الطرق المختلفة لإنشاء ملف APK:

### الطريقة الأولى: تثبيت Flutter وبناء APK

#### 1. تثبيت Flutter
```bash
# تحميل Flutter SDK من:
https://docs.flutter.dev/get-started/install/windows

# استخراج الملف إلى مجلد مثل:
C:\flutter

# إضافة Flutter إلى PATH:
# إضافة C:\flutter\bin إلى متغير البيئة PATH
```

#### 2. تثبيت Android Studio
```bash
# تحميل وتثبيت Android Studio من:
https://developer.android.com/studio

# تثبيت Android SDK
# تثبيت Android SDK Command-line Tools
```

#### 3. بناء APK
```bash
# انتقل إلى مجلد المشروع
cd "m:/SR3H APK/sr3h_video_converter"

# تنظيف المشروع
flutter clean

# تحميل التبعيات
flutter pub get

# بناء APK للإنتاج
flutter build apk --release

# بناء APK للاختبار
flutter build apk --debug
```

### الطريقة الثانية: استخدام GitHub Actions (موصى بها)

#### 1. رفع المشروع إلى GitHub
```bash
# إنشاء repository جديد على GitHub
# رفع جميع ملفات المشروع
```

#### 2. إعداد GitHub Actions
سأقوم بإنشاء ملف workflow للبناء التلقائي.

### الطريقة الثالثة: استخدام Flutter Online

#### 1. DartPad أو FlutLab
- رفع الكود إلى منصة Flutter online
- بناء APK من خلال المنصة

## 📋 متطلبات النظام

### للتطوير المحلي:
- Windows 10/11
- Flutter SDK 3.0+
- Android Studio
- Android SDK (API 21+)
- Java JDK 8+

### للبناء السحابي:
- حساب GitHub
- إعداد GitHub Actions

## 🔧 حل المشاكل

### مشكلة: Flutter غير معرف
```bash
# تأكد من إضافة Flutter إلى PATH
echo $env:PATH
# يجب أن يحتوي على مسار Flutter

# أو استخدم المسار الكامل
C:\flutter\bin\flutter --version
```

### مشكلة: Android SDK غير موجود
```bash
# تأكد من تثبيت Android Studio
# تأكد من تثبيت Android SDK
# تأكد من قبول التراخيص
flutter doctor --android-licenses
```

## 📦 ملفات APK المتوقعة

بعد البناء الناجح، ستجد الملفات في:

```
build/app/outputs/flutter-apk/
├── app-release.apk          # للإنتاج (موقع)
├── app-debug.apk            # للاختبار
└── app-profile.apk          # للتحليل
```

## 🚀 اختبار APK

### على الجهاز الحقيقي:
1. تفعيل "مصادر غير معروفة" في إعدادات الأمان
2. نسخ ملف APK إلى الجهاز
3. تثبيت التطبيق
4. اختبار جميع الوظائف

### على المحاكي:
```bash
# تشغيل المحاكي
emulator -avd <avd_name>

# تثبيت APK
adb install app-release.apk
```

## 📞 الدعم

إذا واجهت مشاكل في البناء:
1. تأكد من تثبيت جميع المتطلبات
2. راجع ملف INSTALLATION.md
3. تحقق من سجلات الأخطاء
4. استخدم `flutter doctor -v` للتشخيص

---
© 2025 منصة سرعة