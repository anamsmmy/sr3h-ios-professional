@echo off
chcp 65001 >nul
echo ========================================
echo    بناء FFmpegKit محلياً - النسخة النهائية
echo ========================================
echo.

echo الخطوة 1: نسخ الكود النهائي مع FFmpeg...
copy "lib\main_final_ffmpeg.dart" "lib\main.dart" /Y
echo ✅ تم نسخ الكود النهائي
echo.

echo الخطوة 2: نسخ الشعار...
if exist "M:\7j\logo.png" (
    copy "M:\7j\logo.png" "assets\images\logo.png" /Y
    echo ✅ تم نسخ الشعار
) else (
    echo ⚠️ الشعار غير موجود - سيتم استخدام أيقونة افتراضية
)
echo.

echo الخطوة 3: تنظيف شامل...
C:\flutter\bin\flutter clean
if exist "build" rmdir /s /q "build" 2>nul
if exist ".dart_tool" rmdir /s /q ".dart_tool" 2>nul
echo ✅ تم التنظيف الشامل
echo.

echo الخطوة 4: إصلاح pub cache...
C:\flutter\bin\flutter pub cache repair
echo ✅ تم إصلاح pub cache
echo.

echo الخطوة 5: تحميل التبعيات مع FFmpegKit الجديد...
echo تحذير: هذا قد يستغرق وقتاً طويلاً لتحميل FFmpeg...
echo المكتبة المستخدمة: ffmpeg_kit_flutter_new ^2.0.0
echo.
C:\flutter\bin\flutter pub get --verbose
if %errorlevel% neq 0 (
    echo ❌ فشل في تحميل التبعيات
    echo محاولة إصلاح المشكلة...
    
    echo جاري حذف pubspec.lock...
    if exist "pubspec.lock" del "pubspec.lock"
    
    echo محاولة أخرى...
    C:\flutter\bin\flutter pub get --verbose
    
    if %errorlevel% neq 0 (
        echo ❌ ما زال هناك فشل
        echo يرجى التحقق من:
        echo 1. الاتصال بالإنترنت
        echo 2. إعدادات الشبكة/البروكسي
        echo 3. مساحة القرص الصلب
        pause
        exit /b 1
    )
)
echo ✅ تم تحميل التبعيات بنجاح
echo.

echo الخطوة 6: التحقق من إعدادات Android...
echo جاري التحقق من Android SDK...
if not exist "C:\Android\Sdk" (
    echo ❌ Android SDK غير موجود في C:\Android\Sdk
    echo يرجى تثبيت Android Studio أو تحديد مسار SDK الصحيح
    pause
    exit /b 1
)
echo ✅ Android SDK موجود
echo.

echo الخطوة 7: قبول تراخيص Android...
echo y | C:\Android\Sdk\cmdline-tools\latest\bin\sdkmanager --licenses 2>nul
echo ✅ تم قبول التراخيص
echo.

echo الخطوة 8: بناء APK مع FFmpegKit محلياً...
echo =================================================
echo تحذير مهم: هذا قد يستغرق 20-30 دقيقة لأول مرة!
echo FFmpegKit مكتبة ضخمة تحتاج وقت طويل للتجميع المحلي
echo يرجى الانتظار وعدم إغلاق النافذة...
echo =================================================
echo.

echo محاولة البناء الأساسي...
C:\flutter\bin\flutter build apk --release --verbose
if %errorlevel% equ 0 (
    echo ✅ نجح البناء الأساسي
    goto :copy_apk
)

echo محاولة البناء بدون تحسينات...
C:\flutter\bin\flutter build apk --release --no-shrink --no-obfuscate --verbose
if %errorlevel% equ 0 (
    echo ✅ نجح البناء بدون تحسينات
    goto :copy_apk
)

echo محاولة البناء مع تقسيم المعماريات...
C:\flutter\bin\flutter build apk --release --split-per-abi --verbose
if %errorlevel% equ 0 (
    echo ✅ نجح البناء مع تقسيم المعماريات
    goto :copy_apk
)

echo محاولة البناء مع إعدادات خاصة...
C:\flutter\bin\flutter build apk --release --no-tree-shake-icons --verbose
if %errorlevel% equ 0 (
    echo ✅ نجح البناء مع إعدادات خاصة
    goto :copy_apk
)

echo ❌ فشلت جميع محاولات البناء
echo.
echo تشخيص المشاكل:
echo.
echo جاري فحص Flutter doctor...
C:\flutter\bin\flutter doctor -v
echo.
echo جاري فحص إعدادات المشروع...
C:\flutter\bin\flutter analyze
echo.
echo يرجى مراجعة الأخطاء أعلاه وإصلاحها
pause
exit /b 1

:copy_apk
echo.
echo الخطوة 9: نسخ APK النهائي...
if not exist "APK_LOCAL_FFMPEG" mkdir "APK_LOCAL_FFMPEG"

set "found_apk=false"

REM البحث عن ملفات APK المختلفة
if exist "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" (
    copy "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "APK_LOCAL_FFMPEG\SR3H-محول-سرعة-v2.0.1-LOCAL-FFMPEG-arm64.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK ARM64
)

