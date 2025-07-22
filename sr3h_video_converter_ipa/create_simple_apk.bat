@echo off
setlocal enabledelayedexpansion

echo ========================================
echo    منصة سرعة - إنشاء APK مبسط
echo ========================================
echo.

echo الخطوة 1: تحقق من Flutter...
C:\flutter\bin\flutter --version > flutter_version.txt 2>&1
type flutter_version.txt
echo.

echo الخطوة 2: تنظيف المشروع...
C:\flutter\bin\flutter clean > clean_output.txt 2>&1
type clean_output.txt
echo.

echo الخطوة 3: تحميل التبعيات...
C:\flutter\bin\flutter pub get > pub_get_output.txt 2>&1
type pub_get_output.txt
echo.

echo الخطوة 4: محاولة بناء APK...
echo بناء APK للاختبار...
C:\flutter\bin\flutter build apk --debug > build_debug_output.txt 2>&1
type build_debug_output.txt

echo.
echo فحص النتائج...
if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ✅ تم إنشاء Debug APK بنجاح!
    for %%A in ("build\app\outputs\flutter-apk\app-debug.apk") do echo الحجم: %%~zA bytes
    
    if not exist "APK_Ready" mkdir "APK_Ready"
    copy "build\app\outputs\flutter-apk\app-debug.apk" "APK_Ready\SR3H-Video-Converter-v2.0.1-Debug.apk"
    echo ✅ تم نسخ APK إلى مجلد APK_Ready
) else (
    echo ❌ فشل في إنشاء Debug APK
    echo محاولة بناء بدون تحسينات...
    C:\flutter\bin\flutter build apk --debug --no-shrink > build_debug_no_shrink.txt 2>&1
    type build_debug_no_shrink.txt
)

echo.
echo الخطوة 5: محاولة بناء APK للإنتاج...
C:\flutter\bin\flutter build apk --release > build_release_output.txt 2>&1
type build_release_output.txt

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ تم إنشاء Release APK بنجاح!
    for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do echo الحجم: %%~zA bytes
    
    if not exist "APK_Ready" mkdir "APK_Ready"
    copy "build\app\outputs\flutter-apk\app-release.apk" "APK_Ready\SR3H-Video-Converter-v2.0.1-Release.apk"
    echo ✅ تم نسخ APK إلى مجلد APK_Ready
) else (
    echo ❌ فشل في إنشاء Release APK
)

echo.
echo ========================================
echo              النتائج النهائية
echo ========================================

if exist "APK_Ready" (
    echo محتويات مجلد APK_Ready:
    dir "APK_Ready" /B
    echo.
    echo ✅ ملفات APK جاهزة للاختبار!
    echo المسار: %CD%\APK_Ready\
) else (
    echo ❌ لم يتم إنشاء أي ملفات APK
    echo يرجى مراجعة ملفات السجل أعلاه لمعرفة السبب
)

echo.
echo تعليمات التثبيت:
echo 1. انسخ ملف APK إلى جهاز Android
echo 2. فعل "مصادر غير معروفة" في الإعدادات
echo 3. اضغط على ملف APK لتثبيته
echo 4. استخدم البريد: test@example.com للتجربة
echo.
pause