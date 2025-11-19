import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SensorMetricsCard extends StatelessWidget {
  const SensorMetricsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.thermostat_outlined,
                        color: Colors.grey[700], size: 20),
                    const SizedBox(width: 6),
                    const Text('°C',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436))),
                    const SizedBox(width: 6),
                    const Text('Temperature',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436))),
                  ],
                ),
                const SizedBox(height: 16),
                IntrinsicHeight(
                  child: Row(
                    children: const [
                      Expanded(
                        child: SensorValueBox(
                          label: 'Sensor 1',
                          value: '18',
                          color: Color(0xFF27AE60),
                          backgroundColor: Color(0xFFF4F9E9), // Warna 1
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: SensorValueBox(
                          label: 'Sensor 2',
                          value: '31',
                          color: Color(0xFFE67E22),
                          backgroundColor: Color(0xFFFFF4E5), // Warna 2
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.water_drop_outlined,
                        color: Colors.grey[700], size: 20),
                    const SizedBox(width: 6),
                    const Text('%',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436))),
                    const SizedBox(width: 6),
                    const Text('Humidity',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436))),
                  ],
                ),
                const SizedBox(height: 16),
                IntrinsicHeight(
                  child: Row(
                    children: const [
                      Expanded(
                        child: SensorValueBox(
                          label: 'Sensor 1',
                          value: '80',
                          color: Color(0xFF27AE60),
                          backgroundColor: Color(0xFFF4F9E9), // Warna 3
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: SensorValueBox(
                          label: 'Sensor 2',
                          value: '60',
                          color: Color(0xFFE67E22),
                          backgroundColor: Color(0xFFFFF4E5), // Warna 4
                        ),
                      ),
                    ],
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

class SensorValueBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color backgroundColor; // ✅ Tambahkan parameter baru

  const SensorValueBox({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
    required this.backgroundColor, // ✅ Wajib diisi
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor, // ✅ Ganti agar dinamis
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1,
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

class SafeLimitCard extends StatelessWidget {
  const SafeLimitCard({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MenuCard(
        icon: Icons.settings_outlined,
        iconColor: Color(0xFF3498DB),
        title: 'Safe Limit',
        subtitle: 'Set control device settings');
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
                color: const Color(0xFF2ECC71).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.dns_outlined,
                color: Color(0xFF2ECC71),
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

