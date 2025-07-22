@echo off
echo ========================================
echo    بناء APK مع عرض السجلات
echo ========================================
echo.

echo تنظيف المشروع...
C:\flutter\bin\flutter clean
echo.

echo تحميل التبعيات...
C:\flutter\bin\flutter pub get
echo.

echo محاولة بناء APK Debug مع عرض السجلات...
C:\flutter\bin\flutter build apk --debug --verbose > build_log_debug.txt 2>&1

echo فحص نتائج Debug...
if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ✅ Debug APK تم إنشاؤه بنجاح!
    for %%A in ("build\app\outputs\flutter-apk\app-debug.apk") do echo الحجم: %%~zA bytes
    
    if not exist "APK_Ready" mkdir "APK_Ready"
    copy "build\app\outputs\flutter-apk\app-debug.apk" "APK_Ready\SR3H-Debug.apk"
    echo ✅ تم نسخ Debug APK
) else (
    echo ❌ فشل في بناء Debug APK
    echo عرض آخر 20 سطر من سجل الأخطاء:
    powershell -Command "Get-Content 'build_log_debug.txt' | Select-Object -Last 20"
)

echo.
echo محاولة بناء APK Release...
C:\flutter\bin\flutter build apk --release --verbose > build_log_release.txt 2>&1

echo فحص نتائج Release...
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ Release APK تم إنشاؤه بنجاح!
    for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do echo الحجم: %%~zA bytes
    
    if not exist "APK_Ready" mkdir "APK_Ready"
    copy "build\app\outputs\flutter-apk\app-release.apk" "APK_Ready\SR3H-Release.apk"
    echo ✅ تم نسخ Release APK
) else (
    echo ❌ فشل في بناء Release APK
    echo عرض آخر 20 سطر من سجل الأخطاء:
    powershell -Command "Get-Content 'build_log_release.txt' | Select-Object -Last 20"
)

echo.
echo فحص مجلد APK_Ready...
if exist "APK_Ready" (
    echo محتويات مجلد APK_Ready:
    dir "APK_Ready"
) else (
    echo ❌ لم يتم إنشاء أي APK
)

echo.
echo ملفات السجل متوفرة في:
echo - build_log_debug.txt
echo - build_log_release.txt
echo.
pause