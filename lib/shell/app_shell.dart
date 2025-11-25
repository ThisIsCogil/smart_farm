
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
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // fungsi untuk ganti tab dari mana saja (termasuk dari Dashboard)
    void changeTab(int i) {
      setState(() => _index = i);
    }

    _pages = [
      DashboardScreen(onChangeTab: changeTab), // ⬅ PENTING: kirim callback
      const CalendarScreen(),
      const ScanPage(),
      const StatsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return HideOnScrollNavScaffold(
      pages: _pages,
      currentIndex: _index,
      onTabChanged: (i) => setState(() => _index = i),
      icons: const [
        Icons.home_sharp,
        Icons.calendar_today_outlined,
        Icons.camera_alt_sharp,
        Icons.bar_chart_outlined,
      ],
      duration: const Duration(milliseconds: 220),
    );
  }
}
