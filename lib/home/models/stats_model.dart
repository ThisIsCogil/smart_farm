import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AirQualityModel {
  final _client = Supabase.instance.client;

  AirQualityModel();

  DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    throw ArgumentError('Cannot parse DateTime from value: $value');
  }

  num _numOrZero(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    if (v is String) return num.tryParse(v) ?? 0;
    return 0;
  }

  // ===================== DAY -> sensor_hourly_stats =====================
  Future<List<Map<String, dynamic>>> fetchDayData(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final response = await _client
        .from('sensor_hourly_stats')
        .select('bucket_start, avg_temp, avg_hum, avg_soil')
        .gte('bucket_start', start.toIso8601String())
        .lt('bucket_start', end.toIso8601String())
        .order('bucket_start');

    final list = response as List;

    return list.map((row) {
      final ts = _parseDateTime(row['bucket_start']);
      final hourLabel = '${ts.hour.toString().padLeft(2, '0')}:00';

      return {
        'day': hourLabel,
        'temperature': _numOrZero(row['avg_temp']).round(),
        'humidity': _numOrZero(row['avg_hum']).round(),
        'soil': _numOrZero(row['avg_soil']).round(),
      };
    }).toList();
  }

  // ===================== WEEK -> sensor_daily_stats =====================
  Future<List<Map<String, dynamic>>> fetchWeekData(DateTime anchor) async {
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    final start = DateTime(monday.year, monday.month, monday.day);
    final end = start.add(const Duration(days: 7));

    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';

    final response = await _client
        .from('sensor_daily_stats')
        .select('date, avg_temp, avg_hum, avg_soil')
        .gte('date', fmt(start))
        .lt('date', fmt(end))
        .order('date');

    final list = response as List;

    return list.map((row) {
      final d = _parseDateTime(row['date']);

      return {
        'day': 'D${d.day}', // label bebas, penting unik per bar
        'temperature': _numOrZero(row['avg_temp']).round(),
        'humidity': _numOrZero(row['avg_hum']).round(),
        'soil': _numOrZero(row['avg_soil']).round(),
      };
    }).toList();
  }

  // ===================== MONTH -> sensor_daily_stats ====================
  

  // ===================== API utama utk controller =======================
  Future<List<Map<String, dynamic>>> getCurrentData(
    String selectedPeriod,
    DateTime anchorDate,
  ) async {
    switch (selectedPeriod) {
      case 'Day':
        return fetchDayData(anchorDate);
      case 'Week':
      default:
        return fetchWeekData(anchorDate);
    }
  }
}
