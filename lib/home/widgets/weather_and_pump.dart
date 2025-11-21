import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/mqtt_service.dart';

// ===== ENUM UNTUK MODE DEVICE =====
enum DeviceMode { auto, manual }

// ================= WEATHER LOADING CARD =================
class WeatherCardLoading extends StatelessWidget {
  const WeatherCardLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF27AE60),
        ),
      ),
    );
  }
}

// ================= WEATHER CARD =================
class WeatherCard extends StatelessWidget {
  final WeatherData? weatherData;
  const WeatherCard({Key? key, this.weatherData}) : super(key: key);

  String _getWeatherCondition(String? condition) {
    if (condition == null) return 'Good';
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'Excellent';
      case 'clouds':
        return 'Good';
      case 'rain':
        return 'Moderate';
      default:
        return 'Good';
    }
  }

  Color _getConditionColor(String? condition) {
    if (condition == null) return const Color(0xFF27AE60);
    switch (condition.toLowerCase()) {
      case 'clear':
        return const Color(0xFF27AE60);
      case 'clouds':
        return const Color(0xFF3498DB);
      case 'rain':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF27AE60);
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  IconData _getWeatherIcon(String? condition) {
    if (condition == null) return Icons.wb_cloudy;
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.wb_cloudy;
      case 'rain':
        return Icons.water_drop;
      default:
        return Icons.wb_cloudy;
    }
  }

  String _formatRelative(DateTime? dateTime) {
    if (dateTime == null) return '';
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }

  @override
  Widget build(BuildContext context) {
    final temp = weatherData?.temperature ?? 25.0;
    final condition = weatherData?.condition ?? 'Clear';
    final windSpeed = weatherData?.windSpeed ?? 0.0;
    final rainfall = weatherData?.rainfall ?? 0.0;
    final location = weatherData?.location ?? 'Nevio';
    final timestamp = weatherData?.timestamp;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.wb_sunny_outlined,
                    color: Color(0xFFE74C3C),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: Color(0xFF636E72)),
                      SizedBox(width: 4),
                      Text(
                        'Weather Forecast',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF636E72),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${temp.toStringAsFixed(0)}°C',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _getConditionColor(condition),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getWeatherCondition(condition),
                          style: TextStyle(
                            fontSize: 14,
                            color: _getConditionColor(condition),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getWeatherIcon(condition),
                    size: 40,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _formatDateTime(DateTime.now()),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF636E72),
              ),
            ),
            Text(
              'Updated ${_formatRelative(timestamp)}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF636E72),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.air, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${windSpeed.toStringAsFixed(1)} m/s',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    Icon(Icons.water_drop,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${rainfall.toStringAsFixed(1)} mm',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ========== CONTROL DEVICE CARD (3 AKTUATOR) ==========
class ControlDevicesCard extends StatefulWidget {
  const ControlDevicesCard({Key? key}) : super(key: key);

  @override
  ControlDevicesCardState createState() => ControlDevicesCardState();
}

class ControlDevicesCardState extends State<ControlDevicesCard> {
  final MqttService _mqtt = MqttService();

  // ===== STATE AUTO dari MQTT actuators =====
  final Map<String, bool> _autoOn = {
    'pump': false,
    'humidifier': false,
    'fan': false,
  };

  // ===== STATE MANUAL dari switch Flutter =====
  final Map<String, bool> _manualOn = {
    'pump': false,
    'humidifier': false,
    'fan': false,
  };

  @override
  void initState() {
    super.initState();
    _mqtt.connect();

    // listen status AUTO/device (endpoint actuators)
    _mqtt.actuatorsStream.listen((act) {
      setState(() {
        if (act.containsKey('pump')) _autoOn['pump'] = act['pump']!;
        if (act.containsKey('humidifier')) {
          _autoOn['humidifier'] = act['humidifier']!;
        }
        if (act.containsKey('fan')) _autoOn['fan'] = act['fan']!;
        // NOTE: _manualOn TIDAK diubah dari MQTT
      });
    });
  }

  Future<bool> _confirmTurnOn(BuildContext context, String title) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Apakah Anda ingin menghidupkan $title?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ya, Hidupkan'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _handleManualToggle(
      String id, bool value, String title) async {
    if (value) {
      final ok = await _confirmTurnOn(context, title);
      if (!ok) return;
    }

    setState(() {
      _manualOn[id] = value;
    });

    // publish manual ke CONTROL endpoint
    await _mqtt.publishManualControl(id, value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CompactDeviceCard(
          icon: Icons.water_drop,
          title: 'Water Pump',
          color: const Color(0xFF3498DB),
          autoOn: _autoOn['pump']!,
          manualOn: _manualOn['pump']!,
          onManualChanged: (v) =>
              _handleManualToggle('pump', v, 'Water Pump'),
        ),
        const SizedBox(height: 6),
        CompactDeviceCard(
          icon: Icons.air,
          title: 'Humidifier',
          color: const Color(0xFF9B59B6),
          autoOn: _autoOn['humidifier']!,
          manualOn: _manualOn['humidifier']!,
          onManualChanged: (v) =>
              _handleManualToggle('humidifier', v, 'Humidifier'),
        ),
        const SizedBox(height: 6),
        CompactDeviceCard(
          icon: Icons.wind_power,
          title: 'Exhaust Fan',
          color: const Color(0xFFE67E22),
          autoOn: _autoOn['fan']!,
          manualOn: _manualOn['fan']!,
          onManualChanged: (v) =>
              _handleManualToggle('fan', v, 'Exhaust Fan'),
        ),
      ],
    );
  }
}

// ========== COMPACT DEVICE CARD (AUTO STATUS + MANUAL SWITCH) ==========
class CompactDeviceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  // dari endpoint actuators (auto)
  final bool autoOn;
  // dari switch flutter (manual)
  final bool manualOn;

  final ValueChanged<bool> onManualChanged;

  const CompactDeviceCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
    required this.autoOn,
    required this.manualOn,
    required this.onManualChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isManual = manualOn;
    final bool isActive = manualOn || autoOn; // status final

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(icon, size: 26, color: color),
            ),
          ),
          const SizedBox(width: 10),

          // TEKS TENGAH
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isActive
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFEF4444))
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  isManual
                      ? (manualOn
                          ? 'Sedang menyala (manual)'
                          : 'Perangkat mati (manual)')
                      : (autoOn
                          ? 'Sedang menyala (otomatis)'
                          : 'Perangkat mati (otomatis)'),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // MODE LABEL + SWITCH
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isManual ? Icons.touch_app : Icons.auto_mode,
                      size: 13,
                      color: isManual
                          ? const Color(0xFF111827)
                          : Colors.blueGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isManual ? 'Manual' : 'Auto',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isManual
                            ? const Color(0xFF111827)
                            : Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.power_settings_new,
                    size: 16,
                    color: isActive
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF9CA3AF),
                  ),
                  Switch.adaptive(
                    value: manualOn, // switch hanya manual
                    onChanged: (v) => onManualChanged(v),
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
