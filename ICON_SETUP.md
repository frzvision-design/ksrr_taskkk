# راهنمای تنظیم آیکون اپلیکیشن
# App Icon Setup Guide

## فارسی

### مراحل تبدیل لوگو به آیکون اندروید:

#### روش 1: استفاده از Android Studio (توصیه می‌شود)
1. فایل `assets/images/logo.jpg` را باز کنید
2. Android Studio را باز کنید
3. به مسیر `android/app/src/main/res` بروید
4. روی پوشه `res` کلیک راست کنید
5. `New` > `Image Asset` را انتخاب کنید
6. در قسمت Path، فایل `logo.jpg` را انتخاب کنید
7. گزینه `Launcher Icons (Adaptive and Legacy)` را انتخاب کنید
8. روی `Next` و سپس `Finish` کلیک کنید

#### روش 2: استفاده از ابزار آنلاین
1. به سایت https://icon.kitchen بروید
2. فایل `assets/images/logo.jpg` را آپلود کنید
3. تنظیمات را مطابق میل خود انجام دهید:
   - Background: Solid Color (قهوه‌ای #3E2723)
   - Foreground: Image
   - Shape: Circle یا Square
4. دانلود کنید و فایل‌ها را در مسیرهای زیر جایگزین کنید:
   ```
   android/app/src/main/res/mipmap-hdpi/ic_launcher.png
   android/app/src/main/res/mipmap-mdpi/ic_launcher.png
   android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
   android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
   android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
   ```

#### روش 3: استفاده از Flutter Package
```bash
# 1. نصب پکیج
flutter pub add flutter_launcher_icons --dev

# 2. اضافه کردن تنظیمات به pubspec.yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/logo.jpg"
  adaptive_icon_background: "#3E2723"
  adaptive_icon_foreground: "assets/images/logo.jpg"

# 3. اجرای دستور
flutter pub run flutter_launcher_icons
```

---

## English

### Steps to Convert Logo to Android Icon:

#### Method 1: Using Android Studio (Recommended)
1. Open the file `assets/images/logo.jpg`
2. Open Android Studio
3. Navigate to `android/app/src/main/res`
4. Right-click on `res` folder
5. Select `New` > `Image Asset`
6. In the Path section, select `logo.jpg`
7. Choose `Launcher Icons (Adaptive and Legacy)`
8. Click `Next` then `Finish`

#### Method 2: Using Online Tool
1. Go to https://icon.kitchen
2. Upload `assets/images/logo.jpg`
3. Configure settings:
   - Background: Solid Color (brown #3E2723)
   - Foreground: Image
   - Shape: Circle or Square
4. Download and replace files in:
   ```
   android/app/src/main/res/mipmap-hdpi/ic_launcher.png
   android/app/src/main/res/mipmap-mdpi/ic_launcher.png
   android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
   android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
   android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
   ```

#### Method 3: Using Flutter Package
```bash
# 1. Install package
flutter pub add flutter_launcher_icons --dev

# 2. Add configuration to pubspec.yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/logo.jpg"
  adaptive_icon_background: "#3E2723"
  adaptive_icon_foreground: "assets/images/logo.jpg"

# 3. Run command
flutter pub run flutter_launcher_icons
```

---

## نکات مهم / Important Notes

### فارسی:
- سایز توصیه شده لوگو: 1024x1024 پیکسل
- فرمت: PNG با پس‌زمینه شفاف (بهتر از JPG)
- بعد از تغییر آیکون، حتماً Clean و Rebuild کنید
- برای iOS نیز باید آیکون‌ها را جداگانه تولید کنید

### English:
- Recommended logo size: 1024x1024 pixels
- Format: PNG with transparent background (better than JPG)
- After changing icon, make sure to Clean and Rebuild
- For iOS, you need to generate icons separately

---

## تست / Testing

بعد از تنظیم آیکون:

```bash
# پاک کردن build قبلی
flutter clean

# نصب مجدد dependencies
flutter pub get

# بیلد و اجرا
flutter run
```

✅ آیکون جدید باید در لانچر دیوایس نمایش داده شود
