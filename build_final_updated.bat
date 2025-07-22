@echo off
echo ========================================
echo    بناء تطبيق محوّل سرعة - الإصدار المحدث
echo ========================================
echo.

echo 🔧 تنظيف المشروع...
call flutter clean

echo 📦 تحديث Dependencies...
call flutter pub get

echo 🎨 إنشاء أيقونات التطبيق...
python create_app_icons.py

echo 🔨 بناء APK للإنتاج...
call flutter build apk --release --target-platform android-arm64

echo.
echo ========================================
echo ✅ تم بناء التطبيق بنجاح!
echo ========================================
echo.
echo 📱 اسم التطبيق: محوّل سرعة
echo 🎯 الميزات الجديدة:
echo    ✅ Hardware ID ثابت (لا يتغير)
echo    ✅ التحقق كل 24 ساعة فقط
echo    ✅ إخفاء لوحة المفاتيح تلقائياً
echo    ✅ حفظ الفيديو في المعرض - ألبوم SR3H
echo    ✅ أيقونة مخصصة من الصورة المطلوبة
echo    ✅ فتح المعرض مباشرة
echo    ✅ رسائل واضحة ودقيقة
echo.
echo 📁 مكان الملف: build\app\outputs\flutter-apk\app-release.apk
echo.
pause
