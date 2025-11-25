import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../controller/stats_controller.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  // Controller yang akan ambil data dari AirQualityModel (Flask API → IoTDB)
  final StatsController c = StatsController();

  @override
  void initState() {
    super.initState();
    c.init(refresh: () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF6D4C41);
    const inactiveColor = Color(0xFF9E9E9E);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight + 50),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== Card utama =====
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ===== Header - IMPROVED LAYOUT =====
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Baris pertama: Judul + Tombol Reload
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Bagian kiri: Judul
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Air Quality',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: activeColor,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Graphics history',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Bagian kanan: Tombol Reload
                                    InkWell(
                                      onTap: c.isLoading
                                          ? null
                                          : () {
                                              c.loadData();
                                            },
                                      borderRadius: BorderRadius.circular(999),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6D4C41),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: c.isLoading
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Colors.white),
                                                ),
                                              )
                                            : const Icon(
                                                Icons.refresh,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Baris kedua: Date picker
                                InkWell(
                                  onTap: () => c.pickAnchor(context),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      border: Border.all(
                                          color: const Color(0xFFE0E0E0)),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: activeColor.withOpacity(0.7),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              c.rangeLabel,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF5D4037),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: activeColor.withOpacity(0.7),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // ===== Tabs (Hour / Day / Week) =====
                            Row(
                              children: [
                                // TAB HOUR
                                Expanded(
                                  child: InkWell(
                                    onTap: () => c.changePeriod('Hour'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: c.selectedPeriod == 'Hour'
                                                ? activeColor
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Hour',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: c.selectedPeriod == 'Hour'
                                              ? activeColor
                                              : inactiveColor,
                                          fontWeight: c.selectedPeriod == 'Hour'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // TAB DAY
                                Expanded(
                                  child: InkWell(
                                    onTap: () => c.changePeriod('Day'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: c.selectedPeriod == 'Day'
                                                ? activeColor
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Day',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: c.selectedPeriod == 'Day'
                                              ? activeColor
                                              : inactiveColor,
                                          fontWeight: c.selectedPeriod == 'Day'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // TAB WEEK
                                Expanded(
                                  child: InkWell(
                                    onTap: () => c.changePeriod('Week'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: c.selectedPeriod == 'Week'
                                                ? activeColor
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Week',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: c.selectedPeriod == 'Week'
                                              ? activeColor
                                              : inactiveColor,
                                          fontWeight: c.selectedPeriod == 'Week'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // ===== Chart =====
                            SizedBox(
                              height: 250,
                              child: Builder(
                                builder: (context) {
                                  if (c.isLoading && c.currentData.isEmpty) {
                                    // kalau lagi loading awal
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (c.currentData.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'Tidak ada data untuk rentang ini',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  }

                                  return BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: 100,
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipItem: (group, groupIndex,
                                                  rod, rodIndex) =>
                                              BarTooltipItem(
                                            '${rod.toY.round()}',
                                            const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              final i = value.toInt();
                                              if (i >= 0 &&
                                                  i < c.currentData.length) {
                                                // Kurangi label biar tidak terlalu rapat di mode Hour
                                                if (c.selectedPeriod ==
                                                        'Hour' &&
                                                    i % 5 != 0) {
                                                  return const SizedBox
                                                      .shrink();
                                                }

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(
                                                    c.currentData[i]['day']
                                                        .toString(),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 20,
                                            getTitlesWidget: (value, meta) =>
                                                Text(
                                              value.toInt().toString(),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            reservedSize: 30,
                                          ),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                      ),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: 20,
                                        getDrawingHorizontalLine: (value) =>
                                            const FlLine(
                                          color: Color(0xFFE0E0E0),
                                          strokeWidth: 1,
                                          dashArray: [5, 5],
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),

                                      // ===== 3 bar: temp, hum, soil =====
                                      barGroups: List.generate(
                                        c.currentData.length,
                                        (index) => BarChartGroupData(
                                          x: index,
                                          barsSpace: 4,
                                          barRods: [
                                            // Temperature
                                            BarChartRodData(
                                              toY: (c.currentData[index]
                                                      ['temperature'] as num)
                                                  .toDouble(),
                                              color: const Color(0xFF72bcd4),
                                              width: 8,
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top: Radius.circular(4),
                                              ),
                                            ),
                                            // Humidity
                                            BarChartRodData(
                                              toY: (c.currentData[index]
                                                      ['humidity'] as num)
                                                  .toDouble(),
                                              color: const Color(0xFF4CAF50),
                                              width: 8,
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top: Radius.circular(4),
                                              ),
                                            ),
                                            // Soil
                                            BarChartRodData(
                                              toY: (c.currentData[index]['soil']
                                                      as num)
                                                  .toDouble(),
                                              color: activeColor,
                                              width: 8,
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top: Radius.circular(4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ===== Legend =====
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegend('Temp', const Color(0xFF72bcd4)),
                                const SizedBox(width: 16),
                                _buildLegend('Humid', const Color(0xFF4CAF50)),
                                const SizedBox(width: 16),
                                _buildLegend('Soil', activeColor),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ===== Export Button =====
                      GestureDetector(
                        onTap: () => c.exportAndShareExcel(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4CAF50),
                                      Color(0xFF8BC34A)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.file_copy,
                                    color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 15),
                              const Expanded(
                                child: Text(
                                  'Export & Share',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6D4C41),
                                  ),
                                ),
                              ),
                              const Icon(Icons.ios_share,
                                  color: Color(0xFF6D4C41)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 30, height: 3, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}