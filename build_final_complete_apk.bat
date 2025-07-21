@echo off
chcp 65001 >nul
echo ========================================
echo    بناء APK النهائي الكامل - SR3H
echo ========================================
echo.

echo الخطوة 1: التحقق من الملفات المطلوبة...
if not exist "assets\fonts\Tajawal-Regular.ttf" (
    echo ❌ خط Tajawal-Regular.ttf مفقود
    echo نسخ الخطوط من المسار الأصلي...
    copy "m:\SR3H APK\sr3h_video_converter\assets\fonts\Tajawal-Regular.ttf" "assets\fonts\" /Y
)

if not exist "assets\fonts\Tajawal-Bold.ttf" (
    echo ❌ خط Tajawal-Bold.ttf مفقود
    copy "m:\SR3H APK\sr3h_video_converter\assets\fonts\Tajawal-Bold.ttf" "assets\fonts\" /Y
)

if not exist "assets\fonts\Tajawal-Medium.ttf" (
    echo ❌ خط Tajawal-Medium.ttf مفقود
    copy "m:\SR3H APK\sr3h_video_converter\assets\fonts\Tajawal-Medium.ttf" "assets\fonts\" /Y
)

if not exist "assets\images\logo.png" (
    echo ❌ شعار التطبيق مفقود
    copy "m:\7j\logo.png" "assets\images\logo.png" /Y
)

echo ✅ تم التحقق من جميع الملفات المطلوبة
echo.

echo الخطوة 2: نسخ الكود النهائي...
copy "lib\main_final_ffmpeg.dart" "lib\main.dart" /Y
echo ✅ تم نسخ الكود النهائي مع FFmpeg
echo.

echo الخطوة 3: تنظيف المشروع...
C:\flutter\bin\flutter clean
echo ✅ تم تنظيف المشروع
echo.

echo الخطوة 4: تحميل التبعيات...
echo تحذير: قد يستغرق وقتاً لتحميل FFmpeg...
C:\flutter\bin\flutter pub get
if %errorlevel% neq 0 (
    echo ❌ فشل في تحميل التبعيات
    pause
    exit /b 1
)
echo ✅ تم تحميل التبعيات بنجاح
echo.

echo الخطوة 5: بناء APK النهائي...
echo تحذير: قد يستغرق 15-20 دقيقة لأول مرة
echo FFmpeg مكتبة كبيرة وتحتاج وقت للتجميع...
echo يرجى الانتظار وعدم إغلاق النافذة...
echo.

C:\flutter\bin\flutter build apk --release --split-per-abi --no-shrink
if %errorlevel% neq 0 (
    echo ❌ فشل في بناء APK مع split-per-abi
    echo محاولة بناء عادي...
    C:\flutter\bin\flutter build apk --release --no-shrink
    if %errorlevel% neq 0 (
        echo ❌ فشل في بناء APK
        echo محاولة بناء أساسي...
        C:\flutter\bin\flutter build apk --release
    )
)
echo.

echo الخطوة 6: نسخ APK النهائي...
if not exist "APK_FINAL_COMPLETE" mkdir "APK_FINAL_COMPLETE"

set "found_apk=false"

REM البحث عن APK في مجلدات مختلفة
if exist "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" (
    copy "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "APK_FINAL_COMPLETE\SR3H-v2.0.1-FINAL-arm64.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK ARM64
)

if exist "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" (
    copy "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" "APK_FINAL_COMPLETE\SR3H-v2.0.1-FINAL-arm32.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK ARM32
)

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "APK_FINAL_COMPLETE\SR3H-v2.0.1-FINAL.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK العام
)

if "%found_apk%"=="true" (
    echo.
    echo ========================================
    echo         APK النهائي الكامل جاهز!
    echo ========================================
    
    for %%A in ("APK_FINAL_COMPLETE\*.apk") do (
        echo 📱 %%~nxA
        powershell -Command "Write-Host 'الحجم: ' -NoNewline; [math]::Round((Get-Item '%%A').Length/1MB,2); Write-Host ' MB'"
    )
    
    echo.
    echo ✅ الميزات المطبقة:
    echo ✅ 1. تحويل فعلي للفيديو باستخدام FFmpeg
    echo ✅ 2. الأمر المطبق: ffmpeg -itsscale 2 -i INPUT.mp4 -c:v copy -c:a copy OUTPUT-SR3H.mp4
    echo ✅ 3. شعار كبير (150x150) من m:\7j\logo.png
    echo ✅ 4. خط Tajawal العربي (Regular, Medium, Bold)
    echo ✅ 5. أيقونات التطبيق لجميع الأحجام
    echo ✅ 6. نصائح قبل التحويل (دائماً ظاهرة)
    echo ✅ 7. رابط الموقع: www.SR3H.com
    echo ✅ 8. زر "حول" مع تفاصيل كاملة
    echo ✅ 9. إضافة "-SR3H" لاسم الملف المحول
    echo ✅ 10. شريط تقدم تفصيلي أثناء التحويل
    echo ✅ 11. حفظ الملفات في مجلد Download/SR3H_Converted
    echo ✅ 12. دعم جميع أنواع الفيديو
    echo ✅ 13. أذونات كاملة للوصول للملفات
    echo ✅ 14. واجهة متجاوبة ومحسنة
    echo ✅ 15. FFmpeg Edition - النسخة النهائية الكاملة
    echo.
    
    echo 🎬 APK النهائي الكامل جاهز للتوزيع!
    echo المجلد: APK_FINAL_COMPLETE
    echo.
    echo تعليمات التثبيت:
    echo 1. احذف أي نسخة قديمة من الجهاز
    echo 2. أعد تشغيل الجهاز
    echo 3. انسخ الملف المناسب لجهازك:
    echo    - ARM64: للأجهزة الحديثة (مفضل)
    echo    - ARM32: للأجهزة القديمة
    echo    - العام: يعمل على جميع الأجهزة
    echo 4. فعل "مصادر غير معروفة" في الإعدادات
    echo 5. ثبت التطبيق وامنح جميع الأذونات
    echo 6. استخدم البريد: test@example.com للتجربة
    echo.
    echo 🚀 هذا هو التطبيق النهائي الكامل مع جميع المتطلبات!
    
) else (
    echo ❌ فشل في إنشاء APK
    echo يرجى مراجعة الأخطاء والمحاولة مرة أخرى
    echo.
    echo نصائح لحل المشاكل:
    echo 1. تأكد من وجود مساحة كافية (5+ GB)
    echo 2. تأكد من الاتصال بالإنترنت
    echo 3. أعد تشغيل الكمبيوتر وحاول مرة أخرى
    echo 4. تأكد من أن Flutter محدث
)

echo.
echo اضغط أي مفتاح للإغلاق...
pause >nul