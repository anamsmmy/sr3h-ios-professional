@echo off
echo ========================================
echo    بناء APK مضمون مع أمر FFmpeg
echo ========================================
echo.

echo نسخ الكود النهائي...
copy "lib\main_final_ffmpeg.dart" "lib\main.dart" /Y

echo نسخ الشعار...
if exist "M:\7j\logo.png" (
    copy "M:\7j\logo.png" "assets\images\logo.png" /Y
)

echo تنظيف وبناء...
C:\flutter\bin\flutter clean
C:\flutter\bin\flutter pub get
C:\flutter\bin\flutter build apk --release

echo نسخ النتيجة...
if not exist "APK_GUARANTEED" mkdir "APK_GUARANTEED"

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "APK_GUARANTEED\محول-سرعة-FFMPEG-FINAL.apk"
    echo ✅ تم إنشاء APK النهائي مع FFmpeg!
) else (
    echo ❌ فشل في البناء
)

pause