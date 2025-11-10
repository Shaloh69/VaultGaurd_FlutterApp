class DeviceData {
  final String deviceId;
  final String deviceType;
  final double voltage;
  final double current;
  final double power;
  final double energy;
  final double cost; // Calculated on client side
  final bool ssrState;
  final String state;
  final String sensors;
  final DateTime timestamp;

  DeviceData({
    required this.deviceId,
    required this.deviceType,
    required this.voltage,
    required this.current,
    required this.power,
    required this.energy,
    required this.cost,
    required this.ssrState,
    required this.state,
    required this.sensors,
    required this.timestamp,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    // Get raw values from server
    final voltage = (json['voltage'] ?? 0.0).toDouble();
    final current = (json['current'] ?? 0.0).toDouble();
    final power = (json['power'] ?? 0.0).toDouble();
    final energy = (json['energy'] ?? 0.0).toDouble();
    
    // Calculate cost on client side (using default rate if not provided)
    // Default rate: $0.12 per kWh
    final rate = (json['rate'] ?? 0.12).toDouble();
    final cost = energy * rate;
    
    return DeviceData(
      deviceId: json['deviceId'] ?? '',
      deviceType: json['deviceType'] ?? 'VAULTER',
      voltage: voltage,
      current: current,
      power: power,
      energy: energy,
      cost: cost,
      ssrState: json['ssrState'] ?? false,
      state: json['state'] ?? 'unknown',
      sensors: json['sensors'] ?? 'unknown',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceType': deviceType,
      'voltage': voltage,
      'current': current,
      'power': power,
      'energy': energy,
      'cost': cost,
      'ssrState': ssrState,
      'state': state,
      'sensors': sensors,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class DeviceInfo {
  final String deviceId;
  final String deviceType;
  final String ip;
  final DateTime connectedAt;
  final DateTime lastSeen;
  final bool isMock;
  final DeviceData? currentData;

  DeviceInfo({
    required this.deviceId,
    required this.deviceType,
    required this.ip,
    required this.connectedAt,
    required this.lastSeen,
    this.isMock = false,
    this.currentData,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['deviceId'] ?? '',
      deviceType: json['deviceType'] ?? 'VAULTER',
      ip: json['ip'] ?? '',
      connectedAt: json['connectedAt'] != null
          ? DateTime.parse(json['connectedAt'])
          : DateTime.now(),
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'])
          : DateTime.now(),
      isMock: json['isMock'] ?? false,
      currentData: json['currentData'] != null
          ? DeviceData.fromJson(json['currentData'])
          : null,
    );
  }
}

class CommandHistory {
  final String deviceId;
  final String command;
  final String source;
  final bool success;
  final DateTime timestamp;

  CommandHistory({
    required this.deviceId,
    required this.command,
    required this.source,
    required this.success,
    required this.timestamp,
  });

  factory CommandHistory.fromJson(Map<String, dynamic> json) {
    return CommandHistory(
      deviceId: json['deviceId'] ?? '',
      command: json['command'] ?? '',
      source: json['source'] ?? '',
      success: json['success'] ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}

class Statistics {
  final int totalReadings;
  final VoltageStats voltage;
  final SingleChannelStats channel;

  Statistics({
    required this.totalReadings,
    required this.voltage,
    required this.channel,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalReadings: json['totalReadings'] ?? 0,
      voltage: VoltageStats.fromJson(json['voltage'] ?? {}),
      channel: SingleChannelStats.fromJson(json['channel'] ?? {}),
    );
  }
}

class VoltageStats {
  final double min;
  final double max;
  final double avg;

  VoltageStats({
    required this.min,
    required this.max,
    required this.avg,
  });

  factory VoltageStats.fromJson(Map<String, dynamic> json) {
    return VoltageStats(
      min: (json['min'] ?? 0.0).toDouble(),
      max: (json['max'] ?? 0.0).toDouble(),
      avg: (json['avg'] ?? 0.0).toDouble(),
    );
  }
}

class SingleChannelStats {
  final double avgCurrent;
  final double avgPower;
  final double totalEnergy;

  SingleChannelStats({
    required this.avgCurrent,
    required this.avgPower,
    required this.totalEnergy,
  });

  factory SingleChannelStats.fromJson(Map<String, dynamic> json) {
    return SingleChannelStats(
      avgCurrent: (json['avgCurrent'] ?? 0.0).toDouble(),
      avgPower: (json['avgPower'] ?? 0.0).toDouble(),
      totalEnergy: (json['totalEnergy'] ?? 0.0).toDouble(),
    );
  }
}

class ChartDataPoint {
  final DateTime time;
  final double value;

  ChartDataPoint(this.time, this.value);
}