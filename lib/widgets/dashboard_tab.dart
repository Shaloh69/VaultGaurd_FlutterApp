import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/device_provider.dart';
import '../utils/constants.dart';
import '../widgets/metric_card.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, child) {
        final data = deviceProvider.currentData;

        return RefreshIndicator(
          onRefresh: deviceProvider.refreshDevice,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Voltage Card with gradient
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.voltageColor.withOpacity(0.2),
                      AppColors.surface,
                    ],
                  ),
                ),
                child: MetricCard(
                  title: 'System Voltage',
                  value: formatNumber(data.voltage, decimals: 1),
                  unit: AppStrings.unitVoltage,
                  icon: Icons.bolt,
                  color: AppColors.voltageColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Single Channel Power Metrics
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.electrical_services,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Power Monitor',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: getSSRStatusColor(data.ssrState).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: getSSRStatusColor(data.ssrState),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: getSSRStatusColor(data.ssrState).withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  data.ssrState ? Icons.power_settings_new : Icons.power_off,
                                  color: getSSRStatusColor(data.ssrState),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  getSSRStatusText(data.ssrState),
                                  style: TextStyle(
                                    color: getSSRStatusColor(data.ssrState),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32, color: AppColors.divider),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetric(
                              context,
                              'Current',
                              formatNumber(data.current, decimals: 3),
                              AppStrings.unitCurrent,
                              AppColors.currentColor,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: AppColors.divider,
                          ),
                          Expanded(
                            child: _buildMetric(
                              context,
                              'Power',
                              formatNumber(data.power, decimals: 1),
                              AppStrings.unitPower,
                              AppColors.powerColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetric(
                              context,
                              'Energy',
                              formatNumber(data.energy, decimals: 3),
                              AppStrings.unitEnergy,
                              AppColors.energyColor,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: AppColors.divider,
                          ),
                          Expanded(
                            child: _buildMetric(
                              context,
                              'Cost',
                              formatNumber(data.cost, decimals: 2),
                              AppStrings.unitCost,
                              AppColors.costColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // System Status
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.info),
                          const SizedBox(width: 12),
                          Text(
                            'System Status',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.divider),
                      _buildStatusRow('State', data.state, AppColors.info),
                      const SizedBox(height: 8),
                      _buildStatusRow('Sensors', data.sensors, 
                          data.sensors == 'valid' ? AppColors.success : AppColors.warning),
                      const SizedBox(height: 8),
                      _buildStatusRow('SSR', getSSRStatusText(data.ssrState),
                          getSSRStatusColor(data.ssrState)),
                      const SizedBox(height: 8),
                      _buildStatusRow('Last Update', formatDateTime(data.timestamp), 
                          AppColors.secondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Real-time Charts
              _buildChartsSection(deviceProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetric(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                unit,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(
              value.toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(DeviceProvider deviceProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Real-time Charts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildChart(
              'Voltage',
              deviceProvider.voltageData,
              AppColors.voltageColor,
              'V',
            ),
            const SizedBox(height: 28),
            
            _buildChart(
              'Current',
              deviceProvider.currentData,
              AppColors.currentColor,
              'A',
            ),
            const SizedBox(height: 28),
            
            _buildChart(
              'Power',
              deviceProvider.powerData,
              AppColors.powerColor,
              'W',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(
    String title,
    List<dynamic> data,
    Color color,
    String unit,
  ) {
    if (data.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.cardElevated.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timeline, color: color.withOpacity(0.5), size: 32),
              const SizedBox(height: 8),
              const Text(
                'Collecting data...',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 160,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardElevated.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.border.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: data
                      .asMap()
                      .entries
                      .map((e) => FlSpot(
                            e.key.toDouble(),
                            e.value.value,
                          ))
                      .toList(),
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}