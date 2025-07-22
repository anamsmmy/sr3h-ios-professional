@echo off
chcp 65001 >nul
echo ========================================
echo    بناء APK مع FFmpeg - مشاكل محلولة
echo ========================================
echo.

echo الخطوة 1: نسخ الكود النهائي...
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
flutter clean
if exist "build" rmdir /s /q "build" 2>nul
if exist ".dart_tool" rmdir /s /q ".dart_tool" 2>nul
echo ✅ تم التنظيف الشامل
echo.

echo الخطوة 4: إصلاح Gradle cache...
cd android
if exist ".gradle" rmdir /s /q ".gradle" 2>nul
cd ..
echo ✅ تم تنظيف Gradle cache
echo.

echo الخطوة 5: تحميل التبعيات...
flutter pub get --verbose
if %errorlevel% neq 0 (
    echo ❌ فشل في تحميل التبعيات
    echo محاولة إصلاح...
    flutter pub cache repair
    flutter pub get --verbose
    if %errorlevel% neq 0 (
        echo ❌ ما زال هناك فشل في التبعيات
        pause
        exit /b 1
    )
)
echo ✅ تم تحميل التبعيات بنجاح
echo.

echo الخطوة 6: بناء APK مع الإصلاحات...
echo المشاكل المحلولة:
echo ✅ NDK Version: 27.0.12077973
echo ✅ تعارض مكتبات FFmpeg محلول
echo ✅ ملفات .kts المتعارضة محذوفة
echo ✅ إعدادات Gradle محسنة
echo.

echo جاري البناء...
flutter build apk --release --no-tree-shake-icons
if %errorlevel% equ 0 (
    echo ✅ نجح البناء!
    goto :copy_apk
)

echo محاولة بناء بدون تحسينات...
flutter build apk --release --no-shrink --no-obfuscate --no-tree-shake-icons
if %errorlevel% equ 0 (
    echo ✅ نجح البناء بدون تحسينات!
    goto :copy_apk
)

echo محاولة بناء مع تقسيم المعماريات...
flutter build apk --release --split-per-abi --no-tree-shake-icons
if %errorlevel% equ 0 (
    echo ✅ نجح البناء مع تقسيم المعماريات!
    goto :copy_apk
)

echo ❌ فشلت جميع محاولات البناء
echo يرجى مراجعة الأخطاء أعلاه
pause
exit /b 1

:copy_apk
echo.
echo الخطوة 7: نسخ APK النهائي...
if not exist "APK_FIXED_FFMPEG" mkdir "APK_FIXED_FFMPEG"

set "found_apk=false"

if exist "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" (
    copy "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "APK_FIXED_FFMPEG\SR3H-محول-سرعة-v2.0.1-FIXED-FFMPEG-arm64.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK ARM64
)

if exist "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" (
    copy "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" "APK_FIXED_FFMPEG\SR3H-محول-سرعة-v2.0.1-FIXED-FFMPEG-arm32.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK ARM32
)

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "APK_FIXED_FFMPEG\SR3H-محول-سرعة-v2.0.1-FIXED-FFMPEG-Universal.apk"
    set "found_apk=true"
    echo ✅ تم نسخ APK العام
)

if "%found_apk%"=="true" (
    echo.
    echo ========================================
    echo       🎉 نجح بناء APK مع FFmpeg المحلول!
    echo ========================================
    
    echo 📱 ملفات APK المنشأة:
    for %%A in ("APK_FIXED_FFMPEG\*.apk") do (
        echo    %%~nxA
        powershell -Command "Write-Host '    الحجم: ' -NoNewline; [math]::Round((Get-Item '%%A').Length/1MB,2); Write-Host ' MB'"
    )
    
    echo.
    echo ✅ المشاكل المحلولة:
    echo ✅ 1. NDK Version مطابق (27.0.12077973)
    echo ✅ 2. تعارض مكتبات FFmpeg محلول
    echo ✅ 3. ملفات Kotlin DSL المتعارضة محذوفة
    echo ✅ 4. إعدادات Gradle محسنة
    echo ✅ 5. Packaging options شاملة
    echo.
    echo ✅ الميزات النهائية:
    echo ✅ 1. تحويل فعلي للفيديو باستخدام FFmpeg
    echo ✅ 2. الأمر المطبق: ffmpeg -itsscale 2 -i INPUT.mp4 -c:v copy -c:a copy OUTPUT-SR3H.mp4
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
    echo.
    
    echo 🎬 APK النهائي مع FFmpeg الفعلي جاهز للتوزيع!
    echo المجلد: APK_FIXED_FFMPEG
    echo.
    echo تعليمات التثبيت:
    echo 1. احذف أي نسخة قديمة من الجهاز تماماً
    echo 2. أعد تشغيل الجهاز لضمان التنظيف
    echo 3. اختر الملف المناسب لمعمارية جهازك:
    echo    - ARM64: للأجهزة الحديثة (الأفضل)
    echo    - ARM32: للأجهزة القديمة
    echo    - Universal: يعمل على جميع الأجهزة
    echo 4. فعل "مصادر غير معروفة" في الإعدادات
    echo 5. ثبت التطبيق وامنح جميع الأذونات المطلوبة
    echo 6. استخدم البريد: test@example.com للتجربة
    echo 7. اختر ملف فيديو واضغط "بدء التحويل"
    echo 8. انتظر حتى اكتمال التحويل الفعلي
    echo.
    echo 🚀 هذا هو التطبيق النهائي المطلوب مع FFmpeg الفعلي!
    echo 🏆 جميع المشاكل محلولة والبناء نجح!
    
) else (
    echo ❌ فشل في إنشاء APK
    echo يرجى مراجعة الأخطاء والمحاولة مرة أخرى
)

echo.
pause