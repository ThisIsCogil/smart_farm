import 'package:flutter/material.dart';
import '../../controller/notif_controller.dart';
import '../../models/notif_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

enum _StatusFilter { all, unread, read }
enum _DateFilter { all, today, last7, last30 }

class _NotificationPageState extends State<NotificationPage> {
  final NotificationController _c = NotificationController();

  // ===== STATE FILTER =====
  _StatusFilter _statusFilter = _StatusFilter.all;
  _DateFilter _dateFilter = _DateFilter.all;

  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFF6D4C41);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: brown,
        elevation: 2,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(14),
          ),
        ),
        title: Row(
          children: [
            // Back Button
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(50),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Title
            const Text(
              'Notifikasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),

            const Spacer(),

            // Reload button (force rebuild setelah ganti IP / config)
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
                color: Colors.white,
              ),
              tooltip: 'Reload',
              onPressed: () {
                // Kalau IP / Supabase client berubah di tempat lain,
                // tombol ini memaksa StreamBuilder attach ke stream baru.
                setState(() {});
              },
            ),

            // Mark all read
            TextButton.icon(
              onPressed: () async {
                await _c.markAllAsRead();
              },
              icon: const Icon(
                Icons.done_all_rounded,
                size: 16,
                color: Colors.white,
              ),
              label: const Text(
                'Baca',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ],
        ),
      ),

      // ===== BODY =====
      body: Column(
        children: [
          // ===========================
          //   FILTER BAR — COMPACT UI
          // ===========================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==== TITLE ====
                  Row(
                    children: const [
                      Icon(
                        Icons.filter_alt_rounded,
                        size: 16,
                        color: Color(0xFF6D4C41),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Filter",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6D4C41),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ==== STATUS CHIPS (compact) ====
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildMiniChip(
                          "Semua",
                          _StatusFilter.all,
                          Icons.list_alt_rounded,
                        ),
                        const SizedBox(width: 6),
                        _buildMiniChip(
                          "Belum",
                          _StatusFilter.unread,
                          Icons.notifications_active_rounded,
                        ),
                        const SizedBox(width: 6),
                        _buildMiniChip(
                          "Dibaca",
                          _StatusFilter.read,
                          Icons.mark_email_read_rounded,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==== DATE DROPDOWN (compact) ====
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButton<_DateFilter>(
                      value: _dateFilter,
                      underline: const SizedBox(),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                      ),
                      isExpanded: true,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[900],
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: _DateFilter.all,
                          child: Text("Semua tanggal"),
                        ),
                        DropdownMenuItem(
                          value: _DateFilter.today,
                          child: Text("Hari ini"),
                        ),
                        DropdownMenuItem(
                          value: _DateFilter.last7,
                          child: Text("7 hari terakhir"),
                        ),
                        DropdownMenuItem(
                          value: _DateFilter.last30,
                          child: Text("30 hari terakhir"),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _dateFilter = v);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== LIST NOTIF =====
          Expanded(
            child: StreamBuilder<List<NotificationItem>>(
              stream: _c.notificationsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rawList = snapshot.data ?? [];
                final now = DateTime.now();

                // ====== APPLY FILTERS ======
                final filtered = rawList.where((n) {
                  // Filter status read/unread
                  switch (_statusFilter) {
                    case _StatusFilter.unread:
                      if (n.isRead == true) return false;
                      break;
                    case _StatusFilter.read:
                      if (n.isRead == false) return false;
                      break;
                    case _StatusFilter.all:
                      break;
                  }

                  // Filter tanggal
                  final dt = n.createdAt.toLocal();
                  switch (_dateFilter) {
                    case _DateFilter.today:
                      if (!(dt.year == now.year &&
                          dt.month == now.month &&
                          dt.day == now.day)) {
                        return false;
                      }
                      break;
                    case _DateFilter.last7:
                      if (dt.isBefore(now.subtract(const Duration(days: 7)))) {
                        return false;
                      }
                      break;
                    case _DateFilter.last30:
                      if (dt.isBefore(now.subtract(const Duration(days: 30)))) {
                        return false;
                      }
                      break;
                    case _DateFilter.all:
                      break;
                  }

                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada notifikasi\nsesuai filter',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final n = filtered[index];

                    // Icon & warna untuk warning
                    const finalColor = Color(0xFFE53935);
                    IconData finalIcon;

                    final sensorNameLower = n.sensorName.toLowerCase();

                    // Deteksi tipe sensor
                    if (sensorNameLower.contains('tanah') ||
                        sensorNameLower.contains('soil')) {
                      finalIcon = Icons.grass_rounded;
                    } else if (sensorNameLower.contains('suhu') ||
                        sensorNameLower.contains('temperature')) {
                      finalIcon = Icons.thermostat_rounded;
                    } else if (sensorNameLower.contains('kelembaban') ||
                        sensorNameLower.contains('kelembapan') ||
                        sensorNameLower.contains('humidity') ||
                        sensorNameLower.contains('udara')) {
                      finalIcon = Icons.water_drop_rounded;
                    } else if (sensorNameLower.contains('moisture')) {
                      finalIcon = Icons.grass_rounded;
                    } else {
                      finalIcon = Icons.warning_amber_rounded;
                    }

                    return InkWell(
                      onTap: () => _c.markAsRead(n.id),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: n.isRead
                              ? Border.all(color: Colors.grey[200]!, width: 1)
                              : Border.all(
                                  color: finalColor.withOpacity(0.4),
                                  width: 2,
                                ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: finalColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                finalIcon,
                                color: finalColor,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          n.sensorName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Colors.grey[900],
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                      ),
                                      if (!n.isRead)
                                        Container(
                                          width: 10,
                                          height: 10,
                                          margin: const EdgeInsets.only(
                                              left: 8, top: 2),
                                          decoration: BoxDecoration(
                                            color: finalColor,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: finalColor
                                                    .withOpacity(0.4),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    n.message,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 13,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDateTime(n.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
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
            ),
          ),
        ],
      ),
    );
  }

  // ====== CHIP FILTER MINI (COMPACT) ======
  Widget _buildMiniChip(
    String label,
    _StatusFilter value,
    IconData icon,
  ) {
    final bool selected = _statusFilter == value;

    return GestureDetector(
      onTap: () => setState(() => _statusFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6D4C41) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.25),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey[800],
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final localDt = dt.toLocal();

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    return "${localDt.day} ${months[localDt.month - 1]} ${localDt.year}, "
        "${localDt.hour.toString().padLeft(2, '0')}:"
        "${localDt.minute.toString().padLeft(2, '0')}";
  }
}

/// =======================
/// ICON BELL + BADGE
/// =======================
class NotificationIconWithBadge extends StatelessWidget {
  final NotificationController controller;

  const NotificationIconWithBadge({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: controller.unreadCountStream(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationPage(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_rounded,
                  size: 26,
                ),
                if (count > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
