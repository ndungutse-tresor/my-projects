import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String bookingId;
  final String clientId;
  final String clientName;
  final String expertId;
  final String expertName;
  final String expertTitle;
  final int stars;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.bookingId,
    required this.clientId,
    required this.clientName,
    required this.expertId,
    required this.expertName,
    this.expertTitle = '',
    required this.stars,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      bookingId: data['bookingId'] as String? ?? '',
      clientId: data['clientId'] as String? ?? '',
      clientName: data['clientName'] as String? ?? '',
      expertId: data['expertId'] as String? ?? '',
      expertName: data['expertName'] as String? ?? '',
      expertTitle: data['expertTitle'] as String? ?? '',
      stars: data['stars'] as int? ?? 5,
      comment: data['comment'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'bookingId': bookingId,
        'clientId': clientId,
        'clientName': clientName,
        'expertId': expertId,
        'expertName': expertName,
        'expertTitle': expertTitle,
        'stars': stars,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
