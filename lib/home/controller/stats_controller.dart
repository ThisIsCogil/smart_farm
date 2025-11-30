import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart' as excel_pkg;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../models/stats_model.dart';

class StatsController {
  // ===== State utama =====
  String selectedPeriod = 'Hour'; // 'Hour' | 'Day' | 'Week'
  DateTime anchorDate = DateTime.now();

  // Ticker real-time (opsional)
  Timer? _ticker;
  int _lastMinute = DateTime.now().minute;

  // Model (Flask API → IoTDB)
  final AirQualityModel _model = AirQualityModel();

  // Data & loading
  List<Map<String, dynamic>> _data = [];
  bool isLoading = false;

  List<Map<String, dynamic>> get currentData => _data;

  // Callback untuk refresh UI
  VoidCallback? _refresh;

  void init({VoidCallback? refresh}) {
    _refresh = refresh;

    // Ticker tiap 5 detik → kalau menit berubah, anchorDate ikut update
    _ticker = Timer.periodic(const Duration(seconds: 5), (_) {
      final now = DateTime.now();
      if (now.minute != _lastMinute) {
        _lastMinute = now.minute;
        anchorDate = now;
        _refresh?.call();
      }
    });

    // Load pertama kali
    loadData();
  }

  void dispose() {
    _ticker?.cancel();
  }

  // ===================== Ubah periode =====================
  void changePeriod(String period) {
    if (selectedPeriod == period) return;
    selectedPeriod = period;
    loadData();
  }

