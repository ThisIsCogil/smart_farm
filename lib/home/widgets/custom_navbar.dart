import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HideOnScrollNavScaffold extends StatefulWidget {
  final List<Widget> pages;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final Duration duration;

  /// Opsional: kustom icon untuk tiap tab
  final List<IconData> icons;

  const HideOnScrollNavScaffold({
    Key? key,
    required this.pages,
    required this.currentIndex,
    required this.onTabChanged,
    this.duration = const Duration(milliseconds: 220),
    this.icons = const [
      Icons.home_outlined,
      Icons.calendar_today_outlined,
      Icons.play_circle_outline,
      Icons.bar_chart_outlined,
      Icons.person_outline,
    ],
  }) : super(key: key);

  @override
  State<HideOnScrollNavScaffold> createState() =>
      _HideOnScrollNavScaffoldState();
}

class _HideOnScrollNavScaffoldState extends State<HideOnScrollNavScaffold> {
  bool _showNav = true;

  // ambang perubahan scroll yang dianggap signifikan (px)
  static const double _deltaThreshold = 4.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // luar navbar transparan
      extendBody: true, // konten melebar ke bawah navbar
      body: Stack(
        children: [
          // fallback background (kalau page tidak punya background)
          const Positioned.fill(child: ColoredBox(color: Color(0xFFF7F7F7))),

          // === BODY + deteksi arah scroll (pakai UserScrollNotification.direction) ===
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Abaikan overscroll (tarik refresh/mentok)
              if (notification is OverscrollNotification) return false;

              // Jika konten hampir tidak bisa discroll, jangan hide/show
              if (notification.metrics.maxScrollExtent <= 24.0) {
                if (!_showNav) setState(() => _showNav = true);
                return false;
              }

              // Gerakan kecil: abaikan (biar gak “kedip”)
              if (notification is ScrollUpdateNotification &&
                  (notification.scrollDelta?.abs() ?? 0) < _deltaThreshold) {
                return false;
              }

              // Arah scroll yang valid ada pada UserScrollNotification.direction
              if (notification is UserScrollNotification) {
                final dir = notification.direction;
                if (dir == ScrollDirection.reverse && _showNav) {
                  setState(() => _showNav = false); // scroll down -> hide
                } else if (dir == ScrollDirection.forward && !_showNav) {
                  setState(() => _showNav = true); // scroll up -> show
                }
              }

              return false;
            },
            child: IndexedStack(
              index: widget.currentIndex,
              children: widget.pages,
            ),
          ),

          // === NAVBAR (floating di atas body) ===
          Positioned(
            left: 0,
            right: 0,
            bottom: -5, 
            child: AnimatedSlide(
              duration: widget.duration,
              curve: Curves.easeOutCubic,
              offset: _showNav ? Offset.zero : const Offset(0, 1),
              child: AnimatedOpacity(
                duration: widget.duration,
                opacity: _showNav ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !_showNav,
                  child: CustomBottomNavigationBar(
                    currentIndex: widget.currentIndex,
                    onItemSelected: widget.onTabChanged,
                    // icons opsional; kalau nggak diisi, Navbar pakai default internal
                    icons: widget.icons,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================================================================
/// CustomBottomNavigationBar
/// - `icons` OPSIONAL (punya default internal)
/// - Tetap putih, sudut bulat, shadow, aman dengan SafeArea
/// ===================================================================
class CustomBottomNavigationBar extends StatelessWidget {
  static const List<IconData> _defaultIcons = [
    Icons.home_filled,
    Icons.calendar_today,
    Icons.qr_code_scanner,
    Icons.bar_chart_outlined,
    Icons.person,
  ];

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  /// Opsional; jika null/empty, akan pakai `_defaultIcons`
  final List<IconData>? icons;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
    this.icons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = (icons == null || icons!.isEmpty) ? _defaultIcons : icons!;

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white, // navbar tetap solid
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            items.length,
            (i) => _item(i, items[i]),
          ),
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon) {
    return _BottomNavItem(
      icon: icon,
      isSelected: currentIndex == index,
      onTap: () => onItemSelected(index),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    Key? key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6D4C41).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF6D4C41) : const Color(0xFF95A5A6),
          size: 26,
        ),
      ),
    );
  }
}
