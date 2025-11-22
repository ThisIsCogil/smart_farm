import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/mqtt_service.dart';

class SensorMetricsCard extends StatefulWidget {
  const SensorMetricsCard({Key? key}) : super(key: key);

  @override
  State<SensorMetricsCard> createState() => _SensorMetricsCardState();
}

class _SensorMetricsCardState extends State<SensorMetricsCard> {
  final MqttService _mqtt = MqttService();
  StreamSubscription<Map<String, dynamic>>? _sub;

  double _temperature = 0;
  double _humidityAir = 0;
  double _humiditySoil = 0;

  @override
  void initState() {
    super.initState();
    _initMqtt();
  }

  double _readNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  Future<void> _initMqtt() async {
    await _mqtt.connect();

    _sub = _mqtt.sensorsStream.listen((data) {
      setState(() {
        // temperature key selalu sama
        _temperature = _readNum(data['temperature']);

        // humidity bisa "humidity_air" ATAU "humidity"
        _humidityAir = _readNum(
          data['humidity_air'] ?? data['humidity']
        );

        // soil moisture bisa "soil_moisture" ATAU "humidity_soil"
        _humiditySoil = _readNum(
          data['soil_moisture'] ?? data['humidity_soil']
        );
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sensors, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Sensor Monitoring',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: SensorValueBox(
                    icon: Icons.thermostat_outlined,
                    label: 'Temperature',
                    value: _temperature,
                    unit: '°C',
                    color: const Color(0xFF27AE60),
                    backgroundColor: const Color(0xFFF4F9E9),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SensorValueBox(
                    icon: Icons.water_drop_outlined,
                    label: 'Humidity',
                    value: _humidityAir,
                    unit: '%',
                    color: const Color(0xFF3498DB),
                    backgroundColor: const Color(0xFFE3F2FD),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SensorValueBox(
                    icon: Icons.grass_outlined,
                    label: 'Soil Moisture',
                    value: _humiditySoil,
                    unit: '%',
                    color: const Color(0xFFE67E22),
                    backgroundColor: const Color(0xFFFFF4E5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========== SENSOR VALUE BOX (KOMPONEN INDIVIDUAL) ==========
class SensorValueBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final String unit;
  final Color color;
  final Color backgroundColor;

  const SensorValueBox({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // format angka biar rapi
    final valueStr = value.toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valueStr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              unit,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 8),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class DiseaseDetectionCard extends StatelessWidget {
  const DiseaseDetectionCard({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MenuCard(
        icon: Icons.bug_report_outlined,
        iconColor: Color(0xFF27AE60),
        title: 'Disease Detection',
        subtitle: 'Check out plant protection');
  }
}


class ArchiveDataCard extends StatelessWidget {
  const ArchiveDataCard({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MenuCard(
        icon: Icons.folder_outlined,
        iconColor: Color(0xFF9B59B6),
        title: 'Archive Data',
        subtitle: 'Data of plant monitoring');
  }
}

class DailyTaskCard extends StatelessWidget {
  const DailyTaskCard({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MenuCard(
        icon: Icons.task_alt_outlined,
        iconColor: Color(0xFFF39C12),
        title: 'Daily Task',
        subtitle: 'Manage daily activities');
  }
}

class MenuCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  const MenuCard(
      {Key? key,
      required this.icon,
      required this.iconColor,
      required this.title,
      required this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 3)),
          ]),
      child: Row(children: [
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF636E72),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6D4C41),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ]),
    );
  }
}
class ServerConfigCard extends StatefulWidget {
  const ServerConfigCard({Key? key}) : super(key: key);

  @override
  State<ServerConfigCard> createState() => _ServerConfigCardState();
}

class _ServerConfigCardState extends State<ServerConfigCard> {
  String? _serverUrl;
  bool _isLoading = true;

  final TextEditingController _controller = TextEditingController();
  static const String _prefsKey = 'server_url';

  @override
  void initState() {
    super.initState();
    _loadServerUrl();
  }

  Future<void> _loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    setState(() {
      _serverUrl = saved;
      _isLoading = false;
    });
  }

  Future<void> _saveServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, url);
    setState(() {
      _serverUrl = url;
    });
  }

  Future<void> _openEditDialog() async {
    _controller.text = _serverUrl ?? '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pengaturan Server AI'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Base URL Server',
              hintText: 'misal: http://192.168.1.5:8000',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = _controller.text.trim();
                if (text.isNotEmpty) {
                  _saveServerUrl(text);
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _isLoading ? null : _openEditDialog,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.dns_outlined,
                color: Color(0xFF3498DB),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Server AI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (_isLoading)
                    const Text(
                      'Memuat pengaturan...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF636E72),
                      ),
                    )
                  else if (_serverUrl == null || _serverUrl!.isEmpty)
                    const Text(
                      'Belum diatur. Ketuk untuk menambahkan base URL server.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF636E72),
                      ),
                    )
                  else
                    Text(
                      _serverUrl!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF636E72),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6D4C41),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

