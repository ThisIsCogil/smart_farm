class NotificationItem {
  final String id;
  final String sensorId;
  final String sensorName;
  final double value;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.sensorId,
    required this.sensorName,
    required this.value,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'].toString(), // jaga-jaga kalau uuid / int
      sensorId: json['sensor_id'] as String? ?? '',
      sensorName: json['sensor_name'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      // 🔴 PENTING: baca dari is_read, default false kalau null
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sensor_id': sensorId,
      'sensor_name': sensorName,
      'value': value,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}
