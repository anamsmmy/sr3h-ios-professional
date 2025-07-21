@echo off
echo ========================================
echo    بناء APK محسن - جميع التحسينات
echo ========================================
echo.

echo الخطوة 1: نسخ النسخة المحسنة...
copy "lib\main_improved.dart" "lib\main.dart" /Y
echo ✅ تم نسخ الكود المحسن
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
echo.

echo الخطوة 4: تحميل التبعيات...
C:\flutter\bin\flutter pub get
echo.

echo الخطوة 5: بناء APK...
C:\flutter\bin\flutter build apk --release
echo.

echo الخطوة 6: نسخ النتيجة...
if not exist "APK_IMPROVED" mkdir "APK_IMPROVED"

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "APK_IMPROVED\محول-سرعة-v2.0.1-IMPROVED.apk"
    
    for %%A in ("APK_IMPROVED\محول-سرعة-v2.0.1-IMPROVED.apk") do (
        echo ✅ APK محسن تم إنشاؤه بنجاح!
        echo الحجم: %%~zA bytes
        powershell -Command "Write-Host 'الحجم بالميجابايت: ' -NoNewline; [math]::Round(%%~zA/1MB,2)"
        echo التاريخ: %%~tA
    )
    
    echo.
    echo ========================================
    echo         التحسينات المطبقة
    echo ========================================
    echo ✅ 1. شعار أكبر حجماً (150x150)
    echo ✅ 2. خط Tajawal العربي
    echo ✅ 3. نصائح قبل التحويل (دائماً ظاهرة)
    echo ✅ 4. رابط الموقع: www.SR3H.com
    echo ✅ 5. زر "حول" مع تفاصيل كاملة
    echo ✅ 6. عرض حالة التفعيل والبريد
    echo ✅ 7. تحويل مؤقت (محاكاة) مع "-SR3H"
    echo ✅ 8. تحسينات في التصميم والألوان
    echo ✅ 9. رسائل واضحة ومفيدة
    echo ✅ 10. واجهة متجاوبة ومحسنة
    echo.
    
) else (
    echo ❌ فشل في إنشاء APK
)

echo.
pause