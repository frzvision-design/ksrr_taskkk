#!/usr/bin/env python3
"""
Supabase Connection Test Script
اسکریپت تست اتصال به Supabase
"""

import requests
import json
from typing import Optional, Dict

# کانفیگ Supabase
SUPABASE_URL = "https://gywuopnmxnvjdskmmnmi.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5d3VvcG5teG52amRza21tbm1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI4MDEyODMsImV4cCI6MjA5ODM3NzI4M30.jvOGjQDzdk5R2biOrnVcPlaFub55VIj5hzdJOJh_sQk"

# ⚠️ اگر service_role key داری اینجا وارد کن (از Settings > API در Supabase)
SUPABASE_SERVICE_KEY = None  # مثال: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# از کدوم key استفاده کنیم؟
SUPABASE_KEY = SUPABASE_SERVICE_KEY if SUPABASE_SERVICE_KEY else SUPABASE_ANON_KEY

# رنگ‌ها برای خروجی زیبا
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    END = '\033[0m'

def print_header(text: str):
    """چاپ هدر با فرمت"""
    print(f"\n{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.END}")
    print(f"{Colors.BOLD}{Colors.BLUE}{text.center(60)}{Colors.END}")
    print(f"{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.END}\n")

def print_success(text: str):
    """چاپ پیام موفقیت"""
    print(f"{Colors.GREEN}✓ {text}{Colors.END}")

def print_error(text: str):
    """چاپ پیام خطا"""
    print(f"{Colors.RED}✗ {text}{Colors.END}")

def print_warning(text: str):
    """چاپ هشدار"""
    print(f"{Colors.YELLOW}⚠ {text}{Colors.END}")

def print_info(text: str):
    """چاپ اطلاعات"""
    print(f"{Colors.BLUE}ℹ {text}{Colors.END}")

def test_connection() -> bool:
    """تست اتصال به Supabase از طریق جدول users"""
    print_header("تست اتصال به Supabase")
    
    try:
        # تست با query مستقیم روی جدول users
        url = f"{SUPABASE_URL}/rest/v1/users?limit=1"
        headers = {
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}"
        }
        
        response = requests.get(url, headers=headers, timeout=10)
        
        if response.status_code == 200:
            print_success("اتصال به Supabase برقرار شد")
            return True
        else:
            print_error(f"خطا در اتصال: {response.status_code}")
            print_info(f"پاسخ: {response.text}")
            return False
            
    except requests.exceptions.Timeout:
        print_error("Timeout: سرور پاسخ نداد")
        return False
    except requests.exceptions.ConnectionError:
        print_error("خطا در اتصال به اینترنت")
        return False
    except Exception as e:
        print_error(f"خطای غیرمنتظره: {str(e)}")
        return False

def test_table_exists(table_name: str) -> bool:
    """بررسی وجود جدول"""
    try:
        url = f"{SUPABASE_URL}/rest/v1/{table_name}?limit=1"
        headers = {
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}"
        }
        
        response = requests.get(url, headers=headers, timeout=10)
        
        if response.status_code == 200:
            print_success(f"جدول '{table_name}' وجود دارد")
            return True
        elif response.status_code == 404:
            print_error(f"جدول '{table_name}' یافت نشد")
            return False
        else:
            print_warning(f"وضعیت نامشخص برای جدول '{table_name}': {response.status_code}")
            return False
            
    except Exception as e:
        print_error(f"خطا در بررسی جدول '{table_name}': {str(e)}")
        return False

def get_users_count() -> Optional[int]:
    """دریافت تعداد کاربران"""
    try:
        url = f"{SUPABASE_URL}/rest/v1/users?select=count"
        headers = {
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}",
            "Prefer": "count=exact"
        }
        
        response = requests.head(url, headers=headers, timeout=10)
        
        if response.status_code == 200:
            count = response.headers.get('Content-Range', '0')
            if '/' in count:
                total = int(count.split('/')[-1])
                print_success(f"تعداد کاربران: {total}")
                return total
        
        return None
            
    except Exception as e:
        print_error(f"خطا در دریافت تعداد کاربران: {str(e)}")
        return None

