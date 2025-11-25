import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AirQualityModel {
  // Key HARUS sama dengan yang di ServerConfigCard
  static const String _prefsKey = 'server_url';

  // Default kalau belum pernah di-set
  static const String _defaultBaseUrl = 'http://192.168.1.47:8000';

  const AirQualityModel();

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

  /// Ambil baseUrl paling baru dari SharedPreferences
  Future<String> _getBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefsKey) ?? _defaultBaseUrl;
    } catch (e) {
      debugPrint('Gagal load server_url dari prefs: $e');
      return _defaultBaseUrl;
    }
  }

  /// Helper: ambil list "points" dari endpoint Flask
  Future<List<Map<String, dynamic>>> _fetchPointsFromApi(String path) async {
    final baseUrl = await _getBaseUrl();          // ⬅️ pakai IP terbaru
    final uri = Uri.parse('$baseUrl$path');

    debugPrint('GET $uri'); // optional: bantu debug

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final list = (decoded['points'] as List?) ?? [];

    return list.cast<Map<String, dynamic>>();
  }

  // ===================== HOUR -> per menit =====================
  /// Data untuk 1 jam tertentu (per menit).
  /// Contoh: anchorDate = 25 Nov 2025, 14:xx → ambil menit 14:00–14:59 di hari itu.
  Future<List<Map<String, dynamic>>> fetchHourData(DateTime anchor) async {
    // Ambil 24 jam terakhir dari backend
    final points = await _fetchPointsFromApi('/api/sensors/daily?hours=24');

    // minute: 0..59
    final Map<int, _Agg> aggByMinute = {};

    for (final p in points) {
      final ts = _parseDateTime(p['timestamp']).toLocal();

      // Filter data yang hanya dari hari dan jam yang sama dengan [anchor]
      if (ts.year == anchor.year &&
          ts.month == anchor.month &&
          ts.day == anchor.day &&
          ts.hour == anchor.hour) {
        final minute = ts.minute;

        final temp = _numOrZero(p['temperature']).toDouble();
        final hum = _numOrZero(p['humidity']).toDouble();
        final soil = _numOrZero(p['soil_moisture']).toDouble();

        final agg = aggByMinute.putIfAbsent(minute, () => _Agg());
        agg.add(temp: temp, hum: hum, soil: soil);
      }
    }

    final entries = aggByMinute.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final hh = anchor.hour.toString().padLeft(2, '0');

    return entries.map((e) {
      final mm = e.key;
      final agg = e.value;

      final label = '$hh:${mm.toString().padLeft(2, '0')}';

      return {
        'day': label, // label X axis & Excel
        'temperature': agg.avgTemp.round(),
        'humidity': agg.avgHum.round(),
        'soil': agg.avgSoil.round(),
      };
    }).toList();
  }

  // ===================== DAY -> per jam =====================
  /// Data untuk 1 hari (per jam).
  Future<List<Map<String, dynamic>>> fetchDayData(DateTime date) async {
    // Ambil 24 jam terakhir dari backend
    final points = await _fetchPointsFromApi('/api/sensors/daily?hours=24');

    final Map<int, _Agg> aggByHour = {};

    for (final p in points) {
      final ts = _parseDateTime(p['timestamp']).toLocal();

      // Filter hanya tanggal yang sama dengan [date]
      if (ts.year == date.year &&
          ts.month == date.month &&
          ts.day == date.day) {
        final hour = ts.hour;

        final temp = _numOrZero(p['temperature']).toDouble();
        final hum = _numOrZero(p['humidity']).toDouble();
        final soil = _numOrZero(p['soil_moisture']).toDouble();

        final agg = aggByHour.putIfAbsent(hour, () => _Agg());
        agg.add(temp: temp, hum: hum, soil: soil);
      }
    }

    final entries = aggByHour.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries.map((e) {
      final hour = e.key;
      final agg = e.value;

      final label = '${hour.toString().padLeft(2, '0')}:00';

      return {
        'day': label,
        'temperature': agg.avgTemp.round(),
        'humidity': agg.avgHum.round(),
        'soil': agg.avgSoil.round(),
      };
    }).toList();
  }

  // ===================== WEEK -> per hari =====================
  /// Data untuk 1 minggu (per hari).
  Future<List<Map<String, dynamic>>> fetchWeekData(DateTime anchor) async {
    // Ambil 7 hari terakhir dari backend
    final points = await _fetchPointsFromApi('/api/sensors/weekly?days=7');

    // Range minggu berdasarkan anchor (Senin–Minggu)
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    final start = DateTime(monday.year, monday.month, monday.day);
    final end = start.add(const Duration(days: 7));

    final Map<DateTime, _Agg> aggByDay = {};

    DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

    for (final p in points) {
      final ts = _parseDateTime(p['timestamp']).toLocal();
      final d = _dateOnly(ts);

      // Hanya ambil data yang berada di rentang minggu [start, end)
      if (d.isBefore(start) || !d.isBefore(end)) continue;

      final temp = _numOrZero(p['temperature']).toDouble();
      final hum = _numOrZero(p['humidity']).toDouble();
      final soil = _numOrZero(p['soil_moisture']).toDouble();

      final agg = aggByDay.putIfAbsent(d, () => _Agg());
      agg.add(temp: temp, hum: hum, soil: soil);
    }

    final entries = aggByDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries.map((e) {
      final d = e.key;
      final agg = e.value;

      return {
        'day': 'D${d.day}', // label harian, bebas (bisa diganti nama hari)
        'temperature': agg.avgTemp.round(),
        'humidity': agg.avgHum.round(),
        'soil': agg.avgSoil.round(),
      };
    }).toList();
  }

  // ===================== API utama utk controller =======================
  Future<List<Map<String, dynamic>>> getCurrentData(
    String selectedPeriod,
    DateTime anchorDate,
  ) async {
    debugPrint('getCurrentData: $selectedPeriod, anchor=$anchorDate');
    switch (selectedPeriod) {
      case 'Hour':
        return fetchHourData(anchorDate);
      case 'Day':
        return fetchDayData(anchorDate);
      case 'Week':
      default:
        return fetchWeekData(anchorDate);
    }
  }
}

/// Accumulator sederhana untuk hitung rata-rata
class _Agg {
  double _sumTemp = 0;
  double _sumHum = 0;
  double _sumSoil = 0;
  int _count = 0;

  void add({required double temp, required double hum, required double soil}) {
    _sumTemp += temp;
    _sumHum += hum;
    _sumSoil += soil;
    _count++;
  }

  double get avgTemp => _count == 0 ? 0 : _sumTemp / _count;
  double get avgHum => _count == 0 ? 0 : _sumHum / _count;
  double get avgSoil => _count == 0 ? 0 : _sumSoil / _count;
}
