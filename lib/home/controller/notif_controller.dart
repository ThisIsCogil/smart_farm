import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notif_model.dart';

class NotificationController {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<NotificationItem>> fetchNotifications() async {
    final res = await _supabase
        .from('notifications')
        .select('*')
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Stream semua notifikasi (insert/update/delete)
  Stream<List<NotificationItem>> notificationsStream() {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) {
      final list = rows
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList();

      // Debug optional:
      // for (final n in list) {
      //   print('notif: id=${n.id}, isRead=${n.isRead}');
      // }

      return list;
    });
  }

  /// Stream jumlah notif belum dibaca (isRead == false)
  Stream<int> unreadCountStream() {
    return notificationsStream().map((list) {
      final unread = list.where((n) => n.isRead == false).length;

      // Debug optional:
      // print('unreadCountStream = $unread');

      return unread;
    });
  }

  Future<void> markAsRead(String id) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }

  Future<void> markAllAsRead() async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('is_read', false);
  }
}
