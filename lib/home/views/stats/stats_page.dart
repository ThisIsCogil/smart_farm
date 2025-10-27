import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../controller/stats_controller.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // penting agar tetap bisa drag meski konten pendek
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                // +50px supaya SELALU ada sedikit scroll extent
                constraints: BoxConstraints(minHeight: constraints.maxHeight + 50),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== Card =====
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
                            // Header + label tanggal tappable (buka date range di controller)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Air Quality',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: activeColor,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Graphics history',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () => c.pickAnchor(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Color(0xFFE0E0E0)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      c.rangeLabel,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF5D4037),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // ===== Tabs (Day / Week / Month) =====
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => c.selectedPeriod = 'Day'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: c.selectedPeriod == 'Day' ? activeColor : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Day',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: c.selectedPeriod == 'Day' ? activeColor : inactiveColor,
                                          fontWeight: c.selectedPeriod == 'Day' ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => c.selectedPeriod = 'Week'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: c.selectedPeriod == 'Week' ? activeColor : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Week',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: c.selectedPeriod == 'Week' ? activeColor : inactiveColor,
                                          fontWeight: c.selectedPeriod == 'Week' ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => c.selectedPeriod = 'Month'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: c.selectedPeriod == 'Month' ? activeColor : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Month',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: c.selectedPeriod == 'Month' ? activeColor : inactiveColor,
                                          fontWeight: c.selectedPeriod == 'Month' ? FontWeight.bold : FontWeight.normal,
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
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: 100,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
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
                                          if (i >= 0 && i < c.currentData.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                c.currentData[i]['day'].toString(),
                                                style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                                        getTitlesWidget: (value, meta) => Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                        reservedSize: 30,
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 20,
                                    getDrawingHorizontalLine: (value) => const FlLine(
                                      color: Color(0xFFE0E0E0),
                                      strokeWidth: 1,
                                      dashArray: [5, 5],
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: List.generate(
                                    c.currentData.length,
                                    (index) => BarChartGroupData(
                                      x: index,
                                      barsSpace: 6,
                                      barRods: [
                                        BarChartRodData(
                                          toY: (c.currentData[index]['temperature'] as num).toDouble(),
                                          color: activeColor,
                                          width: 12,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                        ),
                                        BarChartRodData(
                                          toY: (c.currentData[index]['humidity'] as num).toDouble(),
                                          color: Color(0xFF8D6E63),
                                          width: 12,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ===== Legend =====
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegend('temperature', activeColor),
                                const SizedBox(width: 20),
                                _buildLegend('humidity', const Color(0xFF8D6E63)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ===== Export Button =====
                      GestureDetector(
                        onTap: () => c.exportToExcel(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                                    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.file_copy, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 15),
                              const Expanded(
                                child: Text(
                                  'Export File',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6D4C41),
                                  ),
                                ),
                              ),
                              const Icon(Icons.ios_share, color: Color(0xFF6D4C41)),
                            ],
                          ),
                        ),
                      ),

                      // Spacer bawah agar aman dengan navbar & memastikan scroll
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
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
