import 'package:flutter/material.dart';
import '../models/weather_model.dart';

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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Color(0xFF636E72)),
                      SizedBox(width: 4),
                      Text('Weather Forecast', style: TextStyle(fontSize: 11, color: Color(0xFF636E72))),
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
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: _getConditionColor(condition), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _getWeatherCondition(condition),
                          style: TextStyle(fontSize: 14, color: _getConditionColor(condition), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(_getWeatherIcon(condition), size: 40, color: Colors.amber),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // A) Tampilkan waktu lokal perangkat (live)
            Text(
              _formatDateTime(DateTime.now()),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF636E72),
              ),
            ),
            // B) Tampilkan "X menit yang lalu" dari timestamp API
            Text(
              'Updated ' + _formatRelative(timestamp),
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
                    Text('${windSpeed.toStringAsFixed(1)} m/s', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    Icon(Icons.water_drop, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${rainfall.toStringAsFixed(1)} mm', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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

class WaterPumpCard extends StatelessWidget {
  const WaterPumpCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF3498DB).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.water_drop, color: Color(0xFF3498DB), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Water Pump', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                    SizedBox(height: 2),
                    Text('Control water pump', style: TextStyle(fontSize: 12, color: Color(0xFF636E72))),
                  ],
                ),
              ),
              Container(
                width: 50,
                height: 28,
                decoration: BoxDecoration(color: const Color(0xFF27AE60), borderRadius: BorderRadius.circular(20)),
                child: Stack(children: [
                  Positioned(
                    right: 2,
                    top: 2,
                    bottom: 2,
                    child: Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text('Online 1sec/ago', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ]),
          ),
        ],
      ),
    );
  }
}