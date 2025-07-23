# 🚀 تعليمات بناء ملف IPA - SR3H Video Converter

## 📋 نظرة عامة

تم إعداد GitHub Actions لبناء ملف IPA تلقائياً باستخدام macOS. اتبع هذه الخطوات للحصول على ملف IPA جاهز للتثبيت.

## 🔧 طريقة تشغيل GitHub Actions

### الطريقة 1: تشغيل تلقائي
GitHub Actions سيعمل تلقائياً عند:
- Push جديد إلى branch main
- Pull request جديد
- أي تحديث في الكود

### الطريقة 2: تشغيل يدوي
1. اذهب إلى: https://github.com/anamsmmy/sr3h-ios-professional/actions
2. اختر "Build iOS IPA" من قائمة Workflows
3. اضغط على "Run workflow"
4. اختر branch "main"
5. اضغط "Run workflow" الأخضر

## 📥 تحميل ملف IPA

### بعد اكتمال البناء:

1. **من صفحة Actions:**
   - اذهب إلى https://github.com/anamsmmy/sr3h-ios-professional/actions
   - اختر آخر workflow مكتمل (✅ أخضر)
   - انزل إلى قسم "Artifacts"
   - اضغط على "SR3H_Video_Converter_IPA"
   - سيتم تحميل ملف ZIP يحتوي على IPA

2. **من صفحة Releases:**
   - اذهب إلى https://github.com/anamsmmy/sr3h-ios-professional/releases
   - ستجد إصدار جديد "v2.0.8"
   - حمل ملف `SR3H_Video_Converter_v2.0.8.ipa`

## 📱 تثبيت ملف IPA

### الطريقة 1: AltStore
1. حمل AltStore من الموقع الرسمي
2. ثبت AltStore على الكمبيوتر والجهاز
3. اسحب ملف IPA إلى AltStore
4. ثبت التطبيق

### الطريقة 2: Sideloadly
1. حمل Sideloadly من الموقع الرسمي
2. وصل جهاز iOS بالكمبيوتر
3. اسحب ملف IPA إلى Sideloadly
4. أدخل Apple ID وكلمة المرور
5. ثبت التطبيق

### الطريقة 3: 3uTools
1. حمل 3uTools
2. وصل الجهاز
3. اذهب إلى Apps > Install Local App
4. اختر ملف IPA
5. ثبت التطبيق

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