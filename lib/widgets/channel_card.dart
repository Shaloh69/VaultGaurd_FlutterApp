import 'package:flutter/material.dart';
import '../models/device_models.dart';
import '../utils/constants.dart';

/// ChannelCard widget for displaying single-channel power monitoring data
/// Note: VaultGaurd is a single-channel device, so this displays the main channel data
class ChannelCard extends StatelessWidget {
  final int channelNumber;
  final DeviceData deviceData;
  final Color color;

  const ChannelCard({
    super.key,
    required this.channelNumber,
    required this.deviceData,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.electrical_services,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Channel $channelNumber',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: getSSRStatusColor(deviceData.ssrState).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: getSSRStatusColor(deviceData.ssrState),
                    ),
                  ),
                  child: Text(
                    getSSRStatusText(deviceData.ssrState),
                    style: TextStyle(
                      color: getSSRStatusColor(deviceData.ssrState),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    context,
                    'Current',
                    formatNumber(deviceData.current, decimals: 3),
                    AppStrings.unitCurrent,
                    AppColors.currentColor,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    context,
                    'Power',
                    formatNumber(deviceData.power, decimals: 1),
                    AppStrings.unitPower,
                    AppColors.powerColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    context,
                    'Energy',
                    formatNumber(deviceData.energy, decimals: 3),
                    AppStrings.unitEnergy,
                    AppColors.energyColor,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    context,
                    'Cost',
                    formatNumber(deviceData.cost, decimals: 2),
                    AppStrings.unitCost,
                    AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}