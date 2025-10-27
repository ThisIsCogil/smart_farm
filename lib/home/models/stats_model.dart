import 'package:flutter/foundation.dart';

/// Model sederhana untuk menampung data contoh (day/week/month).
class AirQualityModel {
  // ===================== DATA CONTOH =====================
  final List<Map<String, dynamic>> dayData = List.generate(
    7,
    (i) => {
      'day': 'H-${i + 1}',
      'temperature': [26, 27, 28, 29, 27, 26, 28][i],
      'humidity': [62, 64, 66, 63, 61, 60, 65][i],
    },
  );

  final List<Map<String, dynamic>> weekData = const [
    {'day': 'day 1', 'temperature': 25, 'humidity': 60},
    {'day': 'day 2', 'temperature': 28, 'humidity': 65},
    {'day': 'day 3', 'temperature': 89, 'humidity': 70},
    {'day': 'day 4', 'temperature': 45, 'humidity': 55},
    {'day': 'day 5', 'temperature': 38, 'humidity': 62},
    {'day': 'day 6', 'temperature': 42, 'humidity': 58},
    {'day': 'day 7', 'temperature': 35, 'humidity': 64},
  ];

  final List<Map<String, dynamic>> monthData = List.generate(
    4,
    (i) => {
      'day': 'W-${i + 1}',
      'temperature': [27, 28, 29, 27][i],
      'humidity': [63, 65, 66, 62][i],
    },
  );

  List<Map<String, dynamic>> getCurrentData(String selectedPeriod) {
    switch (selectedPeriod) {
      case 'Day':
        return dayData;
      case 'Month':
        return monthData;
      case 'Week':
      default:
        return weekData;
    }
  }
}
