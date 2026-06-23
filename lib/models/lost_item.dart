import 'package:cloud_firestore/cloud_firestore.dart';

class LostItem {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime date;
  String status; // 'pending' or 'approved'
  final String type; // 'hilang' or 'ditemukan'
  bool isResolved;
  final String? imageUrl;
  final String reporterEmail;
  final String reporterPhone;
  final double? latitude;
  final double? longitude;

  LostItem({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    this.status = 'approved',
    required this.type,
    this.isResolved = false,
    this.imageUrl,
    required this.reporterEmail,
    required this.reporterPhone,
    this.latitude,
    this.longitude,
  });

  /// Konversi ke Map untuk disimpan ke Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'status': status,
      'type': type,
      'isResolved': isResolved,
      'imageUrl': imageUrl,
      'reporterEmail': reporterEmail,
      'reporterPhone': reporterPhone,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Buat LostItem dari data Firestore.
  factory LostItem.fromMap(Map<String, dynamic> map, String docId) {
    return LostItem(
      id: docId,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      location: map['location'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] as String? ?? 'pending',
      type: map['type'] as String? ?? 'hilang',
      isResolved: map['isResolved'] as bool? ?? false,
      imageUrl: map['imageUrl'] as String?,
      reporterEmail: map['reporterEmail'] as String? ?? '',
      reporterPhone: map['reporterPhone'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }
}



