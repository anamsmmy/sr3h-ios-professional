@echo off
chcp 65001 >nul
echo ========================================
echo      بناء تطبيق محوّل سرعة النهائي
echo ========================================
echo.

echo الخطوة 1: تنظيف المشروع...
flutter clean
echo ✅ تم تنظيف المشروع
echo.

echo الخطوة 2: تحميل التبعيات...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ فشل في تحميل التبعيات
    pause
    exit /b 1
)
echo ✅ تم تحميل التبعيات بنجاح
echo.

echo الخطوة 3: بناء APK النهائي...
echo تحذير: قد يستغرق 10-15 دقيقة لأول مرة
echo FFmpeg مكتبة كبيرة وتحتاج وقت للتجميع...
echo.

flutter build apk --release --split-per-abi
if %errorlevel% neq 0 (
    echo ❌ فشل في بناء APK مع split-per-abi
    echo محاولة بناء عادي...
    flutter build apk --release
    if %errorlevel% neq 0 (
        echo ❌ فشل في بناء APK
        pause
        exit /b 1
    )
)
echo.

echo الخطوة 4: نسخ APK النهائي...
if not exist "APK_SR3H_FINAL" mkdir "APK_SR3H_FINAL"

set "found_apk=false"

if exist "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" (
    copy "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "APK_SR3H_FINAL\محوّل-سرعة-v2.0.1-arm64.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK ARM64
)

if exist "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" (
    copy "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" "APK_SR3H_FINAL\محوّل-سرعة-v2.0.1-arm32.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK ARM32
)

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "APK_SR3H_FINAL\محوّل-سرعة-v2.0.1.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK العام
)

if "%found_apk%"=="true" (
    echo.
    echo ========================================
    echo           تطبيق SR3H جاهز!
    echo ========================================
    
    for %%A in ("APK_SR3H_FINAL\*.apk") do (
        echo 📱 %%~nxA
        powershell -Command "Write-Host 'الحجم: ' -NoNewline; [math]::Round((Get-Item '%%A').Length/1MB,2); Write-Host ' MB'"
    )
    
    echo.
    echo ✅ الميزات المطبقة:
    echo ✅ 1. تحويل فعلي للفيديو باستخدام FFmpeg
    echo ✅ 2. الأمر المطبق: ffmpeg -itsscale 2 -i INPUT.mp4 -c:v copy -c:a copy OUTPUT-SR3H.mp4
    echo ✅ 3. اسم التطبيق: SR3H
    echo ✅ 4. شعار احترافي
    echo ✅ 5. خط Tajawal العربي
    echo ✅ 6. واجهة محسنة
    echo ✅ 7. رابط الموقع: www.SR3H.com
    echo.
    
    echo 🎬 تطبيق SR3H جاهز للتوزيع!
    echo المجلد: APK_SR3H_FINAL
    echo.
    echo تعليمات التثبيت:
    echo 1. احذف أي نسخة قديمة من الجهاز
    echo 2. انسخ الملف المناسب لجهازك
    echo 3. فعل "مصادر غير معروفة" في الإعدادات
    echo 4. ثبت التطبيق وامنح الأذونات
    echo 5. استخدم البريد: test@example.com للتجربة
    echo.
    echo 🚀 تطبيق SR3H النهائي مكتمل!
    
) else (
    echo ❌ فشل في إنشاء APK
    echo يرجى مراجعة الأخطاء والمحاولة مرة أخرى
)

echo.
echo اضغط أي مفتاح للإغلاق...
pause >nul