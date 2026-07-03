import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/employee/employee_dashboard.dart';
import 'services/supabase_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('theme_mode') ?? 'light';
    setState(() {
      _themeMode = themeName == 'dark'
          ? ThemeMode.dark
          : themeName == 'system'
              ? ThemeMode.system
              : ThemeMode.light;
    });
  }

  void _changeTheme(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'سیستم مدیریت وظایف',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppThemeDark.darkTheme,
        themeMode: _themeMode,
        locale: const Locale('fa', 'IR'),
        supportedLocales: const [
          Locale('fa', 'IR'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: AuthWrapper(onThemeChanged: _changeTheme),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;

  const AuthWrapper({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Route based on role
        if (authProvider.currentUser?.role == 'admin') {
          return AdminDashboard(
            user: authProvider.currentUser!,
            onThemeChanged: onThemeChanged,
          );
        } else {
          return EmployeeDashboard(
            user: authProvider.currentUser!,
            onThemeChanged: onThemeChanged,
          );
        }
      },
    );
  }
}
