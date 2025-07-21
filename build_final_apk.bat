@echo off
echo ========================================
echo    بناء APK النهائي - محّول سرعة
echo ========================================
echo.

echo الخطوة 1: نسخ الملفات النهائية...
copy "lib\main_final.dart" "lib\main.dart" /Y
echo ✅ تم نسخ الكود النهائي
echo.

echo الخطوة 2: التأكد من وجود الأصول...
if not exist "assets\images" mkdir "assets\images"
if not exist "assets\fonts" mkdir "assets\fonts"

if exist "M:\7j\logo.png" (
    copy "M:\7j\logo.png" "assets\images\logo.png" /Y
    echo ✅ تم نسخ الشعار
) else (
    echo ⚠️ ملف الشعار غير موجود في M:\7j\logo.png
)

if exist "M:\7j\800x800.png" (
    copy "M:\7j\800x800.png" "assets\images\app_icon.png" /Y
    echo ✅ تم نسخ أيقونة التطبيق
) else (
    echo ⚠️ ملف الأيقونة غير موجود في M:\7j\800x800.png
)

echo.
echo الخطوة 3: تنظيف شامل للمشروع...
C:\flutter\bin\flutter clean
if exist "build" rmdir /s /q "build" 2>nul
echo.

echo الخطوة 4: تحميل التبعيات الجديدة...
C:\flutter\bin\flutter pub get
if %errorlevel% neq 0 (
    echo ❌ فشل في تحميل التبعيات
    pause
    exit /b 1
)
echo.

echo الخطوة 5: بناء APK النهائي...
echo هذا قد يستغرق عدة دقائق...
C:\flutter\bin\flutter build apk --release --verbose
if %errorlevel% neq 0 (
    echo ❌ فشل في بناء APK
    echo محاولة بناء بدون تحسينات...
    C:\flutter\bin\flutter build apk --release --no-shrink --no-obfuscate
)
echo.

echo الخطوة 6: نسخ APK النهائي...
if not exist "APK_RELEASE" mkdir "APK_RELEASE"

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ APK النهائي تم إنشاؤه بنجاح!
    copy "build\app\outputs\flutter-apk\app-release.apk" "APK_RELEASE\محول-سرعة-v2.0.1-FINAL.apk"
    
    for %%A in ("APK_RELEASE\محول-سرعة-v2.0.1-FINAL.apk") do (
        echo    الحجم: %%~zA bytes
        echo    الحجم بالميجابايت: 
        powershell -Command "[math]::Round(%%~zA/1MB,2)"
    )
    
    echo ✅ APK جاهز في مجلد APK_RELEASE
) else (
    echo ❌ فشل في إنشاء APK
    echo يرجى مراجعة الأخطاء أعلاه
)

echo.
echo ========================================
echo         الميزات الجديدة المضافة
echo ========================================
echo ✅ 1. تحويل فعلي للفيديو باستخدام FFmpeg
echo ✅ 2. خط Tajawal العربي
echo ✅ 3. شعار أكبر وأوضح
echo ✅ 4. نصائح قبل التحويل
echo ✅ 5. رابط الموقع: www.SR3H.com
echo ✅ 6. زر "حول" مع تفاصيل التطبيق
echo ✅ 7. عرض حالة التفعيل والبريد
echo ✅ 8. إضافة "-SR3H" لاسم الملف المحول
echo ✅ 9. شريط تقدم أثناء التحويل
echo ✅ 10. تحسينات في التصميم والواجهة
echo.

if exist "APK_RELEASE" (
    echo 📱 APK النهائي جاهز للتوزيع!
    echo الملف: محول-سرعة-v2.0.1-FINAL.apk
    echo المجلد: APK_RELEASE
    echo.
    echo تعليمات التثبيت:
    echo 1. احذف النسخة القديمة من الجهاز
    echo 2. انسخ الملف الجديد إلى جهاز Android
    echo 3. فعل "مصادر غير معروفة" في الإعدادات
    echo 4. ثبت التطبيق وامنح الأذونات المطلوبة
    echo 5. استخدم البريد: test@example.com للتجربة
    echo.
    echo ملاحظة: التطبيق يحتاج أذونات الوصول للملفات لحفظ الفيديو المحول
) else (
    echo ❌ لم يتم إنشاء APK
    echo يرجى مراجعة الأخطاء والمحاولة مرة أخرى
)

echo.
pause