  // ===================== Util tanggal (Indonesia) =========
  static const _bulanPendek = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des'
  ];
  static const _bulanPanjang = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  String _formatDateID(DateTime d) =>
      '${d.day} ${_bulanPendek[d.month - 1]} ${d.year}';

  DateTime _mondayOf(DateTime d) {
    final wd = d.weekday; // 1=Mon..7=Sun
    return d.subtract(Duration(days: wd - 1));
  }

  String _formatWeekRangeID(DateTime d) {
    final start = _mondayOf(d);
    final end = start.add(const Duration(days: 6));
    return '${_formatDateID(start)} – ${_formatDateID(end)}';
  }

  String get rangeLabel {
    switch (selectedPeriod) {
      case 'Hour':
        final h = anchorDate.hour.toString().padLeft(2, '0');
        return '${_formatDateID(anchorDate)} • $h:00 - $h:59';
      case 'Day':
        return _formatDateID(anchorDate);
      case 'Week':
        return _formatWeekRangeID(anchorDate);
      default:
        return '';
    }
  }

  // ===================== Bottom sheet minimalis (Tanggal + Jam) =====================

  Future<DateTime?> _showMinimalDateTimePicker(
    BuildContext context,
    DateTime initial,
    String period,
  ) async {
    final now = DateTime.now();
    final isHour = period == 'Hour';
    final isWeek = period == 'Week';

    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        DateTime tempDate = DateTime(initial.year, initial.month, initial.day);
        int tempHour = initial.hour;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final weekLabel = isWeek ? _formatWeekRangeID(tempDate) : '';

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.6,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isHour
                          ? 'Pilih tanggal & jam'
                          : (period == 'Day'
                              ? 'Pilih tanggal'
                              : 'Pilih minggu'),
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // ================== ISI YANG BISA DISCROLL ==================
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          // =============== KALENDER DENGAN WARNA COKLAT ===============
                          Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme:
                                  Theme.of(ctx).colorScheme.copyWith(
                                        primary: Colors.brown,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                      ),
                            ),
                            child: CalendarDatePicker(
                              initialDate: tempDate.isAfter(now)
                                  ? now
                                  : tempDate,
                              firstDate: DateTime(2022, 1, 1),
                              lastDate: now,
                              onDateChanged: (d) {
                                setModalState(() {
                                  tempDate =
                                      DateTime(d.year, d.month, d.day);

                                  if (isHour) {
                                    final candidate = DateTime(
                                      tempDate.year,
                                      tempDate.month,
                                      tempDate.day,
                                      tempHour,
                                    );
                                    if (candidate.isAfter(now)) {
                                      if (tempDate.year == now.year &&
                                          tempDate.month == now.month &&
                                          tempDate.day == now.day) {
                                        tempHour = now.hour;
                                      }
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ================= WEEK LABEL =================
                          if (isWeek) ...[
                            Text(
                              'Minggu ini:',
                              style: Theme.of(ctx)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              weekLabel,
                              style: Theme.of(ctx)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // ================= PILIH JAM (KHUSUS HOUR) =================
                          if (isHour) ...[
                            Text(
                              'Jam',
                              style: Theme.of(ctx)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: List.generate(24, (h) {
                                final label =
                                    '${h.toString().padLeft(2, '0')}:00';
                                final isSelected = tempHour == h;

                                return ChoiceChip(
                                  label: Text(label),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    if (!val) return;
                                    setModalState(() {
                                      tempHour = h;
                                    });
                                  },
                                  selectedColor: Colors.brown,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                  backgroundColor: Colors.grey[100],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),

                    // ================== TOMBOL ==================
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final result = DateTime(
                                  tempDate.year,
                                  tempDate.month,
                                  tempDate.day,
                                  isHour ? tempHour : 0,
                                  0,
                                  0,
                                );
                                Navigator.pop(ctx, result);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Terapkan',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===================== Pick anchor (Hour/Day/Week) pakai UI minimalis =====================
  Future<void> pickAnchor(BuildContext context) async {
    final picked = await _showMinimalDateTimePicker(
      context,
      anchorDate,
      selectedPeriod,
    );

    if (picked == null) return;

    if (selectedPeriod == 'Hour') {
      // ambil tanggal + jam, menit selalu 00
      anchorDate = picked;
    } else if (selectedPeriod == 'Day') {
      anchorDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        0,
        0,
        0,
      );
    } else if (selectedPeriod == 'Week') {
      // pakai tanggal yg dipilih sebagai anchor minggu
      anchorDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        0,
        0,
        0,
      );
    }

    await loadData();
  }

  // ===================== Load data dari model (Flask API) ==========
  Future<void> loadData() async {
    try {
      isLoading = true;
      _refresh?.call();

      _data = await _model.getCurrentData(selectedPeriod, anchorDate);
    } catch (e, st) {
      debugPrint('Error loadData: $e\n$st');
      _data = [];
    } finally {
      isLoading = false;
      _refresh?.call();
    }
  }

  // ===================== Export ke Excel + Share ================
  Future<void> exportAndShareExcel(BuildContext context) async {
    try {
      final excel = excel_pkg.Excel.createExcel();
      final sheet = excel['Air Quality - $selectedPeriod'];

      // Header
      sheet.appendRow([
        excel_pkg.TextCellValue('Label'),
        excel_pkg.TextCellValue('Temperature'),
        excel_pkg.TextCellValue('Humidity'),
        excel_pkg.TextCellValue('Soil'),
      ]);

      // Data
      for (final row in currentData) {
        sheet.appendRow([
          excel_pkg.TextCellValue(row['day'].toString()),
          excel_pkg.IntCellValue((row['temperature'] ?? 0) as int),
          excel_pkg.IntCellValue((row['humidity'] ?? 0) as int),
          excel_pkg.IntCellValue((row['soil'] ?? 0) as int),
        ]);
      }

      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/air_quality_${selectedPeriod.toLowerCase()}.xlsx';

      final file = File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File tersimpan: $filePath')),
      );

      final xfile = XFile(
        filePath,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );

      await Share.shareXFiles(
        [xfile],
        text: 'Riwayat kualitas lingkungan periode $selectedPeriod',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal export/share: $e')),
      );
    }
  }
}
