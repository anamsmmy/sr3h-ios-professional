@echo off
chcp 65001 >nul
echo.
echo ========================================
echo 🍎 رفع مشروع iOS الاحترافي إلى GitHub  
echo ========================================
echo.

set /p username="🔑 أدخل اسم المستخدم GitHub: "
if "%username%"=="" (
    echo ❌ يجب إدخال اسم المستخدم!
    pause
    exit /b 1
)

set /p reponame="📝 اسم Repository (افتراضي: sr3h-ios-professional): "
if "%reponame%"=="" set reponame=sr3h-ios-professional

echo.
echo 🚀 بدء رفع المشروع الاحترافي...
echo.

if not exist ".git" (
    echo 📦 إعداد Git...
    git init
    git branch -M main
)

echo 📁 إضافة جميع الملفات...
git add .

echo 💾 حفظ التغييرات...
git commit -m "🍎 Professional iOS project ready for IPA build"

echo 🔗 ربط بـ GitHub...
git remote remove origin 2>nul
git remote add origin https://github.com/%username%/%reponame%.git

echo ⬆️ رفع إلى GitHub...
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ✅ تم رفع المشروع بنجاح!
    echo.
    echo 🎯 الخطوات التالية:
    echo    1. اذهب إلى: https://github.com/%username%/%reponame%
    echo    2. اضغط تبويب Actions
    echo    3. اختر Build Professional iOS IPA
    echo    4. اضغط Run workflow
    echo    5. اختر نوع البناء (development/ad-hoc/app-store)
    echo    6. اضغط Run workflow الأخضر
    echo.
    echo ⏱️ الوقت المتوقع: 15-25 دقيقة
    echo 📦 النتيجة: IPA احترافي حقيقي (30-80 MB)
    echo.
) else (
    echo.
    echo ❌ حدث خطأ أثناء الرفع!
    echo 💡 تأكد من إنشاء repository على GitHub أولاً
    echo.
)

pause
