import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart' as excel_pkg;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // masih bisa dipakai kalau nanti butuh
import 'package:share_plus/share_plus.dart';

import '../models/stats_model.dart';

class StatsController {
  // ===== State utama =====
  String selectedPeriod = 'Hour'; // default: Hour
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

  // ===================== Pick tanggal =====================
  Future<void> pickAnchor(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: anchorDate,
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null) {
      // untuk Hour, kita pertahankan jam sekarang, ganti hanya tanggalnya
      anchorDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        anchorDate.hour,
        anchorDate.minute,
      );
      await loadData();
    }
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
        return '${_formatDateID(anchorDate)} • $h:00';
      case 'Day':
        return _formatDateID(anchorDate);
      case 'Week':
        return _formatWeekRangeID(anchorDate);
      default:
        return '';
    }
  }

  // ===================== Export ke Excel + Share ================
  Future<void> exportAndShareExcel(BuildContext context) async {
    try {
      // 1. Buat file Excel
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

      // 2. Simpan ke folder dokumen aplikasi (AMAN utk Android 10–14)
      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/air_quality_${selectedPeriod.toLowerCase()}.xlsx';

      final file = File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      // 3. Tampilkan notif lokal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File tersimpan: $filePath')),
      );

      // 4. Buka share sheet → pilih WhatsApp dll
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
