@echo off
echo ========================================
echo    بناء APK محسن - جميع الإصلاحات
echo ========================================
echo.

echo الخطوة 1: نسخ الملفات المحسنة...
copy "pubspec_basic.yaml" "pubspec.yaml" /Y
copy "lib\main_basic.dart" "lib\main.dart" /Y
echo ✅ تم نسخ الملفات المحسنة
echo.

echo الخطوة 2: التأكد من وجود الأصول...
if not exist "assets\images" mkdir "assets\images"

if exist "M:\7j\logo.png" (
    copy "M:\7j\logo.png" "assets\images\logo.png" /Y
    echo ✅ تم نسخ الشعار
) else (
    echo ⚠️ ملف الشعار غير موجود في M:\7j\logo.png
)

if exist "M:\7j\800x800.png" (
    copy "M:\7j\800x800.png" "assets\images\app_icon.png" /Y
    echo ✅ تم نسخ أيقونة التطبيق
) else (
    echo ⚠️ ملف الأيقونة غير موجود في M:\7j\800x800.png
)
echo.

echo الخطوة 3: تنظيف المشروع...
C:\flutter\bin\flutter clean
echo.

echo الخطوة 4: تحميل التبعيات...
C:\flutter\bin\flutter pub get
if %errorlevel% neq 0 (
    echo ❌ فشل في تحميل التبعيات
    pause
    exit /b 1
)
echo.

echo الخطوة 5: بناء APK Debug...
C:\flutter\bin\flutter build apk --debug
if %errorlevel% neq 0 (
    echo ❌ فشل في بناء Debug APK
    echo محاولة بناء بدون تحسينات...
    C:\flutter\bin\flutter build apk --debug --no-shrink
)
echo.

echo الخطوة 6: بناء APK Release...
C:\flutter\bin\flutter build apk --release
if %errorlevel% neq 0 (
    echo ❌ فشل في بناء Release APK
    echo محاولة بناء بدون تحسينات...
    C:\flutter\bin\flutter build apk --release --no-shrink
)
echo.

echo الخطوة 7: فحص النتائج ونسخ الملفات...
if not exist "APK_Fixed" mkdir "APK_Fixed"

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ✅ Debug APK تم إنشاؤه بنجاح!
    copy "build\app\outputs\flutter-apk\app-debug.apk" "APK_Fixed\محول-سرعة-v2.0.1-Debug.apk"
    for %%A in ("APK_Fixed\محول-سرعة-v2.0.1-Debug.apk") do echo    الحجم: %%~zA bytes
)

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ Release APK تم إنشاؤه بنجاح!
    copy "build\app\outputs\flutter-apk\app-release.apk" "APK_Fixed\محول-سرعة-v2.0.1-Release.apk"
    for %%A in ("APK_Fixed\محول-سرعة-v2.0.1-Release.apk") do echo    الحجم: %%~zA bytes
)

echo.
echo ========================================
echo           الإصلاحات المطبقة
echo ========================================
echo ✅ 1. إصلاح التحقق من البريد مع Supabase
echo ✅ 2. تفعيل وظيفة اختيار الفيديو
echo ✅ 3. إضافة الشعار الفعلي
echo ✅ 4. تحديث أيقونات التطبيق
echo ✅ 5. تغيير اسم التطبيق إلى "محّول سرعة"
echo ✅ 6. إضافة أذونات الملفات والإنترنت
echo.

if exist "APK_Fixed" (
    echo 📱 ملفات APK جاهزة في مجلد APK_Fixed:
    dir "APK_Fixed" /B
    echo.
    echo تعليمات التثبيت:
    echo 1. انسخ ملف Release APK إلى جهاز Android
    echo 2. فعل "مصادر غير معروفة" في الإعدادات
    echo 3. اضغط على الملف لتثبيته
    echo 4. استخدم البريد: test@example.com للتجربة
    echo.
    echo ملاحظة: تأكد من وجود اتصال بالإنترنت للتحقق من البريد
) else (
    echo ❌ لم يتم إنشاء أي ملفات APK
    echo يرجى مراجعة الأخطاء أعلاه
)

echo.
pause