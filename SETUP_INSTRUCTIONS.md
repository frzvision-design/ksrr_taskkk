# راهنمای نصب و راه‌اندازی پروژه

## مرحله 1️⃣: راه‌اندازی Google Apps Script

### 1. باز کردن Google Apps Script
1. به این لینک بروید: https://docs.google.com/spreadsheets/d/1kbY1V3j2uKmALnd6pWsPW6F9kVecFKnCpnDRLkIKhVo/edit
2. از منوی بالا: **Extensions** > **Apps Script**

### 2. کپی کردن کد
1. محتویات فایل `google_apps_script/Code.gs` را کپی کنید
2. در صفحه Apps Script، کد موجود را پاک کنید
3. کد جدید را Paste کنید
4. روی **Save** (💾) کلیک کنید

### 3. اجرای تابع اولیه (ساخت جداول)
1. از منوی بالا، تابع `initializeSheets` را انتخاب کنید
2. روی **Run** (▶️) کلیک کنید
3. اولین بار از شما مجوز می‌خواهد:
   - **Review permissions** کلیک کنید
   - حساب Google خود را انتخاب کنید
   - **Advanced** > **Go to [Project Name] (unsafe)** کلیک کنید
   - **Allow** را بزنید
4. منتظر بمانید تا اجرا تمام شود (چند ثانیه)
5. به Google Sheet برگردید - باید 3 تب جدید ببینید:
   - ✅ **Users** (با یک کاربر admin پیش‌فرض)
   - ✅ **Tasks**
   - ✅ **Checklist**

### 4. Deploy کردن Web App
1. در Apps Script، روی **Deploy** > **New deployment** کلیک کنید
2. روی آیکون ⚙️ کنار **Select type** کلیک کنید
3. **Web app** را انتخاب کنید
4. تنظیمات زیر را وارد کنید:
   - **Description**: Backend API
   - **Execute as**: Me
   - **Who has access**: Anyone
5. روی **Deploy** کلیک کنید
6. **Web app URL** را کپی کنید (مثل: `https://script.google.com/macros/s/...../exec`)

---

## مرحله 2️⃣: پیکربندی Flutter App

### 1. آپدیت URL در سرویس‌ها
فایل‌های زیر را باز کنید و `YOUR_GOOGLE_APPS_SCRIPT_URL_HERE` را با URL کپی شده جایگزین کنید:

**فایل 1:** `lib/services/sheets_service.dart`
```dart
static const String _scriptUrl = 'WEB_APP_URL_شما';
```

**فایل 2:** `lib/services/checklist_service.dart`
```dart
static const String _scriptUrl = 'WEB_APP_URL_شما';
```

### 2. نصب Dependencies
```bash
flutter pub get
```

---

## مرحله 3️⃣: ساخت APK دیباگ

```bash
flutter build apk --debug
```

فایل APK در مسیر زیر ساخته می‌شود:
```
build/app/outputs/flutter-apk/app-debug.apk
```

---

## 🔐 اطلاعات ورود پیش‌فرض

- **نام کاربری ادمین**: `admin`
- **رمز عبور**: `admin123`

---

## 📋 قابلیت‌های پروژه

### برای ادمین:
- ✅ مدیریت کارمندان (ایجاد، مشاهده)
- ✅ ایجاد تسک و اختصاص به کارمندان
- ✅ مشاهده داشبورد و وضعیت تسک‌ها

### برای کارمند:
- ✅ مشاهده تسک‌های اختصاص داده شده
- ✅ تغییر وضعیت تسک‌ها
- ✅ تایمر شمارش معکوس برای deadline
- ✅ **چک لیست شخصی** (قابلیت جدید! 🎉)
  - افزودن آیتم‌های چک لیست
  - علامت‌گذاری به عنوان انجام شده
  - حذف آیتم‌ها
  - مشاهده پیشرفت

---

## 🐛 عیب‌یابی

### خطای "Invalid credentials"
- مطمئن شوید که تابع `initializeSheets` اجرا شده باشد
- شیت Users را بررسی کنید که کاربر admin وجود دارد

### خطای "Network error"
- URL Web App را دوباره چک کنید
- مطمئن شوید Deploy با تنظیم **Anyone** انجام شده است

### جداول ساخته نشدند
- تابع `initializeSheets` را دوباره اجرا کنید
- Logs را در Apps Script چک کنید

---

## 📱 تست برنامه

1. APK را روی گوشی نصب کنید
2. با `admin` / `admin123` وارد شوید
3. یک کارمند جدید ایجاد کنید
4. یک تسک برای آن کارمند ایجاد کنید
5. خارج شوید و با اکانت کارمند وارد شوید
6. تسک‌ها را مشاهده کنید
7. آیکون چک لیست (✓) را در AppBar بزنید
8. آیتم‌های چک لیست شخصی خود را اضافه کنید

---

✨ **پروژه آماده است!**
