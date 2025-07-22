@echo off
echo ========================================
echo    منصة سرعة - بناء APK الآن
echo ========================================
echo.

echo تحقق من Flutter...
C:\flutter\bin\flutter --version
if %errorlevel% neq 0 (
    echo ❌ خطأ في Flutter
    pause
    exit /b 1
)
echo.

echo تحقق من إعدادات Flutter...
C:\flutter\bin\flutter doctor
echo.

echo تنظيف المشروع...
C:\flutter\bin\flutter clean
echo.

echo تحميل التبعيات...
C:\flutter\bin\flutter pub get
if %errorlevel% neq 0 (
    echo ❌ فشل في تحميل التبعيات
    pause
    exit /b 1
)
echo.

echo إنشاء مجلدات البناء...
if not exist "build" mkdir "build"
if not exist "APK_Output" mkdir "APK_Output"
echo.

echo بناء APK للاختبار (Debug)...
C:\flutter\bin\flutter build apk --debug
if %errorlevel% neq 0 (
    echo ❌ فشل في بناء Debug APK
) else (
    echo ✅ تم بناء Debug APK بنجاح
    if exist "build\app\outputs\flutter-apk\app-debug.apk" (
        copy "build\app\outputs\flutter-apk\app-debug.apk" "APK_Output\SR3H-Video-Converter-Debug.apk"
        echo ✅ تم نسخ Debug APK إلى APK_Output
    )
)
echo.

echo بناء APK للإنتاج (Release)...
C:\flutter\bin\flutter build apk --release
if %errorlevel% neq 0 (
    echo ❌ فشل في بناء Release APK
    echo محاولة بناء بدون تحسينات...
    C:\flutter\bin\flutter build apk --release --no-shrink
) else (
    echo ✅ تم بناء Release APK بنجاح
    if exist "build\app\outputs\flutter-apk\app-release.apk" (
        copy "build\app\outputs\flutter-apk\app-release.apk" "APK_Output\SR3H-Video-Converter-Release.apk"
        echo ✅ تم نسخ Release APK إلى APK_Output
    )
)
echo.

echo فحص الملفات المنشأة...
if exist "APK_Output" (
    echo محتويات مجلد APK_Output:
    dir "APK_Output"
) else (
    echo ❌ لم يتم إنشاء مجلد APK_Output
)

if exist "build\app\outputs\flutter-apk" (
    echo محتويات مجلد flutter-apk:
    dir "build\app\outputs\flutter-apk"
) else (
    echo ❌ لم يتم إنشاء مجلد flutter-apk
)
echo.

echo ========================================
echo              انتهى البناء
echo ========================================
pause