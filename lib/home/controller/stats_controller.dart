import 'dart:async';
import 'dart:io';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/stats_model.dart';

class StatsController {
  // ===== State =====
  String selectedPeriod = 'Week';
  DateTime anchorDate = DateTime.now();

  // === Ticker real-time (update label tiap pergantian menit) ===
  Timer? _ticker;
  int _lastMinute = DateTime.now().minute;

  // === Model ===
  final AirQualityModel _model = AirQualityModel();

  // Callback untuk memicu refresh UI (dipasang dari View)
  VoidCallback? _refresh;

  void init({VoidCallback? refresh}) {
    _refresh = refresh;
    _ticker = Timer.periodic(const Duration(seconds: 5), (_) {
      final now = DateTime.now();
      if (now.minute != _lastMinute) {
        _lastMinute = now.minute;
        anchorDate = now;
        _refresh?.call();
      }
    });
  }

  void dispose() {
    _ticker?.cancel();
  }

  // ===================== DATA AKTIF =====================
  List<Map<String, dynamic>> get currentData =>
      _model.getCurrentData(selectedPeriod);

  // ===================== UTIL TANGGAL (ID) =====================
  static const _bulanPendek = [
    'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'
  ];
  static const _bulanPanjang = [
    'Januari','Februari','Maret','April','Mei','Juni','Juli',
    'Agustus','September','Oktober','November','Desember'
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

  String _formatMonthYearID(DateTime d) =>
      '${_bulanPanjang[d.month - 1]} ${d.year}';

  String get rangeLabel {
    switch (selectedPeriod) {
      case 'Day':
        return _formatDateID(anchorDate);
      case 'Week':
        return _formatWeekRangeID(anchorDate);
      case 'Month':
        return _formatMonthYearID(anchorDate);
      default:
        return '';
    }
  }

  Future<void> pickAnchor(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: anchorDate,
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null) {
      anchorDate = picked;
      _refresh?.call();
    }
  }

  // ===================== EXPORT EXCEL =====================
  Future<void> exportToExcel(BuildContext context) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin penyimpanan dibutuhkan')),
        );
        return;
      }

      final excel = excel_pkg.Excel.createExcel();
      final sheet = excel['Air Quality - $selectedPeriod'];

      // Header
      sheet.appendRow([
        excel_pkg.TextCellValue('Label'),
        excel_pkg.TextCellValue('Temperature'),
        excel_pkg.TextCellValue('Humidity'),
      ]);

      // Rows sesuai tab aktif
      for (final row in currentData) {
        sheet.appendRow([
          excel_pkg.TextCellValue(row['day'].toString()),
          excel_pkg.IntCellValue(row['temperature'] as int),
          excel_pkg.IntCellValue(row['humidity'] as int),
        ]);
      }

      final directory = await getExternalStorageDirectory();
      final safeDir = directory ?? await getApplicationDocumentsDirectory();
      final filePath =
          '${safeDir.path}/air_quality_${selectedPeriod.toLowerCase()}.xlsx';

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File tersimpan: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal export: $e')),
      );
    }
  }
}
