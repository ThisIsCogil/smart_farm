import 'package:flutter/material.dart';
import '../../models/weather_model.dart';
import '../../services/weather_service.dart';
import '../../widgets/weather_and_pump.dart';
import '../../widgets/feature_cards.dart';
import '../../widgets/profile_header.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int)? onChangeTab; // ⬅ tambah ini

  const DashboardScreen({Key? key, this.onChangeTab}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() => _isLoading = true);
    try {
      final weatherData = await _weatherService.getWeatherByCoordinates(
        -8.1724, // Latitude Jember
        113.7006, // Longitude Jember
      );
      setState(() {
        _weatherData = weatherData;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
      // TODO: tampilkan snackbar/toast jika perlu
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tambahkan ruang bawah yang mempertimbangkan safe area + tinggi navbar
    final double bottomSpace = MediaQuery.of(context).padding.bottom +
        120.0; // ~tinggi navbar + margin

    return Scaffold(
      // Opsional: bikin transparan agar fleksibel jika background dipindah ke AppShell
      backgroundColor: Colors.transparent,

      // NAVBAR memang ada di AppShell, jadi di sini cukup body saja
      body: Stack(
        children: [
          // Background gradient
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Color(0xFF4A6741), Color(0xFFF5F5F5)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadWeatherData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          // HERO section (gambar + overlay + header + weather + sensor)
                          Stack(
                            children: [
                              Container(
                                height: 520,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: const AssetImage(
                                        'assets/coffee_farm.png'),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.15),
                                      BlendMode.darken,
                                    ),
                                    onError: (error, stackTrace) {},
                                  ),
                                ),
                              ),
                              Container(
                                height: 520,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.2),
                                      Colors.transparent,
                                      const Color(0xFFF5F5F5).withOpacity(0.8),
                                    ],
                                    stops: const [0.0, 0.3, 1.0],
                                  ),
                                ),
                              ),
                              // Konten atas gambar
                              Column(
                                children: [
                                  const ProfileHeader(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                      children: [
                                        if (_isLoading)
                                          const WeatherCardLoading()
                                        else if (_weatherData != null)
                                          WeatherCard(weatherData: _weatherData)
                                        else
                                          const WeatherErrorCard(),
                                        const SizedBox(height: 16),
                                        // SENSOR METRICS CARD DIPINDAH KE SINI (menggantikan WaterPumpCard)
                                        const SensorMetricsCard(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Section kartu-kartu fitur
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const ControlDevicesCard(),
                                const SizedBox(height: 16),

                                // Disease Detection → tab Scan (index 2)
                                DiseaseDetectionCard(
                                  onTap: () => widget.onChangeTab?.call(2),
                                ),
                                const SizedBox(height: 16),

                                // Archive Data → tab Stats (index 3)
                                ArchiveDataCard(
                                  onTap: () => widget.onChangeTab?.call(3),
                                ),
                                const SizedBox(height: 16),

                                // Daily Task → tab Calendar (index 1)
                                DailyTaskCard(
                                  onTap: () => widget.onChangeTab?.call(1),
                                ),
                                const SizedBox(height: 16),

                                ServerConfigCard(),
                                SizedBox(height: bottomSpace),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

/// Opsional: kartu error sederhana untuk cuaca
class WeatherErrorCard extends StatelessWidget {
  const WeatherErrorCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Text(
                'Gagal memuat data cuaca. Tarik ke bawah untuk mencoba lagi.'),
          ),
        ],
      ),
    );
  }
}
