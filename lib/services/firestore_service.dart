import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lost_item.dart';
import '../models/app_notification.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _items =>
      _db.collection('items');
  static CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  static DocumentReference<Map<String, dynamic>> get _announcement =>
      _db.collection('config').doc('announcement');
  static CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');

  static Stream<List<LostItem>> getItemsStream() {
    return _items
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LostItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  static Stream<List<LostItem>> getUserItemsStream(String reporterEmail) {
    return _items
        .where('reporterEmail', isEqualTo: reporterEmail)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LostItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  static Future<void> addItem(LostItem item) async {
    await _items.add(item.toMap());
  }

  static Future<void> approveItem(String id) async {
    await _items.doc(id).update({'status': 'approved'});
  }

  static Future<void> markAsResolved(String id) async {
    await _items.doc(id).update({'isResolved': true});
  }

  static Future<void> deleteItem(String id) async {
    await _items.doc(id).delete();
  }

  static Future<void> saveUser({
    required String uid,
    required String name,
    required String email,
    required String fakultas,
    required String jurusan,
    required String phone,
    bool isAdmin = false,
  }) async {
    await _users.doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'fakultas': fakultas,
      'jurusan': jurusan,
      'phone': phone,
      'isAdmin': isAdmin,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  static Stream<String> getAnnouncementStream() {
    return _announcement.snapshots().map((doc) {
      if (doc.exists) {
        return doc.data()?['text'] as String? ??
            'Selamat datang di Lost & Found TelU.';
      }
      return 'Selamat datang di Lost & Found TelU.';
    });
  }

  static Future<void> updateAnnouncement(String text) async {
    await _announcement.set({'text': text}, SetOptions(merge: true));
  }

  static Stream<List<AppNotification>> getNotificationsStream(String userId) {
    return _notifications
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  static Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    await _notifications.add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': Timestamp.now(),
      'isRead': false,
    });
  }

  static Future<void> markNotificationsAsRead(String userId) async {
    final unread = await _notifications
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (var doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  static Future<void> clearAllNotifications(String userId) async {
    final allNotif = await _notifications
        .where('userId', isEqualTo: userId)
        .get();

    final batch = _db.batch();
    for (var doc in allNotif.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  static Future<void> deleteNotification(String id) async {
    await _notifications.doc(id).delete();
  }

  static Future<void> notifyAdmins({
    required String title,
    required String message,
    required String type,
  }) async {
    final admins = await _users.where('isAdmin', isEqualTo: true).get();
    final batch = _db.batch();

    for (var admin in admins.docs) {
      final notifRef = _notifications.doc();
      batch.set(notifRef, {
        'userId': admin.id,
        'title': title,
        'message': message,
        'type': type,
        'timestamp': Timestamp.now(),
        'isRead': false,
      });
    }
    await batch.commit();
  }
}