def test_login(username: str, password: str) -> Optional[Dict]:
    """تست لاگین کاربر"""
    try:
        # استفاده از PostgREST API به صورت مستقیم
        url = f"{SUPABASE_URL}/rest/v1/users?username=eq.{username}&password=eq.{password}"
        headers = {
            "apikey": SUPABASE_ANON_KEY,
            "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
            "Content-Type": "application/json",
            "Prefer": "return=representation"
        }
        
        print_info(f"URL: {url}")
        print_info(f"Headers: {headers}")
        
        response = requests.get(url, headers=headers, timeout=10)
        
        print_info(f"Status: {response.status_code}")
        print_info(f"Response: {response.text}")
        
        if response.status_code == 200:
            data = response.json()
            if data and len(data) > 0:
                user = data[0]
                print_success(f"لاگین موفقیت‌آمیز: {user.get('name')} ({user.get('role')})")
                return user
            else:
                print_error("نام کاربری یا رمز عبور اشتباه است")
                return None
        else:
            print_error(f"خطا در لاگین: {response.status_code}")
            print_info(f"پاسخ: {response.text}")
            return None
            
    except Exception as e:
        print_error(f"خطا در تست لاگین: {str(e)}")
        import traceback
        traceback.print_exc()
        return None

def list_all_users():
    """لیست تمام کاربران"""
    print_header("لیست کاربران")
    
    try:
        url = f"{SUPABASE_URL}/rest/v1/users?select=uid,name,username,role"
        headers = {
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}"
        }
        
        response = requests.get(url, headers=headers, timeout=10)
        
        if response.status_code == 200:
            users = response.json()
            if users:
                print(f"\n{'نام':<20} {'نام کاربری':<15} {'نقش':<10}")
                print("-" * 50)
                for user in users:
                    print(f"{user.get('name', 'N/A'):<20} {user.get('username', 'N/A'):<15} {user.get('role', 'N/A'):<10}")
                print()
            else:
                print_warning("هیچ کاربری یافت نشد!")
        else:
            print_error(f"خطا در دریافت لیست کاربران: {response.status_code}")
            
    except Exception as e:
        print_error(f"خطا: {str(e)}")

def main():
    """تابع اصلی"""
    print_header("🔍 Supabase Connection Tester 🔍")
    print_info(f"URL: {SUPABASE_URL}")
    print_info(f"Key: {SUPABASE_KEY[:20]}...")
    
    # تست 1: اتصال پایه
    if not test_connection():
        print_error("\n❌ اتصال به Supabase برقرار نشد!")
        print_info("لطفاً موارد زیر را بررسی کنید:")
        print_info("  1. اتصال اینترنت")
        print_info("  2. URL و Key صحیح باشند")
        print_info("  3. پروژه Supabase فعال باشد")
        return
    
    # تست 2: بررسی جداول
    print_header("بررسی جداول")
    tables = ['users', 'tasks', 'checklist', 'task_checklist']
    all_exist = True
    for table in tables:
        if not test_table_exists(table):
            all_exist = False
    
    if not all_exist:
        print_warning("\nبرخی جداول وجود ندارند!")
        print_info("لطفاً فایل supabase_setup.sql را در SQL Editor اجرا کنید")
        return
    
    # تست 3: شمارش کاربران
    print_header("بررسی کاربران")
    count = get_users_count()
    if count == 0:
        print_warning("هیچ کاربری در دیتابیس وجود ندارد!")
        print_info("لطفاً فایل supabase_setup.sql را اجرا کنید")
        return
    
    # تست 4: لیست کاربران
    list_all_users()
    
    # تست 5: لاگین
    print_header("تست لاگین")
    
    test_accounts = [
        ("admin", "admin123", "مدیر"),
        ("ali", "1234", "کارمند ۱"),
        ("sara", "1234", "کارمند ۲")
    ]
    
    success_count = 0
    for username, password, label in test_accounts:
        print_info(f"\nتست لاگین {label} ({username})...")
        user = test_login(username, password)
        if user:
            success_count += 1
    
    # نتیجه نهایی
    print_header("نتیجه نهایی")
    
    if success_count == len(test_accounts):
        print_success(f"✅ همه تست‌ها ({success_count}/{len(test_accounts)}) موفقیت‌آمیز بود!")
        print_success("سیستم آماده استفاده است")
    else:
        print_warning(f"⚠️ {success_count}/{len(test_accounts)} تست موفق بود")
        print_info("لطفاً موارد زیر را بررسی کنید:")
        print_info("  1. Row Level Security (RLS) غیرفعال باشد")
        print_info("  2. داده‌های پیش‌فرض درست وارد شده باشند")
        print_info("  3. فایل supabase_setup.sql کامل اجرا شده باشد")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n\n{Colors.YELLOW}⚠ تست توسط کاربر متوقف شد{Colors.END}")
    except Exception as e:
        print(f"\n{Colors.RED}❌ خطای غیرمنتظره: {str(e)}{Colors.END}")
