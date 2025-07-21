# 🏗️ دليل بناء FFmpegKit محلياً باستخدام Android Studio

## 📋 المتطلبات الأساسية:

### 1. تثبيت Android Studio:
- تحميل من: https://developer.android.com/studio
- تثبيت Android SDK (API 34)
- تثبيت Android NDK (أحدث إصدار)
- تثبيت CMake

### 2. تثبيت Flutter:
- تحميل من: https://flutter.dev/docs/get-started/install
- إضافة Flutter إلى PATH
- تشغيل `flutter doctor` للتأكد من الإعداد

### 3. متطلبات النظام:
- **مساحة القرص:** 15+ GB متاحة
- **الذاكرة:** 8+ GB RAM
- **المعالج:** متعدد النوى (مفضل)
- **الاتصال:** إنترنت سريع ومستقر

## 🚀 طريقة البناء باستخدام Android Studio:

### الخطوة 1: فتح المشروع
```bash
# افتح Android Studio
# اختر "Open an existing project"
# انتقل إلى: m:/SR3H APK/sr3h_video_converter
# اختر مجلد android
```

### الخطوة 2: إعداد المشروع
1. انتظر حتى يكتمل تحميل Gradle
2. تأكد من إعدادات SDK:
   - File → Project Structure → SDK Location
   - تأكد من مسار Android SDK
   - تأكد من مسار Android NDK

### الخطوة 3: تحديث التبعيات
```bash
# في Terminal داخل Android Studio:
cd ..
flutter clean
flutter pub get
```

### الخطوة 4: إعداد FFmpegKit
1. تأكد من أن `pubspec.yaml` يحتوي على:
```yaml
dependencies:
  ffmpeg_kit_flutter_new: ^2.0.0
```

2. في Terminal:
```bash
flutter pub get --verbose
```

### الخطوة 5: بناء APK
```bash
# الطريقة الأولى: من Terminal
flutter build apk --release --verbose

# الطريقة الثانية: من Android Studio
# Build → Flutter → Build APK
```

### الخطوة 6: بناء متقدم (إذا فشلت الطريقة الأولى)
```bash
# بناء مع تقسيم المعماريات
flutter build apk --release --split-per-abi

# بناء بدون تحسينات
flutter build apk --release --no-shrink --no-obfuscate

# بناء مع إعدادات مخصصة
flutter build apk --release --no-tree-shake-icons
```

## 🔧 حل المشاكل الشائعة:

### مشكلة 1: فشل تحميل FFmpegKit
**الحل:**
```bash
flutter pub cache repair
flutter clean
flutter pub get --verbose
```

### مشكلة 2: خطأ في NDK
**الحل:**
1. افتح Android Studio
2. Tools → SDK Manager → SDK Tools
3. تأكد من تثبيت NDK (Side by side)
4. أعد تشغيل Android Studio

### مشكلة 3: نفاد الذاكرة أثناء البناء
**الحل:**
1. أغلق البرامج غير الضرورية
2. زيد حجم heap في `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
```

### مشكلة 4: بطء البناء
**الحل:**
1. فعل Gradle daemon:
```properties
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.configureondemand=true
```

2. استخدم SSD إذا كان متاحاً
3. أغلق مكافح الفيروسات مؤقتاً

## 📱 بناء APK محسن:

### للأجهزة الحديثة (ARM64):
```bash
flutter build apk --release --target-platform android-arm64
```

### للأجهزة القديمة (ARM32):
```bash
flutter build apk --release --target-platform android-arm
```

### للمحاكيات (x64):
```bash
flutter build apk --release --target-platform android-x64
```

### بناء جميع المعماريات:
```bash
flutter build apk --release --split-per-abi
```

## 🎯 التحقق من نجاح البناء:

### مكان ملفات APK:
```
build/app/outputs/flutter-apk/
├── app-arm64-v8a-release.apk     (ARM64)
├── app-armeabi-v7a-release.apk   (ARM32)
├── app-x86_64-release.apk        (x64)
└── app-release.apk               (Universal)
```

### التحقق من FFmpegKit:
1. ثبت APK على جهاز Android
2. افتح التطبيق
3. فعل باستخدام: test@example.com
4. اختر ملف فيديو
5. اضغط "بدء التحويل"
6. تأكد من ظهور رسائل FFmpeg في الـ logs

## 🔍 تشخيص المشاكل:

### فحص Flutter:
```bash
flutter doctor -v
flutter analyze
```

### فحص التبعيات:
```bash
flutter pub deps
flutter pub outdated
```

### فحص APK:
```bash
# حجم APK
ls -lh build/app/outputs/flutter-apk/

# محتويات APK
unzip -l build/app/outputs/flutter-apk/app-release.apk | grep ffmpeg
```

## 🚀 سكريبت بناء شامل:

```bash
#!/bin/bash
# build_complete.sh

echo "🏗️ بناء APK مع FFmpegKit محلياً..."

# تنظيف
flutter clean
rm -rf build/
rm -rf .dart_tool/

# إصلاح cache
flutter pub cache repair

# تحميل التبعيات
flutter pub get --verbose

# بناء APK
flutter build apk --release --split-per-abi --verbose

# التحقق من النتائج
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "✅ نجح البناء!"
    ls -lh build/app/outputs/flutter-apk/
else
    echo "❌ فشل البناء!"
    exit 1
fi
```

## 📊 مقارنة الطرق:

| الطريقة | الوقت | الحجم | الأداء | الصعوبة |
|---------|-------|-------|---------|----------|
| Flutter CLI | 15-20 دقيقة | 40-60 MB | عالي | متوسط |
| Android Studio | 20-25 دقيقة | 40-60 MB | عالي | سهل |
| Gradle مباشرة | 25-30 دقيقة | 35-55 MB | أعلى | صعب |

## 🎯 النصائح النهائية:

1. **استخدم SSD** لتسريع البناء
2. **أغلق البرامج غير الضرورية** لتوفير الذاكرة
3. **استخدم اتصال إنترنت سريع** لتحميل التبعيات
4. **فعل Developer Mode** على جهاز Android للاختبار
5. **احتفظ بنسخة احتياطية** من APK الناجح

## 🏆 النتيجة المتوقعة:

**APK كامل مع FFmpegKit محلي** يطبق الأمر المطلوب:
```bash
ffmpeg -itsscale 2 -i INPUT.mp4 -c:v copy -c:a copy OUTPUT-SR3H.mp4
```

مع جميع الميزات المطلوبة وأداء محسن!

---
© 2025 دليل بناء FFmpegKit محلياً - منصة سرعة