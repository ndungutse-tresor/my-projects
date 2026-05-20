import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/message.dart';
import '../../models/chat_message.dart';

class ConversationService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _convos => _db.collection('conversations');

  Stream<List<Conversation>> conversationsStream(String userId) {
    return _convos
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Conversation.fromFirestore(d)).toList());
  }

  Stream<List<ChatMessage>> messagesStream(String conversationId) {
    return _convos
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatMessage.fromFirestore(d)).toList());
  }

  Future<String> getOrCreateConversation({
    required String userId,
    required String userName,
    required String expertId,
    required String expertName,
  }) async {
    final existing = await _convos
        .where('participantIds', arrayContains: userId)
        .get();

    for (final doc in existing.docs) {
      final ids = List<String>.from(doc['participantIds'] as List);
      if (ids.contains(expertId)) return doc.id;
    }

    final ref = _convos.doc();
    await ref.set({
      'participantIds': [userId, expertId],
      'participantNames': {userId: userName, expertId: expertName},
      'lastMessage': 'Start a conversation...',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCounts': {userId: 0, expertId: 0},
    });
    return ref.id;
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
    required String otherUserId,
  }) async {
    final batch = _db.batch();
    final msgRef =
        _convos.doc(conversationId).collection('messages').doc();
    batch.set(msgRef, {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
    batch.update(_convos.doc(conversationId), {
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCounts.$otherUserId': FieldValue.increment(1),
    });
    await batch.commit();
  }

  Future<void> markAsRead(String conversationId, String userId) async {
    await _convos
        .doc(conversationId)
        .update({'unreadCounts.$userId': 0});
  }
}
