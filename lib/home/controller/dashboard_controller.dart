import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class DashboardController extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  WeatherData? weatherData;
  bool isLoading = true;

  Future<void> loadWeatherData() async {
    isLoading = true;
    notifyListeners();

    weatherData = await _weatherService.getWeatherByCoordinates(
      -8.1724, // Latitude Jember
      113.7006, // Longitude Jember
    );

    isLoading = false;
    notifyListeners();
  }
}
