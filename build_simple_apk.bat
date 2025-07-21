@echo off
echo ========================================
echo    بناء APK مبسط للاختبار
echo ========================================
echo.

echo نسخ الملفات المبسطة...
copy "pubspec_simple.yaml" "pubspec.yaml"
copy "lib\main_simple.dart" "lib\main.dart"
echo.

echo تنظيف المشروع...
C:\flutter\bin\flutter clean
echo.

echo تحميل التبعيات...
C:\flutter\bin\flutter pub get
echo.

echo بناء APK للاختبار...
C:\flutter\bin\flutter build apk --debug --target-platform android-arm64
echo.

echo فحص النتائج...
if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ✅ تم إنشاء APK بنجاح!
    
    if not exist "APK_Ready" mkdir "APK_Ready"
    copy "build\app\outputs\flutter-apk\app-debug.apk" "APK_Ready\SR3H-Simple-v2.0.1.apk"
    
    echo ✅ APK جاهز في مجلد APK_Ready
    echo الملف: SR3H-Simple-v2.0.1.apk
    
    for %%A in ("APK_Ready\SR3H-Simple-v2.0.1.apk") do echo الحجم: %%~zA bytes
    
    echo.
    echo تعليمات التثبيت:
    echo 1. انسخ الملف إلى جهاز Android
    echo 2. فعل "مصادر غير معروفة" في الإعدادات
    echo 3. اضغط على الملف لتثبيته
    echo 4. استخدم البريد: test@example.com
    
) else (
    echo ❌ فشل في إنشاء APK
    echo محاولة بناء للمنصات المتعددة...
    C:\flutter\bin\flutter build apk --debug
    
    if exist "build\app\outputs\flutter-apk\app-debug.apk" (
        echo ✅ تم إنشاء APK بنجاح (محاولة ثانية)!
        if not exist "APK_Ready" mkdir "APK_Ready"
        copy "build\app\outputs\flutter-apk\app-debug.apk" "APK_Ready\SR3H-Simple-v2.0.1.apk"
        echo ✅ APK جاهز في مجلد APK_Ready
    ) else (
        echo ❌ فشل في إنشاء APK نهائياً
    )
)

echo.
pause