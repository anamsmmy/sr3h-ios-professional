@echo off
echo ========================================
echo    إنشاء أيقونات التطبيق
echo ========================================
echo.

echo نسخ الأيقونة الأساسية...
if exist "M:\7j\800x800.png" (
    copy "M:\7j\800x800.png" "assets\images\app_icon.png"
    echo ✅ تم نسخ الأيقونة الأساسية
) else (
    echo ❌ ملف الأيقونة غير موجود في M:\7j\800x800.png
    pause
    exit /b 1
)

echo.
echo إنشاء مجلدات الأيقونات...
if not exist "android\app\src\main\res\mipmap-hdpi" mkdir "android\app\src\main\res\mipmap-hdpi"
if not exist "android\app\src\main\res\mipmap-mdpi" mkdir "android\app\src\main\res\mipmap-mdpi"
if not exist "android\app\src\main\res\mipmap-xhdpi" mkdir "android\app\src\main\res\mipmap-xhdpi"
if not exist "android\app\src\main\res\mipmap-xxhdpi" mkdir "android\app\src\main\res\mipmap-xxhdpi"
if not exist "android\app\src\main\res\mipmap-xxxhdpi" mkdir "android\app\src\main\res\mipmap-xxxhdpi"

echo.
echo نسخ الأيقونة لجميع المقاسات...
copy "M:\7j\800x800.png" "android\app\src\main\res\mipmap-hdpi\ic_launcher.png"
copy "M:\7j\800x800.png" "android\app\src\main\res\mipmap-mdpi\ic_launcher.png"
copy "M:\7j\800x800.png" "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png"
copy "M:\7j\800x800.png" "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png"
copy "M:\7j\800x800.png" "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png"

echo ✅ تم إنشاء أيقونات التطبيق بجميع المقاسات

echo.
echo ملاحظة: للحصول على أفضل جودة، يُنصح بتحويل الأيقونة
echo إلى المقاسات المناسبة لكل مجلد:
echo - mdpi: 48x48
echo - hdpi: 72x72  
echo - xhdpi: 96x96
echo - xxhdpi: 144x144
echo - xxxhdpi: 192x192
echo.
echo يمكنك استخدام أدوات مثل:
echo - https://appicon.co
echo - https://icon.kitchen
echo - أو Photoshop/GIMP
echo.
pause