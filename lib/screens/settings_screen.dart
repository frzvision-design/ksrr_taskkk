import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const SettingsScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _currentTheme = ThemeMode.light;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('theme_mode') ?? 'light';
    setState(() {
      _currentTheme = themeName == 'dark'
          ? ThemeMode.dark
          : themeName == 'system'
              ? ThemeMode.system
              : ThemeMode.light;
      _isLoading = false;
    });
  }

  Future<void> _setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeName = 'light';
    if (mode == ThemeMode.dark) {
      themeName = 'dark';
    } else if (mode == ThemeMode.system) {
      themeName = 'system';
    }
    await prefs.setString('theme_mode', themeName);
    setState(() => _currentTheme = mode);
    widget.onThemeChanged(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Theme Section
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.palette_outlined),
                        title: const Text(
                          'پوسته',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      RadioListTile<ThemeMode>(
                        title: const Text(
                          'روشن',
                          textDirection: TextDirection.rtl,
                        ),
                        secondary: const Icon(Icons.light_mode),
                        value: ThemeMode.light,
                        groupValue: _currentTheme,
                        onChanged: (value) {
                          if (value != null) _setTheme(value);
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text(
                          'تیره',
                          textDirection: TextDirection.rtl,
                        ),
                        secondary: const Icon(Icons.dark_mode),
                        value: ThemeMode.dark,
                        groupValue: _currentTheme,
                        onChanged: (value) {
                          if (value != null) _setTheme(value);
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text(
                          'سیستم',
                          textDirection: TextDirection.rtl,
                        ),
                        secondary: const Icon(Icons.settings_system_daydream),
                        value: ThemeMode.system,
                        groupValue: _currentTheme,
                        onChanged: (value) {
                          if (value != null) _setTheme(value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // About Section
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text(
                          'درباره',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text(
                          'نسخه',
                          textDirection: TextDirection.rtl,
                        ),
                        trailing: const Text('1.0.0'),
                      ),
                      ListTile(
                        title: const Text(
                          'شرکة الکوثر للخدمات الجامعیة',
                          textDirection: TextDirection.rtl,
                        ),
                        subtitle: const Text(
                          'Al-Kawthar University Services',
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
