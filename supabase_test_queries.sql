-- ====================================
-- Supabase Test Queries
-- برای تست و عیب‌یابی مشکلات لاگین
-- ====================================

-- 1. بررسی وجود جدول users
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'users';

-- 2. بررسی تعداد کاربران
SELECT COUNT(*) as total_users FROM users;

-- 3. مشاهده تمام کاربران
SELECT uid, name, username, role FROM users;

-- 4. تست لاگین admin
SELECT * FROM users 
WHERE username = 'admin' 
AND password = 'admin123';

-- 5. تست لاگین ali
SELECT * FROM users 
WHERE username = 'ali' 
AND password = '1234';

-- 6. بررسی Row Level Security
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('users', 'tasks', 'checklist', 'task_checklist');

-- 7. اگر RLS فعال بود، غیرفعالش کن
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE tasks DISABLE ROW LEVEL SECURITY;
ALTER TABLE checklist DISABLE ROW LEVEL SECURITY;
ALTER TABLE task_checklist DISABLE ROW LEVEL SECURITY;

-- 8. بررسی ساختار جدول users
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'users'
ORDER BY ordinal_position;

-- 9. حذف و ساخت مجدد کاربر admin (اگر لازم بود)
DELETE FROM users WHERE username = 'admin';
INSERT INTO users (uid, name, username, password, role, push_token) 
VALUES ('admin-001', 'مدیر سیستم', 'admin', 'admin123', 'admin', '');

-- 10. تست نهایی
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM users 
            WHERE username = 'admin' 
            AND password = 'admin123'
        ) 
        THEN 'Login Test: SUCCESS ✓' 
        ELSE 'Login Test: FAILED ✗' 
    END as test_result;
