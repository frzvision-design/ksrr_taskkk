# 📱 سیستم مدیریت خدمات دانشجویی

یک اپلیکیشن Flutter کامل برای مدیریت وظایف و چک‌لیست‌های دانشجویی با پشتیبانی از Android، iOS و Web.

## ✨ ویژگی‌ها

- 🔐 **سیستم احراز هویت** - ورود امن با نقش‌های مختلف (مدیر و کارمند)
- 📋 **مدیریت وظایف** - ایجاد، ویرایش و پیگیری وظایف
- ✅ **چک‌لیست شخصی** - چک‌لیست‌های اختصاصی برای هر کاربر
- 🌐 **پشتیبانی کامل از زبان فارسی** - رابط کاربری راست‌چین
- 📱 **Responsive Design** - طراحی واکنش‌گرا برای موبایل، تبلت و دسکتاپ
- ☁️ **Backend Supabase** - دیتابیس و احراز هویت ابری
- 🎨 **Material Design 3** - طراحی مدرن و زیبا

## 🔧 پیش‌نیازها

- Flutter SDK 3.0.0 یا بالاتر
- Dart SDK 3.0.0 یا بالاتر
- Android Studio / VS Code
- حساب Supabase (رایگان)

## 🚀 نصب و راه‌اندازی

### 1. کلون کردن پروژه

```bash
git clone https://github.com/frzvision-design/ksrr_taskkk.git
cd ksrr_taskkk
```

### 2. نصب وابستگی‌ها

```bash
flutter pub get
```

### 3. راه‌اندازی Supabase

1. به [Supabase](https://supabase.com) بروید و یک پروژه جدید بسازید
2. در SQL Editor فایل `supabase_setup.sql` را اجرا کنید
3. Project URL و Anon Key خود را از تنظیمات پروژه کپی کنید
4. فایل `lib/services/supabase_service.dart` را باز کنید و مقادیر زیر را جایگزین کنید:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 4. اجرای پروژه

#### موبایل (Android/iOS):
```bash
flutter run
```

#### وب:
```bash
flutter run -d chrome
```

#### بیلد برای پروداکشن:

**Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

**Web:**
```bash
flutter build web --release --web-renderer canvaskit
```

## 👥 اطلاعات ورود پیش‌فرض

### مدیر:
- **نام کاربری:** `admin`
- **رمز عبور:** `admin123`

### کارمند 1:
- **نام کاربری:** `ali`
- **رمز عبور:** `1234`

### کارمند 2:
- **نام کاربری:** `sara`
- **رمز عبور:** `1234`

## 📦 وابستگی‌های اصلی

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.5.6
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  http: ^1.1.0
  shamsi_date: ^1.0.0
  intl: ^0.20.2
  flutter_local_notifications: ^16.3.0
  google_fonts: ^6.1.0
```

## 🏗️ ساختار پروژه

```
lib/
├── main.dart                 # نقطه ورود برنامه
├── models/                   # مدل‌های داده
│   ├── user_model.dart
│   ├── task_model.dart
│   └── checklist_item_model.dart
├── screens/                  # صفحات رابط کاربری
│   ├── login_screen.dart
│   ├── admin/               # صفحات مدیر
│   └── employee/            # صفحات کارمند
├── services/                # سرویس‌های Backend
│   ├── supabase_service.dart
│   ├── auth_service.dart
│   ├── sheets_service.dart
│   └── local_data_service.dart
├── providers/               # State Management
│   ├── auth_provider.dart
│   └── task_provider.dart
├── widgets/                 # کامپوننت‌های قابل استفاده مجدد
└── utils/                   # توابع کمکی و تم
```

## 🔄 CI/CD

پروژه دارای دو GitHub Actions workflow است:

1. **Android Build** (`android.yml`) - بیلد APK/AAB
2. **Web Deploy** (`web-deploy.yml`) - بیلد و دیپلوی روی GitHub Pages

برای فعال‌سازی GitHub Pages:
1. به Settings > Pages بروید
2. Source را روی `gh-pages` branch تنظیم کنید
3. بعد از هر push به main، نسخه وب به‌روز می‌شود

## 🐛 عیب‌یابی

### خطای Supabase Connection
- مطمئن شوید URL و Key صحیح هستند
- بررسی کنید که Row Level Security غیرفعال باشد

### خطای Build در Android
- مطمئن شوید Java 17 نصب است
- `flutter clean && flutter pub get` را اجرا کنید

### خطای Web CORS
- در Supabase، origin را به لیست مجاز اضافه کنید

## 📝 لایسنس

این پروژه تحت لایسنس MIT منتشر شده است.

## 🤝 مشارکت

Pull Request ها و Issue ها خوشامد هستند!

## 📧 تماس

برای سوالات و پشتیبانی، لطفاً یک Issue باز کنید.

---

ساخته شده با ❤️ توسط [FRZ Vision Design](https://github.com/frzvision-design)
