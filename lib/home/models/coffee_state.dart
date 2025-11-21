import 'dart:convert';

class CoffeeState {
  final double? temperature;
  final double? humidityAir;
  final double? humiditySoil;

  final bool pumpOn;
  final bool humidifierOn;
  final bool fanOn;

  final DateTime? timestamp;

  CoffeeState({
    required this.temperature,
    required this.humidityAir,
    required this.humiditySoil,
    required this.pumpOn,
    required this.humidifierOn,
    required this.fanOn,
    required this.timestamp,
  });

  factory CoffeeState.fromMqttPayload(String payload) {
    final map = jsonDecode(payload) as Map<String, dynamic>;

    final sensors = (map['sensors'] ?? {}) as Map<String, dynamic>;
    final actuators = (map['actuators'] ?? {}) as Map<String, dynamic>;
    final log = (map['log'] ?? {}) as Map<String, dynamic>;

    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    bool _isOn(dynamic v) => v?.toString().toUpperCase() == 'ON';

    DateTime? _parseTs(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return CoffeeState(
      temperature: _toDouble(sensors['temperature']),
      humidityAir: _toDouble(sensors['humidity_air']),
      humiditySoil: _toDouble(sensors['humidity_soil']),
      pumpOn: _isOn(actuators['pump']),
      humidifierOn: _isOn(actuators['humidifier']),
      fanOn: _isOn(actuators['fan']),
      timestamp: _parseTs(log['timestamp']),
    );
  }
}
