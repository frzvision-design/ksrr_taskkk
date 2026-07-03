-- ====================================
-- اضافه کردن کاربران جدید
-- ====================================

-- حذف کاربران قدیمی (در صورت وجود)
DELETE FROM users WHERE uid IN ('admin-001', 'emp-001', 'emp-002', 'emp-003', 'emp-004', 'emp-005', 'emp-006');

-- درج کاربران
INSERT INTO users (uid, name, username, password, role, push_token) VALUES
    ('admin-001', 'مدیر سیستم', 'admin', 'admin123', 'admin', ''),
    ('emp-001', 'تقی‌زاده', 'taghizadeh', 'taghizadeh', 'employee', ''),
    ('emp-002', 'مهدی', 'mahdi', 'mahdi', 'employee', ''),
    ('emp-003', 'صارح', 'sareh', 'sareh', 'employee', ''),
    ('emp-004', 'فرزاد', 'farzad', 'farzad', 'employee', ''),
    ('emp-005', 'زینب', 'zeinab', 'zeinab', 'employee', ''),
    ('emp-006', 'محمد', 'mohammad', 'mohammad', 'employee', '');

-- بررسی موفقیت
SELECT uid, name, username, role FROM users ORDER BY role DESC, name;
