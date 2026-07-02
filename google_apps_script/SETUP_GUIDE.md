# راهنمای راه‌اندازی Google Apps Script

این راهنما به شما کمک می‌کند تا Google Apps Script را برای پروژه خود راه‌اندازی کنید.

## مرحله ۱: باز کردن Google Sheets

1. لینک Google Sheet خود را باز کنید:
   ```
   https://docs.google.com/spreadsheets/d/1kbY1V3j2uKmALnd6pWsPW6F9kVecFKnCpnDRLkIKhVo/edit
   ```

## مرحله ۲: باز کردن Script Editor

1. در Google Sheet، از منوی بالا گزینه **Extensions** > **Apps Script** را انتخاب کنید
2. یک پنجره جدید باز می‌شود که محیط برنامه‌نویسی Apps Script است

## مرحله ۳: کپی کردن کد

1. محتویات فایل `Code.gs` را کامل کپی کنید
2. در Script Editor، همه محتوای موجود را پاک کنید
3. کد کپی شده را Paste کنید
4. روی دکمه **Save** (💾) کلیک کنید یا از کیبورد `Ctrl+S` استفاده کنید

## مرحله ۴: اجرای اولیه (Initialize)

1. در بالای Script Editor، از منوی کشویی تابع `initializeSheets` را انتخاب کنید
2. روی دکمه **Run** (▶️) کلیک کنید
3. اولین بار که اجرا می‌کنید، پیغام "Authorization required" ظاهر می‌شود:
   - روی **Review Permissions** کلیک کنید
   - حساب Google خود را انتخاب کنید
   - روی **Advanced** کلیک کنید
   - روی **Go to [نام پروژه] (unsafe)** کلیک کنید
   - روی **Allow** کلیک کنید

4. اسکریپت اجرا شده و سه sheet زیر ایجاد می‌شود:
   - **Users**: کاربران (ادمین و کارمندان)
   - **Tasks**: وظایف اختصاص داده شده
   - **Checklist**: چک لیست‌های شخصی هر کارمند

## مرحله ۵: Deploy کردن به عنوان Web App

1. در Script Editor، روی دکمه **Deploy** > **New deployment** کلیک کنید
2. روی آیکون ⚙️ (Settings) کنار "Select type" کلیک کنید
3. **Web app** را انتخاب کنید
4. تنظیمات را به صورت زیر وارد کنید:
   - **Description**: Backend API برای اپلیکیشن
   - **Execute as**: Me (ایمیل خودتان)
   - **Who has access**: Anyone (هرکسی)
   
5. روی **Deploy** کلیک کنید
6. **URL وب اپلیکیشن را کپی کنید** - به این شکل است:
   ```
   https://script.google.com/macros/s/AKfycby.../exec
   ```

## مرحله ۶: تنظیم URL در پروژه Flutter

1. فایل `lib/services/sheets_service.dart` را باز کنید
2. خط زیر را پیدا کنید:
   ```dart
   static const String _scriptUrl = 'YOUR_GOOGLE_APPS_SCRIPT_URL_HERE';
   ```
3. URL کپی شده از مرحله قبل را جایگزین کنید:
   ```dart
   static const String _scriptUrl = 'https://script.google.com/macros/s/AKfycby.../exec';
   ```

4. فایل `lib/services/checklist_service.dart` را باز کنید
5. همین کار را برای این فایل نیز انجام دهید:
   ```dart
   static const String _scriptUrl = 'https://script.google.com/macros/s/AKfycby.../exec';
   ```

## مرحله ۷: تست کردن

1. اپلیکیشن Flutter را اجرا کنید
2. با نام کاربری `admin` و رمز `admin123` وارد شوید
3. سعی کنید:
   - یک کارمند جدید ایجاد کنید
   - یک تسک جدید ایجاد کنید
   - با حساب کارمند وارد شوید و چک لیست شخصی را تست کنید

## ساختار Sheet‌ها

### 📊 Users Sheet
| uid | name | username | password | role | push_token |
|-----|------|----------|----------|------|------------|
| uuid | نام و نام خانوادگی | نام کاربری | رمز عبور | admin/employee | توکن نوتیفیکیشن |

### 📋 Tasks Sheet
| task_id | title | description | assigned_to | status | created_at | deadline |
|---------|-------|-------------|-------------|--------|------------|----------|
| uuid | عنوان | توضیحات | uid کارمند | pending/in_progress/completed | تاریخ ایجاد | مهلت انجام |

### ✅ Checklist Sheet
| id | employee_uid | title | description | is_completed | created_at | completed_at |
|----|--------------|-------|-------------|--------------|------------|--------------|
| uuid | uid کارمند | عنوان | توضیحات | true/false | تاریخ ایجاد | تاریخ تکمیل |

## ⚠️ نکات مهم

1. **امنیت**: این پیکربندی برای تست است. برای محیط تولید، باید احراز هویت قوی‌تری اضافه کنید.

2. **بروزرسانی**: هر وقت کد Apps Script را تغییر دادید، باید Deploy جدیدی انجام دهید:
   - **Deploy** > **Manage deployments**
   - روی آیکون ✏️ (Edit) کلیک کنید
   - **Version** را به "New version" تغییر دهید
   - روی **Deploy** کلیک کنید

3. **لاگ‌ها**: برای مشاهده لاگ‌ها و debug کردن:
   - از منو **View** > **Logs** استفاده کنید
   - یا **Executions** را ببینید

4. **محدودیت‌ها**: Google Apps Script محدودیت‌های زیر دارد:
   - حداکثر 6 دقیقه زمان اجرا
   - حداکثر 20 درخواست همزمان
   - برای پروژه‌های بزرگ از Firebase یا backend واقعی استفاده کنید

## 🆘 رفع مشکلات رایج

### خطا: "Script function not found"
- مطمئن شوید که کد را Save کرده‌اید
- تابع `initializeSheets` را دوباره Run کنید

### خطا: "Permission denied"
- مجوزهای دسترسی را دوباره بررسی کنید
- از حساب Google درست استفاده می‌کنید؟

### اپلیکیشن به Sheet متصل نمی‌شود
- URL وب اپلیکیشن را دوباره چک کنید
- مطمئن شوید Deploy کرده‌اید و نه فقط Save
- در تنظیمات Deploy، "Anyone" را انتخاب کرده‌اید؟

### داده‌ها در Sheet ظاهر نمی‌شوند
- **Executions** را چک کنید تا ببینید درخواست‌ها رسیده‌اند یا نه
- لاگ‌ها را برای پیدا کردن خطا بررسی کنید

## 📞 پشتیبانی

اگر مشکلی داشتید:
1. لاگ‌های Apps Script را چک کنید
2. لاگ‌های Flutter Console را بررسی کنید
3. مطمئن شوید URL صحیح است
4. تست کنید که Google Sheet در دسترس است

---

**نویسنده**: پروژه مدیریت خدمات دانشجویی
**تاریخ**: 2026
**نسخه**: 1.0.0
