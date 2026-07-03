-- ====================================
-- آپدیت جدول tasks برای اضافه کردن ویس و فایل
-- ====================================

-- اضافه کردن ستون‌های جدید به جدول tasks
ALTER TABLE tasks 
ADD COLUMN IF NOT EXISTS voice_note TEXT,
ADD COLUMN IF NOT EXISTS attachment_name TEXT,
ADD COLUMN IF NOT EXISTS attachment_data TEXT;

-- بررسی موفقیت‌آمیز بودن آپدیت
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'tasks';
