-- ====================================
-- Supabase Database Setup Script - UPDATED
-- سیستم مدیریت خدمات دانشجویی - شرکة الکوثر
-- با سیستم چک‌لیست فلوچارت
-- ====================================

-- 1. ایجاد جدول کاربران
CREATE TABLE IF NOT EXISTS users (
    uid TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'employee',
    push_token TEXT DEFAULT ''
);

-- 2. ایجاد جدول وظایف
CREATE TABLE IF NOT EXISTS tasks (
    task_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    assigned_to TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW(),
    deadline TIMESTAMP NOT NULL,
    voice_note TEXT,
    attachment_name TEXT,
    attachment_data TEXT,
    FOREIGN KEY (assigned_to) REFERENCES users(uid)
);

-- 3. ایجاد جدول چک‌لیست شخصی
CREATE TABLE IF NOT EXISTS checklist (
    id TEXT PRIMARY KEY,
    employee_uid TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    FOREIGN KEY (employee_uid) REFERENCES users(uid)
);

-- 4. ایجاد جدول چک‌لیست وظایف (فلوچارت)
CREATE TABLE IF NOT EXISTS task_checklist (
    id TEXT PRIMARY KEY,
    task_id TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    "order" INTEGER NOT NULL DEFAULT 0,
    type TEXT NOT NULL CHECK (type IN ('start', 'step', 'condition', 'end')),
    condition_true TEXT,
    condition_false TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE
);

-- 5. غیرفعال کردن Row Level Security برای دسترسی آزاد
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE tasks DISABLE ROW LEVEL SECURITY;
ALTER TABLE checklist DISABLE ROW LEVEL SECURITY;
ALTER TABLE task_checklist DISABLE ROW LEVEL SECURITY;

-- 6. حذف داده‌های قدیمی (در صورت وجود)
DELETE FROM task_checklist;
DELETE FROM checklist;
DELETE FROM tasks;
DELETE FROM users;

-- 7. درج کاربران پیش‌فرض
INSERT INTO users (uid, name, username, password, role, push_token) VALUES
    ('admin-001', 'تقی‌زاده', 'taghizadeh', 'taghizadeh', 'admin', ''),
    ('emp-001', 'مهدی', 'mahdi', 'mahdi', 'employee', ''),
    ('emp-002', 'صارح', 'sareh', 'sareh', 'employee', ''),
    ('emp-003', 'فرزاد', 'farzad', 'farzad', 'employee', ''),
    ('emp-004', 'زینب', 'zeinab', 'zeinab', 'employee', ''),
    ('emp-005', 'محمد', 'mohammad', 'mohammad', 'employee', '');

-- 8. درج وظایف نمونه
INSERT INTO tasks (task_id, title, description, assigned_to, status, created_at, deadline) VALUES
    ('task-001', 'تهیه گزارش ماهانه', 'گزارش کامل عملکرد ماه جاری را آماده کنید', 'emp-001', 'pending', NOW() - INTERVAL '2 days', NOW() + INTERVAL '5 days'),
    ('task-002', 'برگزاری جلسه تیم', 'جلسه هفتگی با اعضای تیم برگزار شود', 'emp-001', 'in_progress', NOW() - INTERVAL '1 day', NOW() + INTERVAL '2 days'),
    ('task-003', 'بروزرسانی سیستم', 'نرم‌افزارهای سیستم را به‌روز کنید', 'emp-002', 'completed', NOW() - INTERVAL '5 days', NOW() - INTERVAL '1 day');

-- 9. درج چک‌لیست نمونه برای task-001
INSERT INTO task_checklist (id, task_id, title, description, "order", type, is_completed, created_at) VALUES
    ('cl-001', 'task-001', 'شروع کار', 'آماده‌سازی و جمع‌آوری اطلاعات اولیه', 0, 'start', TRUE, NOW()),
    ('cl-002', 'task-001', 'بررسی داده‌های ماه جاری', 'مرور و تحلیل اطلاعات عملکرد ماهانه', 1, 'step', TRUE, NOW()),
    ('cl-003', 'task-001', 'آیا داده‌ها کامل است؟', 'بررسی کامل بودن اطلاعات جمع‌آوری شده', 2, 'condition', FALSE, NOW()),
    ('cl-004', 'task-001', 'تهیه نمودارها و جداول', 'ایجاد نمودارها و جداول تحلیلی', 3, 'step', FALSE, NOW()),
    ('cl-005', 'task-001', 'نگارش گزارش نهایی', 'تهیه و تنظیم گزارش نهایی', 4, 'step', FALSE, NOW()),
    ('cl-006', 'task-001', 'بازبینی و تایید', 'بررسی نهایی و تایید گزارش', 5, 'step', FALSE, NOW()),
    ('cl-007', 'task-001', 'اتمام کار', 'ارسال گزارش به مدیریت', 6, 'end', FALSE, NOW());

-- 10. ایجاد ایندکس برای بهبود کارایی
CREATE INDEX IF NOT EXISTS idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_checklist_employee ON checklist(employee_uid);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_task_checklist_task_id ON task_checklist(task_id);
CREATE INDEX IF NOT EXISTS idx_task_checklist_order ON task_checklist("order");
CREATE INDEX IF NOT EXISTS idx_task_checklist_type ON task_checklist(type);

-- 11. ایجاد Function برای حذف خودکار چک‌لیست هنگام حذف وظیفه (در صورت نیاز)
CREATE OR REPLACE FUNCTION delete_task_checklist()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM task_checklist WHERE task_id = OLD.task_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- 12. ایجاد Trigger برای حذف خودکار
DROP TRIGGER IF EXISTS trigger_delete_task_checklist ON tasks;
CREATE TRIGGER trigger_delete_task_checklist
    BEFORE DELETE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION delete_task_checklist();

-- تمام! اکنون دیتابیس با قابلیت چک‌لیست فلوچارت آماده است 🚀
-- شرکة الکوثر للخدمات الجامعية
