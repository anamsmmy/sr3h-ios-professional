@echo off
echo ========================================
echo     رفع المشروع إلى GitHub
echo ========================================
echo.

echo هذا السكريبت سيساعدك في رفع المشروع إلى GitHub
echo لبناء APK تلقائياً باستخدام GitHub Actions
echo.

echo الخطوات المطلوبة:
echo.
echo 1. إنشاء GitHub Repository جديد:
echo    - اذهب إلى: https://github.com/new
echo    - اسم المشروع: sr3h-video-converter
echo    - اجعله Public أو Private
echo    - لا تضيف README أو .gitignore
echo.

echo 2. تثبيت Git (إذا لم يكن مثبتاً):
echo    - تحميل من: https://git-scm.com/download/windows
echo    - تثبيت مع الإعدادات الافتراضية
echo.

echo 3. تشغيل الأوامر التالية في Command Prompt:
echo.
echo    cd "m:/SR3H APK/sr3h_video_converter"
echo    git init
echo    git add .
echo    git commit -m "Initial commit - SR3H Video Converter"
echo    git branch -M main
echo    git remote add origin https://github.com/YOUR_USERNAME/sr3h-video-converter.git
echo    git push -u origin main
echo.

echo 4. بعد الرفع:
echo    - اذهب إلى repository على GitHub
echo    - انتقل إلى تبويب Actions
echo    - ستجد workflow "Build APK" يعمل تلقائياً
echo    - انتظر 5-10 دقائق حتى ينتهي البناء
echo    - حمل APK من Artifacts
echo.

echo 5. للحصول على APK:
echo    - Actions > أحدث workflow run
echo    - Artifacts > sr3h-video-converter-release
echo    - حمل الملف وفك الضغط
echo.

echo ملاحظات مهمة:
echo - استبدل YOUR_USERNAME باسم المستخدم الخاص بك
echo - تأكد من أن repository اسمه sr3h-video-converter
echo - GitHub Actions مجاني للمشاريع العامة
echo - APK سيكون جاهز خلال 10 دقائق من الرفع
echo.

echo هل تريد فتح GitHub في المتصفح لإنشاء repository؟
echo اضغط Y للموافقة أو أي مفتاح آخر للإلغاء
set /p choice=

if /i "%choice%"=="Y" (
    start https://github.com/new
    echo تم فتح GitHub في المتصفح
) else (
    echo يمكنك إنشاء repository لاحقاً من: https://github.com/new
)

echo.
echo بعد إنشاء repository، استخدم الأوامر أعلاه لرفع المشروع
echo.
pause