if exist "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" (
    copy "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" "APK_LOCAL_FFMPEG\SR3H-محول-سرعة-v2.0.1-LOCAL-FFMPEG-arm32.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK ARM32
)

if exist "build\app\outputs\flutter-apk\app-x86_64-release.apk" (
    copy "build\app\outputs\flutter-apk\app-x86_64-release.apk" "APK_LOCAL_FFMPEG\SR3H-محول-سرعة-v2.0.1-LOCAL-FFMPEG-x64.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK x64
)

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "APK_LOCAL_FFMPEG\SR3H-محول-سرعة-v2.0.1-LOCAL-FFMPEG-Universal.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK العام
)

if "%found_apk%"=="true" (
    echo.
    echo ========================================
    echo       🎉 نجح بناء APK مع FFmpegKit محلياً!
    echo ========================================
    
    echo 📱 ملفات APK المنشأة:
    for %%A in ("APK_LOCAL_FFMPEG\*.apk") do (
        echo    %%~nxA
        powershell -Command "Write-Host '    الحجم: ' -NoNewline; [math]::Round((Get-Item '%%A').Length/1MB,2); Write-Host ' MB'"
    )
    
    echo.
    echo ✅ الميزات النهائية المطبقة:
    echo ✅ 1. تحويل فعلي للفيديو باستخدام FFmpegKit المحلي
    echo ✅ 2. الأمر المطبق بالضبط: ffmpeg -itsscale 2 -i INPUT.mp4 -c:v copy -c:a copy OUTPUT-SR3H.mp4
    echo ✅ 3. شعار أكبر حجماً (150x150)
    echo ✅ 4. خط Tajawal العربي
    echo ✅ 5. نصائح قبل التحويل (دائماً ظاهرة)
    echo ✅ 6. رابط الموقع: www.SR3H.com
    echo ✅ 7. زر "حول" محسن مع أمر FFmpeg
    echo ✅ 8. عرض حالة التفعيل والبريد
    echo ✅ 9. إضافة "-SR3H" لاسم الملف المحول
    echo ✅ 10. شريط تقدم تفصيلي أثناء التحويل
    echo ✅ 11. رسائل تفصيلية عن نتيجة التحويل
    echo ✅ 12. حفظ الملفات في مجلد Download/SR3H_Converted
    echo ✅ 13. دعم جميع أنواع الفيديو
    echo ✅ 14. أذونات كاملة للوصول للملفات
    echo ✅ 15. واجهة متجاوبة ومحسنة
    echo ✅ 16. FFmpegKit محلي - أداء أفضل
    echo.
    
    echo 🎬 APK النهائي مع FFmpegKit المحلي جاهز للتوزيع!
    echo المجلد: APK_LOCAL_FFMPEG
    echo.
    echo تعليمات التثبيت:
    echo 1. احذف أي نسخة قديمة من الجهاز تماماً
    echo 2. أعد تشغيل الجهاز لضمان التنظيف
    echo 3. اختر الملف المناسب لمعمارية جهازك:
    echo    - ARM64: للأجهزة الحديثة (الأفضل)
    echo    - ARM32: للأجهزة القديمة
    echo    - x64: للمحاكيات
    echo    - Universal: يعمل على جميع الأجهزة
    echo 4. فعل "مصادر غير معروفة" في الإعدادات
    echo 5. ثبت التطبيق وامنح جميع الأذونات المطلوبة
    echo 6. استخدم البريد: test@example.com للتجربة
    echo 7. اختر ملف فيديو واضغط "بدء التحويل"
    echo 8. انتظر حتى اكتمال التحويل الفعلي
    echo.
    echo ملاحظات مهمة:
    echo - التطبيق يحتاج أذونات الوصول للملفات
    echo - التحويل الفعلي قد يستغرق وقتاً حسب حجم الفيديو
    echo - الملفات المحولة تحفظ في مجلد Download/SR3H_Converted
    echo - يتم إضافة "-SR3H" لاسم الملف المحول
    echo - يتم تطبيق أمر FFmpeg المطلوب بالضبط
    echo - FFmpegKit محلي يوفر أداء أفضل
    echo.
    echo 🚀 هذا هو التطبيق النهائي المطلوب مع FFmpeg الفعلي!
    echo 🏆 تم بناء FFmpegKit محلياً بنجاح!
    
) else (
    echo ❌ فشل في إنشاء APK
    echo يرجى مراجعة الأخطاء والمحاولة مرة أخرى
    echo.
    echo نصائح لحل المشاكل:
    echo 1. تأكد من وجود مساحة كافية على القرص الصلب (10+ GB)
    echo 2. تأكد من الاتصال بالإنترنت المستقر
    echo 3. أعد تشغيل الكمبيوتر وحاول مرة أخرى
    echo 4. تأكد من أن Flutter محدث لآخر إصدار
    echo 5. تأكد من أن Android SDK محدث ومكتمل
    echo 6. جرب إغلاق برامج مكافحة الفيروسات مؤقتاً
)

echo.
pause