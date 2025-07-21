@echo off
echo ========================================
echo    منصة سرعة - إنشاء APK للاختبار
echo ========================================
echo.

echo تحقق من وجود Flutter...
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Flutter غير مثبت أو غير موجود في PATH
    echo.
    echo يرجى تثبيت Flutter أولاً:
    echo 1. تحميل Flutter من: https://flutter.dev/docs/get-started/install/windows
    echo 2. استخراج الملف إلى مجلد مثل C:\flutter
    echo 3. إضافة C:\flutter\bin إلى متغير البيئة PATH
    echo 4. إعادة تشغيل Command Prompt
    echo.
    pause
    exit /b 1
)

echo ✅ Flutter موجود
flutter --version
echo.

echo تحقق من إعدادات Flutter...
flutter doctor
echo.

echo تنظيف المشروع...
flutter clean
echo.

echo تحميل التبعيات...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ فشل في تحميل التبعيات
    pause
    exit /b 1
)
echo.

echo إنشاء مجلد البناء...
if not exist "build" mkdir "build"
if not exist "build\app" mkdir "build\app"
if not exist "build\app\outputs" mkdir "build\app\outputs"
if not exist "build\app\outputs\flutter-apk" mkdir "build\app\outputs\flutter-apk"
echo.

echo بناء APK للاختبار (Debug)...
flutter build apk --debug
if %errorlevel% neq 0 (
    echo ❌ فشل في بناء APK Debug
    pause
    exit /b 1
)
echo.

echo بناء APK للإنتاج (Release)...
flutter build apk --release
if %errorlevel% neq 0 (
    echo ❌ فشل في بناء APK Release
    echo محاولة بناء APK بدون تحسينات...
    flutter build apk --release --no-shrink
)
echo.

echo ========================================
echo           تم إنشاء APK بنجاح! 
echo ========================================
echo.

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ ملف الإنتاج: build\app\outputs\flutter-apk\app-release.apk
    for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do echo    الحجم: %%~zA bytes
)

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ✅ ملف الاختبار: build\app\outputs\flutter-apk\app-debug.apk  
    for %%A in ("build\app\outputs\flutter-apk\app-debug.apk") do echo    الحجم: %%~zA bytes
)

echo.
echo نسخ الملفات إلى مجلد منفصل...
if not exist "APK_Files" mkdir "APK_Files"

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "APK_Files\SR3H-Video-Converter-v2.0.1-Release.apk"
    echo ✅ تم نسخ: APK_Files\SR3H-Video-Converter-v2.0.1-Release.apk
)

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    copy "build\app\outputs\flutter-apk\app-debug.apk" "APK_Files\SR3H-Video-Converter-v2.0.1-Debug.apk"
    echo ✅ تم نسخ: APK_Files\SR3H-Video-Converter-v2.0.1-Debug.apk
)

echo.
echo ========================================
echo            تعليمات التثبيت
echo ========================================
echo.
echo 1. انسخ ملف APK إلى جهاز Android
echo 2. فعل "مصادر غير معروفة" في إعدادات الأمان
echo 3. اضغط على ملف APK لتثبيت التطبيق
echo 4. استخدم البريد: test@example.com للتجربة
echo.
echo ملاحظة: ملف Release أصغر حجماً ومحسن للأداء
echo         ملف Debug أكبر حجماً ويحتوي على معلومات التصحيح
echo.
pause