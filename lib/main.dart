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
        
        // Dark Purple Theme
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          
          // Color Scheme
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            error: AppColors.danger,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: AppColors.textPrimary,
            onError: Colors.white,
          ),
          
          // Scaffold Background
          scaffoldBackgroundColor: AppColors.background,
          
          // App Bar Theme
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            iconTheme: IconThemeData(color: AppColors.textPrimary),
          ),
          
          // Card Theme
          cardTheme: CardTheme(
            elevation: 4,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: AppColors.primary.withOpacity(0.3),
          ),
          
          // Elevated Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          // Text Button Theme
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.secondary,
            ),
          ),
          
          // Input Decoration Theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.cardElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            hintStyle: const TextStyle(color: AppColors.textTertiary),
          ),
          
          // Icon Theme
          iconTheme: const IconThemeData(
            color: AppColors.textPrimary,
          ),
          
          // Divider Theme
          dividerTheme: const DividerThemeData(
            color: AppColors.divider,
            thickness: 1,
          ),
          
          // Chip Theme
          chipTheme: ChipThemeData(
            backgroundColor: AppColors.cardElevated,
            deleteIconColor: AppColors.textSecondary,
            labelStyle: const TextStyle(color: AppColors.textPrimary),
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          
          // Dialog Theme
          dialogTheme: DialogTheme(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          
          // Bottom Sheet Theme
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          
          // Snackbar Theme
          snackBarTheme: SnackBarThemeData(
            backgroundColor: AppColors.cardElevated,
            contentTextStyle: const TextStyle(color: AppColors.textPrimary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            behavior: SnackBarBehavior.floating,
          ),
          
          // Tab Bar Theme
          tabBarTheme: const TabBarTheme(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
          ),
          
          // Progress Indicator Theme
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: AppColors.primary,
          ),
          
          // Text Theme
          textTheme: const TextTheme(
            displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            displaySmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            titleSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(color: AppColors.textPrimary),
            bodyMedium: TextStyle(color: AppColors.textSecondary),
            bodySmall: TextStyle(color: AppColors.textTertiary),
            labelLarge: TextStyle(color: AppColors.textPrimary),
            labelMedium: TextStyle(color: AppColors.textSecondary),
            labelSmall: TextStyle(color: AppColors.textTertiary),
          ),
        ),
        
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}