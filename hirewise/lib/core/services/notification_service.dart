import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_notification.dart';

class NotificationService {
  final _db = FirebaseFirestore.instance;

  CollectionReference _notifs(String uid) =>
      _db.collection('users').doc(uid).collection('notifications');

  Stream<List<AppNotification>> notificationsStream(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _notifs(uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(AppNotification.fromFirestore).toList());
  }

  Future<void> send({
    required String recipientUid,
    required String type,
    required String title,
    required String body,
  }) async {
    if (recipientUid.isEmpty) return;
    await _notifs(recipientUid).add(AppNotification(
      id: '',
      type: type,
      title: title,
      body: body,
      createdAt: DateTime.now(),
    ).toFirestore());
  }

  Future<void> markAllRead(String uid) async {
    if (uid.isEmpty) return;
    final batch = _db.batch();
    final snap =
        await _notifs(uid).where('isRead', isEqualTo: false).get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<int> unreadCount(String uid) async {
    if (uid.isEmpty) return 0;
    final snap =
        await _notifs(uid).where('isRead', isEqualTo: false).count().get();
    return snap.count ?? 0;
  }
}
