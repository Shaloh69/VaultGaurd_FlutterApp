import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'services/websocket_service.dart';
import 'providers/device_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(VaultGaurdApp(prefs: prefs));
}

class VaultGaurdApp extends StatelessWidget {
  final SharedPreferences prefs;

  const VaultGaurdApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(prefs),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ApiService>(
          create: (_) => ApiService(prefs),
          update: (_, auth, previous) => previous ?? ApiService(prefs),
        ),
        ChangeNotifierProxyProvider<ApiService, WebSocketService>(
          create: (_) => WebSocketService(),
          update: (_, api, previous) {
            if (previous == null) {
              return WebSocketService();
            }
            return previous;
          },
        ),
        ChangeNotifierProxyProvider<WebSocketService, DeviceProvider>(
          create: (_) => DeviceProvider(
            WebSocketService(),
            ApiService(prefs),
          ),
          update: (_, ws, previous) {
            if (previous == null) {
              return DeviceProvider(ws, ApiService(prefs));
            }
            previous.updateServices(ws, ApiService(prefs));
            return previous;
          },
        ),
      ],
      child: MaterialApp(
        title: 'VaultGaurd',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
