@echo off
chcp 65001 >nul
cls
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                🍎 إنشاء تطبيق iOS احترافي                    ║
echo ║              IPA حقيقي - ليس ملف مضغوط                      ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo ✅ مشروعك جاهز 100%% للبناء الاحترافي!
echo.
echo 📋 ما تم إعداده لك:
echo    • GitHub Actions احترافي على macOS حقيقي
echo    • Xcode أحدث إصدار + Flutter 3.24.0  
echo    • بناء IPA حقيقي باستخدام xcodebuild
echo    • حجم طبيعي (30-80 MB) - ليس مضغوط
echo.
echo 🎯 الخطوات المطلوبة (5 دقائق فقط):
echo.
echo 1️⃣ إنشاء Repository على GitHub:
echo    https://github.com/new
echo    الاسم: sr3h-ios-professional
echo    النوع: Public
echo.
echo 2️⃣ رفع الكود (نسخ ولصق):
set /p username="    أدخل اسم المستخدم GitHub: "
if "%username%"=="" (
    echo    ❌ يجب إدخال اسم المستخدم!
    pause
    exit /b 1
)
echo.
echo 🚀 جاري رفع المشروع...
git init 2>nul
git add .
git commit -m "🍎 Professional iOS project - Real IPA build ready" 2>nul
git remote remove origin 2>nul
git remote add origin https://github.com/anamsmmy/sr3h-ios-professional.git
git push -u origin main
if %errorlevel% equ 0 (
    echo ✅ تم رفع المشروع بنجاح!
    echo.
    echo 3️⃣ تشغيل البناء الاحترافي:
    echo    https://github.com/anamsmmy/sr3h-ios-professional
    echo    → Actions → "Build Professional iOS IPA" → Run workflow
    echo.
    echo ⏱️ الوقت: 15-25 دقيقة
    echo 📦 النتيجة: IPA احترافي حقيقي
    echo 🎯 الحجم: 30-80 MB (مبني بـ Xcode الحقيقي)
    echo.
    start https://github.com/anamsmmy/sr3h-ios-professional
) else (
    echo ❌ تأكد من إنشاء repository أولاً!
)
echo.
pause
