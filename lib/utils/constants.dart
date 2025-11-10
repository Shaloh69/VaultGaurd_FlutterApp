import 'package:flutter/material.dart';

class AppColors {
  // ========== DARK PURPLE PALETTE ==========
  
  // Primary Colors (4-color palette)
  static const Color primary = Color(0xFF7C3AED);        // Deep Purple - Main actions
  static const Color secondary = Color(0xFFA78BFA);      // Lavender - Accents
  static const Color background = Color(0xFF1E1B2E);     // Dark Void - Background
  static const Color surface = Color(0xFF2D2640);        // Purple Haze - Cards/Surfaces
  
  // Functional State Colors
  static const Color success = Color(0xFF10B981);        // Emerald Green
  static const Color warning = Color(0xFFF59E0B);        // Amber
  static const Color danger = Color(0xFFEF4444);         // Red
  static const Color info = Color(0xFF8B5CF6);           // Purple Info
  
  // Metric-specific Colors (Purple-themed)
  static const Color voltageColor = Color(0xFFD946EF);   // Fuchsia
  static const Color currentColor = Color(0xFF06B6D4);   // Cyan
  static const Color powerColor = Color(0xFF10B981);     // Emerald
  static const Color energyColor = Color(0xFFF59E0B);    // Amber
  static const Color costColor = Color(0xFF8B5CF6);      // Violet
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);    // White
  static const Color textSecondary = Color(0xFFD1D5DB);  // Light Gray
  static const Color textTertiary = Color(0xFF9CA3AF);   // Gray
  
  // Additional UI Colors
  static const Color cardElevated = Color(0xFF372D4F);   // Elevated card background
  static const Color border = Color(0xFF4B4563);         // Border color
  static const Color divider = Color(0xFF3D3451);        // Divider color
  static const Color disabled = Color(0xFF6B7280);       // Disabled state
  
  // SSR Status Colors (with purple tint)
  static const Color ssrOn = Color(0xFF10B981);          // Green when ON
  static const Color ssrOff = Color(0xFF6B7280);         // Gray when OFF
  
  // Gradient Colors
  static const Color gradientStart = Color(0xFF7C3AED);  // Primary
  static const Color gradientEnd = Color(0xFF8B5CF6);    // Secondary purple
}

class AppConstants {
  // Default server configuration
  static const String defaultServerUrl = 'http://192.168.1.100:3000';
  static const String deviceType = 'VAULTER';
  
  // API Endpoints
  static const String apiHealth = '/api/health';
  static const String apiDevices = '/api/devices';
  static const String apiReadings = '/api/readings';
  static const String apiStats = '/api/stats';
  static const String apiCommand = '/api/admin/command';
  static const String apiRelay = '/api/admin/relay'; // SSR control endpoint
  static const String apiSystem = '/api/admin/system';
  static const String apiConfig = '/api/admin/config';
  
  // Storage Keys
  static const String keyServerUrl = 'server_url';
  static const String keyDeviceId = 'device_id';
  static const String keyUsername = 'username';
  static const String keyPassword = 'password';
  static const String keyRememberMe = 'remember_me';
  static const String keyEnergyRate = 'energy_rate';
  
  // Default energy rate ($ per kWh)
  static const double defaultEnergyRate = 0.12;
  
  // Update intervals (milliseconds)
  static const int dataUpdateInterval = 1000;
  static const int chartUpdateInterval = 2000;
  static const int statsUpdateInterval = 5000;
  
  // Chart settings
  static const int maxDataPoints = 50;
  static const double chartHeight = 200.0;
}

class DeviceCommands {
  // SSR commands (VaultGaurd - single channel)
  static const String ssrOn = 'on';
  static const String ssrOff = 'off';
  static const String enable = 'enable';
  static const String disable = 'disable';
  
  // System commands
  static const String reset = 'reset';
  static const String restart = 'restart';
  static const String status = 'status';
  static const String diagnostics = 'diag';
  static const String test = 'test';
  static const String stats = 'stats';
  
  // Settings commands
  static const String calibrate = 'calibrate';
  static const String manual = 'manual';
  static const String safety = 'safety';
  static const String buzzer = 'buzzer';
  static const String clear = 'clear';
}

class AppStrings {
  static const String appName = 'VaultGaurd';
  static const String appTagline = 'Single Channel Power Monitor';
  
  static const String voltage = 'Voltage';
  static const String current = 'Current';
  static const String power = 'Power';
  static const String energy = 'Energy';
  static const String cost = 'Cost';
  
  static const String unitVoltage = 'V';
  static const String unitCurrent = 'A';
  static const String unitPower = 'W';
  static const String unitEnergy = 'kWh';
  static const String unitCost = '\$';
  
  static const String ssrOn = 'ON';
  static const String ssrOff = 'OFF';
  
  static const String connecting = 'Connecting...';
  static const String connected = 'Connected';
  static const String disconnected = 'Disconnected';
  static const String error = 'Error';
  
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String settings = 'Settings';
  static const String dashboard = 'Dashboard';
  static const String controls = 'Controls';
  static const String statistics = 'Statistics';
}

// Helper functions
String formatNumber(double? value, {int decimals = 2}) {
  if (value == null) return '---';
  return value.toStringAsFixed(decimals);
}

String formatDateTime(DateTime dateTime) {
  return '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}:'
      '${dateTime.second.toString().padLeft(2, '0')}';
}

String getSSRStatusText(bool state) {
  return state ? AppStrings.ssrOn : AppStrings.ssrOff;
}

Color getSSRStatusColor(bool state) {
  return state ? AppColors.ssrOn : AppColors.ssrOff;
}

// Backward compatibility - these functions redirect to SSR functions
String getRelayStatusText(bool state) => getSSRStatusText(state);
Color getRelayStatusColor(bool state) => getSSRStatusColor(state);