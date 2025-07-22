@echo off
chcp 65001 >nul
echo.
echo ========================================
echo 🍎 بناء تطبيق محوّل سرعة iOS v2.0.8
echo ========================================
echo.

:: التحقق من وجود Flutter
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter غير مثبت أو غير موجود في PATH
    echo يرجى تثبيت Flutter أولاً من: https://flutter.dev
    pause
    exit /b 1
)

echo ✅ Flutter متوفر
echo.

:: تنظيف المشروع
echo 🧹 تنظيف المشروع...
flutter clean
if errorlevel 1 (
    echo ❌ فشل في تنظيف المشروع
    pause
    exit /b 1
)

:: تحديث التبعيات
echo 📦 تحديث التبعيات...
flutter pub get
if errorlevel 1 (
    echo ❌ فشل في تحديث التبعيات
    pause
    exit /b 1
)

:: بناء iOS
echo 🔨 بناء تطبيق iOS...
flutter build ios --release --no-codesign
if errorlevel 1 (
    echo ❌ فشل في بناء التطبيق
    pause
    exit /b 1
)

:: إنشاء مجلد IPA
echo 📁 إنشاء مجلد IPA...
if not exist "IPA_OUTPUT" mkdir IPA_OUTPUT
if not exist "IPA_OUTPUT\Payload" mkdir IPA_OUTPUT\Payload

:: نسخ التطبيق
echo 📱 نسخ ملفات التطبيق...
xcopy "build\ios\Release-iphoneos\Runner.app" "IPA_OUTPUT\Payload\Runner.app" /E /I /Y
if errorlevel 1 (
    echo ❌ فشل في نسخ ملفات التطبيق
    pause
    exit /b 1
)

:: إنشاء ملف IPA
echo 📦 إنشاء ملف IPA...
cd IPA_OUTPUT
powershell -Command "Compress-Archive -Path 'Payload' -DestinationPath 'SR3H_Video_Converter_v2.0.8_unsigned.zip' -Force"
if errorlevel 1 (
    echo ❌ فشل في إنشاء ملف ZIP
    cd ..
    pause
    exit /b 1
)

:: إعادة تسمية إلى IPA
ren "SR3H_Video_Converter_v2.0.8_unsigned.zip" "SR3H_Video_Converter_v2.0.8_unsigned.ipa"
cd ..

echo.
echo ========================================
echo ✅ تم بناء التطبيق بنجاح!
echo ========================================
echo.
echo 📱 ملف IPA: IPA_OUTPUT\SR3H_Video_Converter_v2.0.8_unsigned.ipa
echo.
echo 🔧 التحسينات الجديدة في v2.0.8:
echo   ✅ أيقونة التطبيق الجديدة
echo   ✅ إخفاء لوحة المفاتيح تلقائياً
echo   ✅ حفظ الفيديو في المعرض مباشرة
echo   ✅ اسم التطبيق: "محوّل سرعة"
echo   ✅ Hardware ID ثابت لا يتغير
echo   ✅ التحقق مرة واحدة كل 24 ساعة
echo   ✅ فتح المعرض بعد التحويل
echo   ✅ رسائل إرشادية محسّنة
echo.
echo 📋 طرق التثبيت:
echo   • AltStore
echo   • Sideloadly  
echo   • 3uTools
echo   • TrollStore (إذا متوفر)
echo.
echo 🎉 استمتع بالتطبيق المحسّن!
echo.
pause