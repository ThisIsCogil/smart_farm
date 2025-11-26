import 'package:flutter/material.dart';
import '../views/dashboard/notif_page.dart';
import '../controller/notif_controller.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFF6D4C41);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: brown.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              color: brown,
              size: 28,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pemilik',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Coffee Greenhouse Monitor',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF636E72),
                  ),
                ),
              ],
            ),
          ),

          // === ICON NOTIF + BADGE MERAH ===
          StreamBuilder<int>(
            // ⬅️ pakai controller langsung di sini
            stream: NotificationController().unreadCountStream(),
            builder: (context, snapshot) {
              final unread = snapshot.data ?? 0;

              // Debug kalau mau lihat di console:
              // print('UNREAD HEADER = $unread');

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationPage(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Color(0xFF2D3436),
                        size: 22,
                      ),
                    ),

                    if (unread > 0)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
