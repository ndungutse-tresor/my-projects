import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/booking.dart';
import 'notification_service.dart';

class BookingService {
  final _db = FirebaseFirestore.instance;
  final _notifService = NotificationService();
  CollectionReference get _bookings => _db.collection('bookings');

  Future<Booking> createBooking(Booking booking) async {
    final ref = _bookings.doc();
    final newBooking = booking.copyWith(id: ref.id);
    await ref.set(newBooking.toFirestore());

    // Notify the expert of a new request.
    await _notifService.send(
      recipientUid: booking.expertId,
      type: 'booking_request',
      title: 'New Session Request',
      body: '${booking.clientName} wants to book "${booking.serviceName}".',
    );

    return newBooking;
  }

  Stream<List<Booking>> clientBookings(String clientId) {
    return _bookings
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Booking.fromFirestore(d)).toList());
  }

  Stream<List<Booking>> expertBookings(String expertId) {
    return _bookings
        .where('expertId', isEqualTo: expertId)
        .orderBy('scheduledAt')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Booking.fromFirestore(d)).toList());
  }

  Stream<int> allBookingsCountStream() {
    return _bookings.snapshots().map((q) => q.docs.length);
  }

  Future<void> updateStatus(String bookingId, BookingStatus status,
      [Booking? booking]) async {
    await _bookings.doc(bookingId).update({'status': status.name});

    if (booking == null) return;

    final (recipientUid, type, title, body) = switch (status) {
      BookingStatus.confirmed => (
          booking.clientId,
          'booking_confirmed',
          'Booking Confirmed!',
          '${booking.expertName} accepted your "${booking.serviceName}" session.',
        ),
      BookingStatus.cancelled => (
          booking.clientId,
          'booking_declined',
          'Booking Declined',
          '${booking.expertName} could not accept your "${booking.serviceName}" request.',
        ),
      BookingStatus.completed => (
          booking.clientId,
          'booking_completed',
          'Session Complete',
          'Your session with ${booking.expertName} is done. Leave a review!',
        ),
      _ => ('', '', '', ''),
    };

    if (recipientUid.isNotEmpty) {
      await _notifService.send(
        recipientUid: recipientUid,
        type: type,
        title: title,
        body: body,
      );
    }
  }
}
