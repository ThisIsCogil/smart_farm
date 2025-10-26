class WeatherData {
final double temperature;
final String condition;
final double humidity;
final double windSpeed;
final double rainfall;
final String location;
final DateTime timestamp;


WeatherData({
required this.temperature,
required this.condition,
required this.humidity,
required this.windSpeed,
required this.rainfall,
required this.location,
required this.timestamp,
});


factory WeatherData.fromJson(Map<String, dynamic> json, String locationName) {
final current = json['current'];


String getCondition(int? weatherCode) {
if (weatherCode == null) return 'Clear';
if (weatherCode == 0) return 'Clear';
if (weatherCode >= 1 && weatherCode <= 3) return 'Clouds';
if (weatherCode >= 51 && weatherCode <= 67) return 'Rain';
if (weatherCode >= 71 && weatherCode <= 77) return 'Snow';
if (weatherCode >= 80 && weatherCode <= 82) return 'Rain';
if (weatherCode >= 95 && weatherCode <= 99) return 'Thunderstorm';
return 'Clear';
}


return WeatherData(
temperature: (current['temperature_2m']?.toDouble() ?? 0.0),
condition: getCondition(current['weather_code']),
humidity: (current['relative_humidity_2m']?.toDouble() ?? 0.0),
windSpeed: (current['wind_speed_10m']?.toDouble() ?? 0.0),
rainfall: (current['precipitation']?.toDouble() ?? 0.0),
location: locationName,
timestamp: DateTime.parse(current['time']),
);
}
}