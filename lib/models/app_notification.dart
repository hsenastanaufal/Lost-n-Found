import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String userId; // Email atau ID pengguna penerima
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'report_approved', 'new_report', 'profile_update', dll.

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
      'type': type,
    };
  }

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null 
          ? (map['timestamp'] as Timestamp).toDate() 
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? 'info',
    );
  }
}
