@echo off
echo ========================================
echo    بناء APK النهائي مع FFmpeg
echo ========================================
echo.

echo الخطوة 1: نسخ الكود النهائي مع FFmpeg...
copy "lib\main_ffmpeg.dart" "lib\main.dart" /Y
echo ✅ تم نسخ الكود النهائي مع FFmpeg
echo.

echo الخطوة 2: التأكد من الأصول...
if exist "M:\7j\logo.png" (
    copy "M:\7j\logo.png" "assets\images\logo.png" /Y
    echo ✅ تم نسخ الشعار
) else (
    echo ⚠️ ملف الشعار غير موجود
)
echo.

echo الخطوة 3: تنظيف شامل...
C:\flutter\bin\flutter clean
if exist "build" rmdir /s /q "build" 2>nul
echo ✅ تم التنظيف
echo.

echo الخطوة 4: تحميل التبعيات مع FFmpeg...
echo هذا قد يستغرق وقتاً أطول لتحميل FFmpeg...
C:\flutter\bin\flutter pub get
if %errorlevel% neq 0 (
    echo ❌ فشل في تحميل التبعيات
    echo يرجى التحقق من الاتصال بالإنترنت
    pause
    exit /b 1
)
echo ✅ تم تحميل التبعيات بنجاح
echo.

echo الخطوة 5: بناء APK مع FFmpeg...
echo تحذير: هذا قد يستغرق 10-15 دقيقة لأول مرة
echo FFmpeg مكتبة كبيرة وتحتاج وقت للتجميع...
echo.
C:\flutter\bin\flutter build apk --release --verbose
if %errorlevel% neq 0 (
    echo ❌ فشل في بناء APK
    echo محاولة بناء بدون تحسينات...
    C:\flutter\bin\flutter build apk --release --no-shrink --no-obfuscate
)
echo.

echo الخطوة 6: نسخ APK النهائي...
if not exist "APK_FINAL_FFMPEG" mkdir "APK_FINAL_FFMPEG"

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "APK_FINAL_FFMPEG\محول-سرعة-v2.0.1-FFMPEG.apk"
    
    for %%A in ("APK_FINAL_FFMPEG\محول-سرعة-v2.0.1-FFMPEG.apk") do (
        echo ✅ APK النهائي مع FFmpeg تم إنشاؤه بنجاح!
        echo الحجم: %%~zA bytes
        powershell -Command "Write-Host 'الحجم بالميجابايت: ' -NoNewline; [math]::Round(%%~zA/1MB,2)"
        echo التاريخ: %%~tA
    )
    
    echo.
    echo ========================================
    echo         الميزات النهائية
    echo ========================================
    echo ✅ 1. تحويل فعلي للفيديو باستخدام FFmpeg
    echo ✅ 2. الأمر المطبق: ffmpeg -itsscale 2 -i INPUT.mp4 -c:v copy -c:a copy OUTPUT-SR3H.mp4
    echo ✅ 3. شعار أكبر حجماً (150x150)
    echo ✅ 4. خط Tajawal العربي
    echo ✅ 5. نصائح قبل التحويل (دائماً ظاهرة)
    echo ✅ 6. رابط الموقع: www.SR3H.com
    echo ✅ 7. زر "حول" مع تفاصيل كاملة
    echo ✅ 8. عرض حالة التفعيل والبريد
    echo ✅ 9. إضافة "-SR3H" لاسم الملف المحول
    echo ✅ 10. شريط تقدم أثناء التحويل
    echo ✅ 11. رسائل تفصيلية عن نتيجة التحويل
    echo ✅ 12. حفظ الملفات في مجلد SR3H_Converted
    echo ✅ 13. دعم جميع أنواع الفيديو
    echo ✅ 14. أذونات كاملة للوصول للملفات
    echo ✅ 15. واجهة متجاوبة ومحسنة
    echo.
    
    echo 📱 APK النهائي جاهز للتوزيع!
    echo الملف: محول-سرعة-v2.0.1-FFMPEG.apk
    echo المجلد: APK_FINAL_FFMPEG
    echo.
    echo تعليمات التثبيت:
    echo 1. احذف أي نسخة قديمة من الجهاز
    echo 2. انسخ الملف الجديد إلى جهاز Android
    echo 3. فعل "مصادر غير معروفة" في الإعدادات
    echo 4. ثبت التطبيق وامنح جميع الأذونات المطلوبة
    echo 5. استخدم البريد: test@example.com للتجربة
    echo 6. اختر ملف فيديو واضغط "بدء التحويل"
    echo.
    echo ملاحظات مهمة:
    echo - التطبيق يحتاج أذونات الوصول للملفات
    echo - التحويل قد يستغرق وقتاً حسب حجم الفيديو
    echo - الملفات المحولة تحفظ في مجلد SR3H_Converted
    echo - يتم إضافة "-SR3H" لاسم الملف المحول
    echo.
    
) else (
    echo ❌ فشل في إنشاء APK
    echo يرجى مراجعة الأخطاء والمحاولة مرة أخرى
    echo.
    echo نصائح لحل المشاكل:
    echo 1. تأكد من وجود مساحة كافية على القرص الصلب
    echo 2. تأكد من الاتصال بالإنترنت
    echo 3. أعد تشغيل الكمبيوتر وحاول مرة أخرى
    echo 4. تأكد من أن Flutter محدث لآخر إصدار
)

echo.
pause