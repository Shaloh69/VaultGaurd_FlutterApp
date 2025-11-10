import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/device_models.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../utils/constants.dart';

class DeviceProvider extends ChangeNotifier {
  WebSocketService _webSocketService;
  ApiService _apiService;

  DeviceProvider(this._webSocketService, this._apiService) {
    _webSocketService.addListener(_onWebSocketUpdate);
  }

  // Current device data
  DeviceData? _currentData;
  DeviceInfo? _deviceInfo;
  List<DeviceInfo> _allDevices = [];
  Statistics? _statistics;
  
  // Chart data - single channel only
  final List<ChartDataPoint> _voltageData = [];
  final List<ChartDataPoint> _currentData = [];
  final List<ChartDataPoint> _powerData = [];
  final List<ChartDataPoint> _energyData = [];
  
  // State
  bool _isLoading = false;
  String? _error;
  String? _selectedDeviceId;

  // Getters
  DeviceData? get currentData => _currentData;
  DeviceInfo? get deviceInfo => _deviceInfo;
  List<DeviceInfo> get allDevices => _allDevices;
  Statistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedDeviceId => _selectedDeviceId;
  bool get isConnected => _webSocketService.isConnected;

  List<ChartDataPoint> get voltageData => _voltageData;
  List<ChartDataPoint> get currentData => _currentData;
  List<ChartDataPoint> get powerData => _powerData;
  List<ChartDataPoint> get energyData => _energyData;

  void updateServices(WebSocketService ws, ApiService api) {
    _webSocketService.removeListener(_onWebSocketUpdate);
    _webSocketService = ws;
    _apiService = api;
    _webSocketService.addListener(_onWebSocketUpdate);
  }

  void _onWebSocketUpdate() {
    if (_selectedDeviceId != null) {
      final data = _webSocketService.getLatestData(_selectedDeviceId!);
      if (data != null) {
        _updateCurrentData(data);
      }
    }
    notifyListeners();
  }

  void _updateCurrentData(DeviceData data) {
    _currentData = data;
    _addToChartData(data);
    notifyListeners();
  }

  void _addToChartData(DeviceData data) {
    final now = data.timestamp;
    
    // Add new data points for single channel
    _voltageData.add(ChartDataPoint(now, data.voltage));
    _currentData.add(ChartDataPoint(now, data.current));
    _powerData.add(ChartDataPoint(now, data.power));
    _energyData.add(ChartDataPoint(now, data.energy));
    
    // Keep only max data points
    if (_voltageData.length > AppConstants.maxDataPoints) {
      _voltageData.removeAt(0);
      _currentData.removeAt(0);
      _powerData.removeAt(0);
      _energyData.removeAt(0);
    }
  }

  // Load all devices
  Future<void> loadDevices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allDevices = await _apiService.getDevices();
      _allDevices = _allDevices
          .where((d) => d.deviceType == AppConstants.deviceType)
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select a device
  Future<void> selectDevice(String deviceId) async {
    _selectedDeviceId = deviceId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _deviceInfo = await _apiService.getDevice(deviceId);
      
      // Load initial data if available
      if (_deviceInfo?.currentData != null) {
        _updateCurrentData(_deviceInfo!.currentData!);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh device data
  Future<void> refreshDevice() async {
    if (_selectedDeviceId == null) return;

    try {
      _deviceInfo = await _apiService.getDevice(_selectedDeviceId!);
      
      if (_deviceInfo?.currentData != null) {
        _updateCurrentData(_deviceInfo!.currentData!);
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load statistics
  Future<void> loadStatistics() async {
    if (_selectedDeviceId == null) return;

    try {
      _statistics = await _apiService.getStatistics(_selectedDeviceId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  // Control SSR (VaultGaurd has single SSR, no channel parameter)
  Future<bool> controlSSR(bool turnOn) async {
    if (_selectedDeviceId == null) return false;

    try {
      final success = await _apiService.controlSSR(
        _selectedDeviceId!,
        turnOn,
      );
      
      if (success) {
        // Refresh device data
        await refreshDevice();
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Send command
  Future<bool> sendCommand(String command, {String? parameters}) async {
    if (_selectedDeviceId == null) return false;

    try {
      final success = await _apiService.sendCommand(
        _selectedDeviceId!,
        command,
        parameters: parameters,
      );
      
      if (success) {
        // Also send via WebSocket for immediate response
        _webSocketService.sendCommand(_selectedDeviceId!, 
            parameters != null ? '$command $parameters' : command);
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // System commands
  Future<bool> systemReset() async {
    if (_selectedDeviceId == null) return false;
    return await _apiService.systemReset(_selectedDeviceId!);
  }

  Future<bool> systemRestart() async {
    if (_selectedDeviceId == null) return false;
    return await _apiService.systemRestart(_selectedDeviceId!);
  }

  // Configuration
  Future<bool> setConfig(String parameter, dynamic value) async {
    if (_selectedDeviceId == null) return false;
    return await _apiService.setConfig(_selectedDeviceId!, parameter, value);
  }

  // Generate mock data for testing
  Future<bool> generateMockData({int count = 1}) async {
    if (_selectedDeviceId == null) return false;
    return await _apiService.generateMockData(_selectedDeviceId!, count: count);
  }

  // Connect WebSocket
  void connectWebSocket(String serverUrl) {
    _webSocketService.connect(serverUrl);
  }

  // Disconnect WebSocket
  void disconnectWebSocket() {
    _webSocketService.disconnect();
  }

  // Clear data
  void clearData() {
    _currentData = null;
    _deviceInfo = null;
    _statistics = null;
    _selectedDeviceId = null;
    _voltageData.clear();
    _currentData.clear();
    _powerData.clear();
    _energyData.clear();
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _webSocketService.removeListener(_onWebSocketUpdate);
    super.dispose();
  }
}