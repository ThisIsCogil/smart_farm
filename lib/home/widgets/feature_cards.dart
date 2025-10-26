import 'package:flutter/material.dart';

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
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
                              color: Color(0xFF27AE60))),
                      SizedBox(width: 10),
                      Expanded(
                          child: SensorValueBox(
                              label: 'Sensor 2',
                              value: '31',
                              color: Color(0xFFE74C3C))),
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
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
                              color: Color(0xFF27AE60))),
                      SizedBox(width: 10),
                      Expanded(
                          child: SensorValueBox(
                              label: 'Sensor 2',
                              value: '60',
                              color: Color(0xFFE67E22))),
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
  const SensorValueBox(
      {Key? key, required this.label, required this.value, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1)),
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
