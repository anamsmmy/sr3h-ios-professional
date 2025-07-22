@echo off
echo ========================================
echo    بناء APK النهائي مع FFmpeg الفعلي
echo ========================================
echo.

echo الخطوة 1: نسخ الكود النهائي مع FFmpeg...
copy "lib\main_final_ffmpeg.dart" "lib\main.dart" /Y
echo ✅ تم نسخ الكود النهائي مع FFmpeg الفعلي
echo.

echo الخطوة 2: التأكد من الأصول...
if exist "M:\7j\logo.png" (
    copy "M:\7j\logo.png" "assets\images\logo.png" /Y
    echo ✅ تم نسخ الشعار
) else (
    echo ⚠️ ملف الشعار غير موجود - سيتم استخدام أيقونة افتراضية
)
echo.

echo الخطوة 3: تنظيف شامل...
C:\flutter\bin\flutter clean
echo ✅ تم التنظيف
echo.

echo الخطوة 4: تحميل التبعيات مع FFmpeg...
echo تحذير: هذا قد يستغرق وقتاً أطول لتحميل FFmpeg...
C:\flutter\bin\flutter pub get
if %errorlevel% neq 0 (
    echo ❌ فشل في تحميل التبعيات
    pause
    exit /b 1
)
echo ✅ تم تحميل التبعيات بنجاح
echo.

echo الخطوة 5: بناء APK مع FFmpeg الفعلي...
echo تحذير: هذا قد يستغرق 15-20 دقيقة لأول مرة
echo FFmpeg مكتبة كبيرة جداً وتحتاج وقت للتجميع...
echo يرجى الانتظار وعدم إغلاق النافذة...
echo.

C:\flutter\bin\flutter build apk --release --split-per-abi
if %errorlevel% neq 0 (
    echo ❌ فشل في بناء APK مع split-per-abi
    echo محاولة بناء عادي...
    C:\flutter\bin\flutter build apk --release
    if %errorlevel% neq 0 (
        echo ❌ فشل في بناء APK
        echo محاولة بناء بدون تحسينات...
        C:\flutter\bin\flutter build apk --release --no-shrink --no-obfuscate
    )
)
echo.

echo الخطوة 6: نسخ APK النهائي...
if not exist "APK_ULTIMATE_FFMPEG" mkdir "APK_ULTIMATE_FFMPEG"

set "found_apk=false"

REM البحث عن APK في مجلدات مختلفة
if exist "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" (
    copy "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "APK_ULTIMATE_FFMPEG\محول-سرعة-v2.0.1-ULTIMATE-arm64.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK ARM64
)

if exist "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" (
    copy "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" "APK_ULTIMATE_FFMPEG\محول-سرعة-v2.0.1-ULTIMATE-arm32.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK ARM32
)

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "APK_ULTIMATE_FFMPEG\محول-سرعة-v2.0.1-ULTIMATE.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK العام
)

if "%found_apk%"=="true" (
    echo.
    echo ========================================
    echo         APK النهائي مع FFmpeg الفعلي
    echo ========================================
    
    for %%A in ("APK_ULTIMATE_FFMPEG\*.apk") do (
        echo 📱 %%~nxA
        powershell -Command "Write-Host 'الحجم: ' -NoNewline; [math]::Round((Get-Item '%%A').Length/1MB,2); Write-Host ' MB'"
    )
    
    echo.
    echo ✅ الميزات النهائية المطبقة:
    echo ✅ 1. تحويل فعلي للفيديو باستخدام FFmpeg
    echo ✅ 2. الأمر المطبق بالضبط: ffmpeg -itsscale 2 -i INPUT.mp4 -c:v copy -c:a copy OUTPUT-SR3H.mp4
    echo ✅ 3. شعار أكبر حجماً (150x150)
    echo ✅ 4. خط Tajawal العربي
    echo ✅ 5. نصائح قبل التحويل (دائماً ظاهرة)
    echo ✅ 6. رابط الموقع: www.SR3H.com
    echo ✅ 7. زر "حول" مع تفاصيل كاملة وأمر FFmpeg
    echo ✅ 8. عرض حالة التفعيل والبريد
    echo ✅ 9. إضافة "-SR3H" لاسم الملف المحول
    echo ✅ 10. شريط تقدم تفصيلي أثناء التحويل
    echo ✅ 11. رسائل تفصيلية عن نتيجة التحويل
    echo ✅ 12. حفظ الملفات في مجلد Download/SR3H_Converted
    echo ✅ 13. دعم جميع أنواع الفيديو
    echo ✅ 14. أذونات كاملة للوصول للملفات
    echo ✅ 15. واجهة متجاوبة ومحسنة
    echo ✅ 16. FFmpeg Edition - النسخة النهائية
    echo.
    
    echo 🎬 APK النهائي مع FFmpeg الفعلي جاهز للتوزيع!
    echo المجلد: APK_ULTIMATE_FFMPEG
    echo.
    echo تعليمات التثبيت والاستخدام:
    echo 1. احذف أي نسخة قديمة من الجهاز تماماً
    echo 2. أعد تشغيل الجهاز لضمان التنظيف
    echo 3. انسخ الملف المناسب لمعمارية جهازك:
    echo    - ARM64: للأجهزة الحديثة (مفضل)
    echo    - ARM32: للأجهزة القديمة
    echo    - العام: يعمل على جميع الأجهزة
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
    echo.
    echo 🚀 هذا هو التطبيق النهائي المطلوب مع FFmpeg الفعلي!
    
) else (
    echo ❌ فشل في إنشاء APK
    echo يرجى مراجعة الأخطاء والمحاولة مرة أخرى
    echo.
    echo نصائح لحل المشاكل:
    echo 1. تأكد من وجود مساحة كافية على القرص الصلب (5+ GB)
    echo 2. تأكد من الاتصال بالإنترنت المستقر
    echo 3. أعد تشغيل الكمبيوتر وحاول مرة أخرى
    echo 4. تأكد من أن Flutter محدث لآخر إصدار
    echo 5. تأكد من أن Android SDK محدث
)

echo.
pause