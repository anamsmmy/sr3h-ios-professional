@echo off
chcp 65001 >nul
echo.
echo ========================================
echo 🍎 رفع مشروع iOS إلى GitHub
echo ========================================
echo.

echo 📋 تأكد من إنشاء repository على GitHub أولاً:
echo    https://github.com/new
echo    الاسم: sr3h-video-converter-ios
echo    النوع: Public
echo.

set /p username="🔑 أدخل اسم المستخدم GitHub: "
if "%username%"=="" (
    echo ❌ يجب إدخال اسم المستخدم!
    pause
    exit /b 1
)

echo.
echo 🚀 بدء رفع الكود...
echo.

REM Initialize git if not already done
if not exist ".git" (
    echo 📦 إعداد Git...
    git init
    git branch -M main
)

REM Add all files
echo 📁 إضافة الملفات...
git add .

REM Commit changes
echo 💾 حفظ التغييرات...
git commit -m "iOS app ready - محوّل سرعة SR3H v2.0.6"

REM Add remote origin
echo 🔗 ربط بـ GitHub...
git remote remove origin 2>nul
git remote add origin https://github.com/%username%/sr3h-video-converter-ios.git

REM Push to GitHub
echo ⬆️ رفع إلى GitHub...
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ✅ تم رفع الكود بنجاح!
    echo.
    echo 🎯 الخطوات التالية:
    echo    1. اذهب إلى: https://github.com/%username%/sr3h-video-converter-ios
    echo    2. اضغط تبويب "Actions"
    echo    3. اختر "🍎 Build iOS IPA"
    echo    4. اضغط "Run workflow"
    echo    5. اختر "development"
    echo    6. اضغط "Run workflow"
    echo.
    echo 📱 ستحصل على IPA في 10-15 دقيقة!
    echo.
) else (
    echo.
    echo ❌ حدث خطأ أثناء الرفع!
    echo 💡 تأكد من:
    echo    - إنشاء repository على GitHub
    echo    - صحة اسم المستخدم
    echo    - اتصال الإنترنت
    echo.
)

pause