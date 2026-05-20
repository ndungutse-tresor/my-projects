import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/review.dart';

class ReviewService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _reviews => _db.collection('reviews');

  Stream<List<Review>> clientReviewsStream(String clientId) {
    if (clientId.isEmpty) return Stream.value([]);
    return _reviews
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Review.fromFirestore).toList());
  }

  Stream<List<Review>> expertReviewsStream(String expertId) {
    if (expertId.isEmpty) return Stream.value([]);
    return _reviews
        .where('expertId', isEqualTo: expertId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Review.fromFirestore).toList());
  }

  Future<Review> createReview(Review review) async {
    final ref = _reviews.doc();
    await ref.set(review.toFirestore());
    await _updateExpertStats(review.expertId);
    return Review(
      id: ref.id,
      bookingId: review.bookingId,
      clientId: review.clientId,
      clientName: review.clientName,
      expertId: review.expertId,
      expertName: review.expertName,
      expertTitle: review.expertTitle,
      stars: review.stars,
      comment: review.comment,
      createdAt: review.createdAt,
    );
  }

  Future<bool> hasReviewed(String clientId, String bookingId) async {
    final snap = await _reviews
        .where('clientId', isEqualTo: clientId)
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> _updateExpertStats(String expertId) async {
    if (expertId.isEmpty) return;
    final snap =
        await _reviews.where('expertId', isEqualTo: expertId).get();
    if (snap.docs.isEmpty) return;
    final all = snap.docs.map(Review.fromFirestore).toList();
    final avg = all.fold<int>(0, (s, r) => s + r.stars) / all.length;
    await _db.collection('experts').doc(expertId).update({
      'rating': double.parse(avg.toStringAsFixed(1)),
      'reviewCount': all.length,
    });
  }
}
