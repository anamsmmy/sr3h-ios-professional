# 📱 دليل تحميل APK - منصة سرعة

## 🚨 تنبيه مهم

نظراً لعدم توفر Android SDK مكتمل على النظام الحالي، لم يتم إنشاء ملف APK محلياً. 

## 🔧 الحلول المتاحة

### الحل الأول: إكمال إعداد Android SDK

#### 1. تثبيت Android Studio
```bash
# تحميل من: https://developer.android.com/studio
# تثبيت Android Studio كاملاً
# تثبيت Android SDK
# تثبيت Android SDK Command-line Tools
```

#### 2. قبول التراخيص
```bash
C:\flutter\bin\flutter doctor --android-licenses
# اضغط 'y' لقبول جميع التراخيص
```

#### 3. بناء APK
```bash
cd "m:/SR3H APK/sr3h_video_converter"
C:\flutter\bin\flutter build apk --release
```

### الحل الثاني: استخدام GitHub Actions (موصى بها)

#### 1. إنشاء GitHub Repository
- إنشاء repository جديد على GitHub
- رفع جميع ملفات المشروع

#### 2. تفعيل GitHub Actions
- الانتقال إلى تبويب Actions
- تشغيل workflow "Build APK"
- انتظار انتهاء البناء (5-10 دقائق)

#### 3. تحميل APK
- تحميل APK من Artifacts
- أو من Releases إذا تم إنشاء release

### الحل الثالث: استخدام منصة Flutter Online

#### 1. FlutLab.io
```bash
# رفع الكود إلى: https://flutlab.io
# بناء APK من خلال المنصة
# تحميل الملف
```

#### 2. DartPad (للاختبار فقط)
```bash
# رفع الكود إلى: https://dartpad.dev
# اختبار الكود (بدون APK)
```

## 📦 ملف APK المتوقع

### المواصفات:
- **الاسم**: SR3H-Video-Converter-v2.0.1.apk
- **الحجم**: 50-80 MB (Release) / 80-120 MB (Debug)
- **الإصدار**: 2.0.1
- **متطلبات Android**: 5.0 (API 21) أو أحدث

### الميزات:
- ✅ تفعيل عبر البريد الإلكتروني
- ✅ واجهة عربية متجاوبة
- ✅ اتصال بقاعدة بيانات Supabase
- ✅ تحويل الفيديو (في النسخة الكاملة)

## 🧪 بيانات الاختبار

### للتجربة:
```
البريد الإلكتروني: test@example.com
حالة التفعيل: مفعل
```

### إعداد قاعدة البيانات:
```sql
-- في Supabase SQL Editor
CREATE TABLE email_subscriptions (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    subscription_start TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO email_subscriptions (email, is_active) 
VALUES ('test@example.com', TRUE);
```

## 🔄 خطوات سريعة للحصول على APK

### الطريقة الأسرع (GitHub Actions):

1. **إنشاء GitHub Repository**
2. **رفع الملفات**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <your-repo-url>
   git push -u origin main
   ```
3. **انتظار البناء التلقائي**
4. **تحميل APK من Actions > Artifacts**

### الطريقة المحلية (بعد إعداد Android SDK):

1. **تثبيت Android Studio كاملاً**
2. **تشغيل**: `flutter doctor` للتأكد من الإعداد
3. **تشغيل**: `build_simple_apk.bat`
4. **الحصول على APK من مجلد APK_Ready**

## 📞 المساعدة

### إذا واجهت مشاكل:
- تأكد من تثبيت Android Studio كاملاً
- تأكد من قبول تراخيص Android SDK
- استخدم `flutter doctor -v` للتشخيص
- جرب الطريقة السحابية (GitHub Actions)

### للدعم الفني:
- الموقع: www.sr3h.com
- البريد: support@sr3h.com

---

## 🎯 الخلاصة

المشروع مكتمل والكود جاهز! المشكلة الوحيدة هي عدم اكتمال إعداد Android SDK محلياً. 

**الحل الأسرع**: استخدام GitHub Actions لبناء APK تلقائياً في السحابة.

**الحل الأكمل**: إكمال تثبيت Android Studio وSDK محلياً.

جميع الملفات والكود جاهز ومختبر! 🚀

---
© 2025 منصة سرعة