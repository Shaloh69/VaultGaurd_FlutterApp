import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/device_provider.dart';
import '../utils/constants.dart';
import '../widgets/dashboard_tab.dart';
import '../widgets/controls_tab.dart';
import '../widgets/statistics_tab.dart';
import '../widgets/device_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

    if (authProvider.serverUrl != null) {
      deviceProvider.connectWebSocket(authProvider.serverUrl!);
    }

    await deviceProvider.loadDevices();

    if (authProvider.deviceId != null) {
      await deviceProvider.selectDevice(authProvider.deviceId!);
    } else if (deviceProvider.allDevices.isNotEmpty) {
      await deviceProvider.selectDevice(deviceProvider.allDevices.first.deviceId);
      await authProvider.setDeviceId(deviceProvider.allDevices.first.deviceId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    deviceProvider.disconnectWebSocket();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
      
      deviceProvider.disconnectWebSocket();
      deviceProvider.clearData();
      await authProvider.logout();
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void _showDeviceSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DeviceSelector(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DeviceProvider, AuthProvider>(
      builder: (context, deviceProvider, authProvider, child) {
        final isConnected = deviceProvider.isConnected;
        final selectedDevice = deviceProvider.deviceInfo;
        
        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                const Text(
                  'VaultGaurd',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                if (selectedDevice != null)
                  Text(
                    selectedDevice.deviceId,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
              ],
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.cardElevated,
                  ],
                ),
              ),
            ),
            actions: [
              // Connection Status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isConnected 
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.danger.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isConnected ? AppColors.success : AppColors.danger,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isConnected ? AppColors.success : AppColors.danger,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isConnected ? AppColors.success : AppColors.danger,
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isConnected ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isConnected ? AppColors.success : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Device Selector
              if (deviceProvider.allDevices.length > 1)
                IconButton(
                  icon: const Icon(Icons.devices_outlined),
                  onPressed: _showDeviceSelector,
                  tooltip: 'Select Device',
                ),
              
              // Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                color: AppColors.cardElevated,
                onSelected: (value) {
                  switch (value) {
                    case 'refresh':
                      deviceProvider.refreshDevice();
                      break;
                    case 'reconnect':
                      if (authProvider.serverUrl != null) {
                        deviceProvider.connectWebSocket(authProvider.serverUrl!);
                      }
                      break;
                    case 'logout':
                      _handleLogout();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: AppColors.primary),
                        SizedBox(width: 12),
                        Text('Refresh', style: TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reconnect',
                    child: Row(
                      children: [
                        Icon(Icons.sync, color: AppColors.info),
                        SizedBox(width: 12),
                        Text('Reconnect', style: TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: AppColors.danger),
                        SizedBox(width: 12),
                        Text('Logout', style: TextStyle(color: AppColors.danger)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  icon: Icon(Icons.dashboard_outlined),
                  text: 'Dashboard',
                ),
                Tab(
                  icon: Icon(Icons.settings_remote_outlined),
                  text: 'Controls',
                ),
                Tab(
                  icon: Icon(Icons.analytics_outlined),
                  text: 'Stats',
                ),
              ],
            ),
          ),
          body: deviceProvider.selectedDeviceId == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.electrical_services_outlined,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Device Selected',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please select a device to monitor',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                      if (deviceProvider.allDevices.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: _showDeviceSelector,
                          icon: const Icon(Icons.devices_outlined),
                          label: const Text('Select Device'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () => deviceProvider.loadDevices(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Devices'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: const [
                    DashboardTab(),
                    ControlsTab(),
                    StatisticsTab(),
                  ],
                ),
        );
      },
    );
  }
}