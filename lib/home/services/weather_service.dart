import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  final String baseUrl = 'https://api.open-meteo.com/v1/forecast';
  final String geocodingUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  Future<Map<String, dynamic>?> _getCoordinates(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$geocodingUrl?name=$city&count=1&language=en&format=json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          return {
            'latitude': result['latitude'],
            'longitude': result['longitude'],
            'name': result['name'],
          };
        }
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting coordinates: $e');
      return null;
    }
  }

  Future<WeatherData?> getWeather(String city) async {
    try {
      final coordinates = await _getCoordinates(city);
      if (coordinates == null) return null;

      final response = await http.get(
        Uri.parse(
          '$baseUrl?latitude=${coordinates['latitude']}&longitude=${coordinates['longitude']}'
          '&current=temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m'
          '&timezone=auto',
        ),
      );

      if (response.statusCode == 200) {
        return WeatherData.fromJson(
          json.decode(response.body),
          coordinates['name'],
        );
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching weather: $e');
      return null;
    }
  }

  Future<WeatherData?> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl?latitude=$lat&longitude=$lon'
          '&current=temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m'
          '&timezone=auto',
        ),
      );

      if (response.statusCode == 200) {
        String locationName = 'Jember';
        try {
          final geoResponse = await http.get(
            Uri.parse(
              'https://geocoding-api.open-meteo.com/v1/search?'
              'latitude=$lat&longitude=$lon&count=1',
            ),
          );
          if (geoResponse.statusCode == 200) {
            final geoData = json.decode(geoResponse.body);
            if (geoData['results'] != null && geoData['results'].isNotEmpty) {
              locationName = geoData['results'][0]['name'];
            }
          }
        } catch (e) {
          // ignore: avoid_print
          print('Error getting location name: $e');
        }

        return WeatherData.fromJson(
          json.decode(response.body),
          locationName,
        );
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching weather: $e');
      return null;
    }
  }
}