import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../utils/constants.dart';

class ControlsTab extends StatefulWidget {
  const ControlsTab({super.key});

  @override
  State<ControlsTab> createState() => _ControlsTabState();
}

class _ControlsTabState extends State<ControlsTab> {
  final _commandController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  Future<void> _controlSSR(DeviceProvider provider, bool turnOn) async {
    setState(() => _isProcessing = true);
    
    final success = await provider.controlSSR(turnOn);
    
    setState(() => _isProcessing = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  success 
                      ? 'SSR turned ${turnOn ? "ON" : "OFF"}' 
                      : 'Failed to control SSR',
                ),
              ),
            ],
          ),
          backgroundColor: success ? AppColors.success : AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _sendCommand(DeviceProvider provider, String command) async {
    if (command.isEmpty) return;

    setState(() => _isProcessing = true);
    
    final success = await provider.sendCommand(command);
    
    setState(() => _isProcessing = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  success 
                      ? 'Command sent: $command' 
                      : 'Failed to send command',
                ),
              ),
            ],
          ),
          backgroundColor: success ? AppColors.success : AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    _commandController.clear();
  }

  Future<void> _systemAction(DeviceProvider provider, String action) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${action.toUpperCase()}'),
        content: Text('Are you sure you want to $action the device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    
    bool success = false;
    if (action == 'reset') {
      success = await provider.systemReset();
    } else if (action == 'restart') {
      success = await provider.systemRestart();
    }
    
    setState(() => _isProcessing = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  success 
                      ? 'System ${action}ed successfully' 
                      : 'Failed to $action system',
                ),
              ),
            ],
          ),
          backgroundColor: success ? AppColors.success : AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, child) {
        final data = deviceProvider.currentData;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // SSR Control with gradient
            Card(
              elevation: 8,
              shadowColor: AppColors.primary.withOpacity(0.3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surface,
                      AppColors.cardElevated,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.power_settings_new,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'SSR Control',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.divider),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing 
                                ? null 
                                : () => _controlSSR(deviceProvider, true),
                            icon: const Icon(Icons.power_settings_new),
                            label: const Text('Turn ON'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(18),
                              elevation: 6,
                              shadowColor: AppColors.success.withOpacity(0.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing 
                                ? null 
                                : () => _controlSSR(deviceProvider, false),
                            icon: const Icon(Icons.power_off),
                            label: const Text('Turn OFF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(18),
                              elevation: 6,
                              shadowColor: AppColors.danger.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (data != null) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: getSSRStatusColor(data.ssrState).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: getSSRStatusColor(data.ssrState),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: getSSRStatusColor(data.ssrState).withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                data.ssrState ? Icons.power_settings_new : Icons.power_off,
                                color: getSSRStatusColor(data.ssrState),
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'SSR is ${getSSRStatusText(data.ssrState)}',
                                style: TextStyle(
                                  color: getSSRStatusColor(data.ssrState),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Custom Command
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.terminal, color: AppColors.info),
                        const SizedBox(width: 12),
                        Text(
                          'Custom Command',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.divider),
                    TextField(
                      controller: _commandController,
                      decoration: InputDecoration(
                        hintText: 'Enter command (e.g., status, test, calibrate)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, color: AppColors.primary),
                          onPressed: _isProcessing
                              ? null
                              : () => _sendCommand(
                                    deviceProvider,
                                    _commandController.text.trim(),
                                  ),
                        ),
                      ),
                      enabled: !_isProcessing,
                      onSubmitted: _isProcessing
                          ? null
                          : (value) => _sendCommand(deviceProvider, value.trim()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Common Commands
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.apps, color: AppColors.secondary),
                        const SizedBox(width: 12),
                        Text(
                          'Common Commands',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.divider),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildCommandChip('status', Icons.info_outline, AppColors.info),
                        _buildCommandChip('test', Icons.science_outlined, AppColors.warning),
                        _buildCommandChip('calibrate', Icons.tune, AppColors.primary),
                        _buildCommandChip('stats', Icons.analytics_outlined, AppColors.secondary),
                        _buildCommandChip('manual', Icons.pan_tool_outlined, AppColors.energyColor),
                        _buildCommandChip('safety', Icons.shield_outlined, AppColors.success),
                        _buildCommandChip('buzzer', Icons.volume_up_outlined, AppColors.warning),
                        _buildCommandChip('clear', Icons.clear_all, AppColors.danger),
                        _buildCommandChip('enable', Icons.toggle_on, AppColors.success),
                        _buildCommandChip('disable', Icons.toggle_off, AppColors.disabled),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // System Controls
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.settings, color: AppColors.warning),
                        const SizedBox(width: 12),
                        Text(
                          'System Controls',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.divider),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.restart_alt, color: AppColors.warning),
                      ),
                      title: const Text('Restart Device'),
                      subtitle: const Text('Restart the ESP32 microcontroller'),
                      trailing: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _systemAction(deviceProvider, 'restart'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                        ),
                        child: const Text('Restart'),
                      ),
                    ),
                    const Divider(color: AppColors.divider),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.settings_backup_restore, color: AppColors.danger),
                      ),
                      title: const Text('Reset System'),
                      subtitle: const Text('Emergency system reset'),
                      trailing: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _systemAction(deviceProvider, 'reset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommandChip(String command, IconData icon, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isProcessing
            ? null
            : () {
                final provider = Provider.of<DeviceProvider>(context, listen: false);
                _sendCommand(provider, command);
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                command,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}