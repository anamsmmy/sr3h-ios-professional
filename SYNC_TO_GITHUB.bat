@echo off
chcp 65001 >nul
echo.
echo ========================================
echo 🔄 مزامنة التحديثات مع GitHub
echo ========================================
echo.

:: التحقق من وجود Git
git --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Git غير مثبت أو غير موجود في PATH
    echo يرجى تثبيت Git أولاً من: https://git-scm.com
    pause
    exit /b 1
)

echo ✅ Git متوفر
echo.

:: إضافة جميع الملفات
echo 📁 إضافة الملفات المحدثة...
git add .

:: إنشاء commit
echo 💾 إنشاء commit جديد...
git commit -m "🚀 SR3H v2.0.8 - تحديثات شاملة

✨ الميزات الجديدة:
• 🎨 أيقونة التطبيق الجديدة من 800x800.png
• ⌨️ إخفاء لوحة المفاتيح تلقائياً بعد التفعيل
• 📱 حفظ الفيديو في معرض الصور مباشرة (ألبوم SR3H)
• 🏷️ اسم التطبيق: 'محوّل سرعة'
• 🔐 Hardware ID ثابت لا يتغير
• ⏰ التحقق مرة واحدة كل 24 ساعة
• 📂 فتح المعرض بعد التحويل
• 💬 رسائل إرشادية محسّنة ودقيقة

🔧 الإصلاحات:
• حل مشكلة Hardware ID المتغير
• إصلاح مسار حفظ الفيديو
• تحسين تجربة المستخدم
• رسائل خطأ أكثر وضوحاً

📱 جاهز لبناء IPA v2.0.8"

if errorlevel 1 (
    echo ⚠️ لا توجد تغييرات جديدة للـ commit
) else (
    echo ✅ تم إنشاء commit بنجاح
)

:: رفع التحديثات
echo 🚀 رفع التحديثات إلى GitHub...
git push origin main

if errorlevel 1 (
    echo ❌ فشل في رفع التحديثات
    echo يرجى التحقق من:
    echo   • الاتصال بالإنترنت
    echo   • صلاحيات GitHub
    echo   • إعدادات المستودع
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✅ تم رفع التحديثات بنجاح!
echo ========================================
echo.
echo 🔗 المستودع: https://github.com/anamsmmy/sr3h-ios-professional/
echo 📱 الإصدار: v2.0.8
echo.
echo 🎯 الخطوة التالية:
echo   1. اذهب إلى GitHub Actions
echo   2. شغّل workflow "Build Professional iOS IPA"
echo   3. حمّل ملف IPA من Artifacts
echo.
pause