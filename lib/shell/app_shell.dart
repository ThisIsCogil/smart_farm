
import 'package:flutter/material.dart';

// ====== IMPORT HALAMANMU ======
import '../home/views/dashboard/home_page.dart';
import '../home/views/calendar/calendar_page.dart';
import '../home/views/scan/scan_page.dart';
import '../home/views/stats/stats_page.dart';
import '../home/views/profile/profile_page.dart';

// ====== IMPORT NAV WRAPPER (ganti path sesuai lokasimu) ======
import '../home/widgets/custom_navbar.dart';
// ^ file ini harus berisi class HideOnScrollNavScaffold + CustomBottomNavigationBar
//   (versi satu file yang tadi kamu kirim/aku kirim balik)

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  // Pastikan tiap page scrollable agar mekanisme hide-on-scroll aktif.
  // DashboardScreen kamu sudah scrollable. Untuk halaman lain,
  // kalau masih pendek, tambahkan ListView/SingleChildScrollView di file masing-masing.
  late final List<Widget> _pages = [
    DashboardScreen(),
    CalendarScreen(),
    ScanPage(),
    StatsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return HideOnScrollNavScaffold(
      pages: _pages,
      currentIndex: _index,
      onTabChanged: (i) => setState(() => _index = i),

      // Opsional: kalau ingin custom icon, isi di sini;
      // kalau tidak diisi, akan pakai default (home, calendar, play, chart, person).
      icons: [
        Icons.home_sharp,
        Icons.calendar_today_outlined,
        Icons.camera_alt_sharp,
        Icons.bar_chart_outlined,
        Icons.person_outlined,
      ],

      // Opsional: tweak durasi animasi
      duration: const Duration(milliseconds: 220),
    );
  }
}
