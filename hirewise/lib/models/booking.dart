import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { pending, confirmed, completed, cancelled }

class Booking {
  final String id;
  final String clientId;
  final String clientName;
  final String expertId;
  final String expertName;
  final String serviceName;
  final int servicePrice;
  final DateTime scheduledAt;
  final String notes;
  final BookingStatus status;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.expertId,
    required this.expertName,
    required this.serviceName,
    required this.servicePrice,
    required this.scheduledAt,
    this.notes = '',
    this.status = BookingStatus.pending,
    required this.createdAt,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      clientId: data['clientId'] as String? ?? '',
      clientName: data['clientName'] as String? ?? '',
      expertId: data['expertId'] as String? ?? '',
      expertName: data['expertName'] as String? ?? '',
      serviceName: data['serviceName'] as String? ?? '',
      servicePrice: data['servicePrice'] as int? ?? 0,
      scheduledAt:
          (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'] as String? ?? '',
      status: BookingStatus.values.firstWhere(
        (s) => s.name == (data['status'] as String? ?? 'pending'),
        orElse: () => BookingStatus.pending,
      ),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'clientId': clientId,
        'clientName': clientName,
        'expertId': expertId,
        'expertName': expertName,
        'serviceName': serviceName,
        'servicePrice': servicePrice,
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'notes': notes,
        'status': status.name,
        'createdAt': FieldValue.serverTimestamp(),
      };

  Booking copyWith({String? id, BookingStatus? status}) => Booking(
        id: id ?? this.id,
        clientId: clientId,
        clientName: clientName,
        expertId: expertId,
        expertName: expertName,
        serviceName: serviceName,
        servicePrice: servicePrice,
        scheduledAt: scheduledAt,
        notes: notes,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}
