# تست اتصال به Supabase

## چک‌لیست عیب‌یابی

### 1. بررسی SQL در Supabase
- [ ] کد SQL در SQL Editor اجرا شده است
- [ ] جدول `users` وجود دارد
- [ ] داده‌های پیش‌فرض (admin, ali, sara) وجود دارند
- [ ] RLS غیرفعال است

### 2. بررسی کانفیگ در کد
فایل: `lib/services/supabase_service.dart`

```dart
static const String supabaseUrl = 'https://gywuopnmxnvjdskmmnmi.supabase.co';
static const String supabaseKey = 'sb_publishable_pNOFiK5NT4JG6wWyk_OCrA_hAz2NwjF';
```

### 3. بررسی دستی در Supabase

1. برو به Supabase Dashboard
2. از منوی چپ، Table Editor را باز کن
3. جدول `users` را باز کن
4. باید این رکوردها را ببینی:

| uid | name | username | password | role |
|-----|------|----------|----------|------|
| admin-001 | مدیر سیستم | admin | admin123 | admin |
| emp-001 | علی احمدی | ali | 1234 | employee |
| emp-002 | سارا محمدی | sara | 1234 | employee |

### 4. تست دستی Query

در SQL Editor این query رو اجرا کن:

```sql
-- تست لاگین admin
SELECT * FROM users 
WHERE username = 'admin' 
AND password = 'admin123';
```

اگر نتیجه بر می‌گرده، یعنی دیتابیس درسته.

### 5. بررسی Row Level Security (RLS)

```sql
-- بررسی وضعیت RLS
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'users';
```

اگر `rowsecurity = true` بود، باید غیرفعالش کنی:

```sql
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
```

### 6. اگر هنوز کار نکرد، دیتابیس رو Reset کن:

```sql
-- حذف جداول قدیمی
DROP TABLE IF EXISTS task_checklist CASCADE;
DROP TABLE IF EXISTS checklist CASCADE;
DROP TABLE IF EXISTS tasks CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- بعد کل کد SQL رو دوباره اجرا کن
```

### 7. بررسی لاگ‌ها

اگر از Flutter Web استفاده می‌کنی:
- کنسول مرورگر (F12) رو باز کن
- تب Console رو ببین
- دنبال خطاهای مربوط به Supabase بگرد

اگر از اپلیکیشن موبایل استفاده می‌کنی:
- در ترمینال، خروجی `flutter run` رو بررسی کن
- دنبال پیام‌های `Login error:` بگرد

### اطلاعات ورود فعلی:

**مدیر:**
- نام کاربری: `admin`
- رمز: `admin123`

**کارمند 1:**
- نام کاربری: `ali`  
- رمز: `1234`

**کارمند 2:**
- نام کاربری: `sara`
- رمز: `1234`

⚠️ **مهم:** حتماً بدون فاصله اضافی وارد کن!
