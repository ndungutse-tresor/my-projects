import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_user.dart';
import '../../models/booking.dart';
import '../../models/message.dart';
import '../../models/chat_message.dart';
import '../../models/app_notification.dart';
import '../../models/review.dart';
import '../services/expert_service.dart';
import '../services/booking_service.dart';
import '../services/conversation_service.dart';
import '../services/notification_service.dart';
import '../services/review_service.dart';
import 'auth_provider.dart';

// ── Service providers ─────────────────────────────────────────────────────────

final expertServiceProvider =
    Provider<ExpertService>((ref) => ExpertService());

final bookingServiceProvider =
    Provider<BookingService>((ref) => BookingService());

final conversationServiceProvider =
    Provider<ConversationService>((ref) => ConversationService());

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final reviewServiceProvider =
    Provider<ReviewService>((ref) => ReviewService());

// ── Pending tutors (admin dashboard) ─────────────────────────────────────────

final pendingTutorsProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.read(userServiceProvider).pendingTutorsStream();
});

// ── Admin stats (real-time counts) ───────────────────────────────────────────

final studentCountProvider = StreamProvider<int>((ref) {
  return ref.read(userServiceProvider).studentsCountStream();
});

final activeTutorCountProvider = StreamProvider<int>((ref) {
  return ref.read(userServiceProvider).activeTutorsCountStream();
});

final recentUsersProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.read(userServiceProvider).recentUsersStream();
});

final allBookingsCountProvider = StreamProvider<int>((ref) {
  return ref.read(bookingServiceProvider).allBookingsCountStream();
});

final studentsProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.read(userServiceProvider).usersByRoleStream('student');
});

final allTutorsProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.read(userServiceProvider).usersByRoleStream('tutor');
});

// ── Expert data ───────────────────────────────────────────────────────────────

final expertsStreamProvider = StreamProvider<List<Expert>>((ref) {
  return ref.read(expertServiceProvider).expertsStream();
});

final expertsBySectorProvider =
    StreamProvider.family<List<Expert>, String>((ref, sector) {
  return ref.read(expertServiceProvider).expertsStream(
        sector: sector == 'All' ? null : sector,
      );
});

final expertByIdProvider =
    StreamProvider.autoDispose.family<Expert?, String>((ref, id) {
  if (id.isEmpty) return Stream.value(null);
  return ref.read(expertServiceProvider).expertStream(id);
});

// ── Booking data ──────────────────────────────────────────────────────────────

final clientBookingsProvider =
    StreamProvider.family<List<Booking>, String>((ref, clientId) {
  return ref.read(bookingServiceProvider).clientBookings(clientId);
});

final expertBookingsProvider =
    StreamProvider.family<List<Booking>, String>((ref, expertId) {
  return ref.read(bookingServiceProvider).expertBookings(expertId);
});

// ── Conversation data ─────────────────────────────────────────────────────────

final conversationsProvider =
    StreamProvider.autoDispose<List<Conversation>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.read(conversationServiceProvider).conversationsStream(user.uid);
});

// ── Message data ──────────────────────────────────────────────────────────────

final messagesProvider =
    StreamProvider.autoDispose.family<List<ChatMessage>, String>(
        (ref, conversationId) {
  if (conversationId.isEmpty) return Stream.value([]);
  return ref
      .read(conversationServiceProvider)
      .messagesStream(conversationId);
});

// ── Notification data ─────────────────────────────────────────────────────────

final notificationsProvider =
    StreamProvider.autoDispose.family<List<AppNotification>, String>(
        (ref, uid) {
  if (uid.isEmpty) return Stream.value([]);
  return ref.read(notificationServiceProvider).notificationsStream(uid);
});

// ── Review data ───────────────────────────────────────────────────────────────

final clientReviewsProvider =
    StreamProvider.autoDispose.family<List<Review>, String>((ref, clientId) {
  if (clientId.isEmpty) return Stream.value([]);
  return ref.read(reviewServiceProvider).clientReviewsStream(clientId);
});

final expertReviewsProvider =
    StreamProvider.autoDispose.family<List<Review>, String>((ref, expertId) {
  if (expertId.isEmpty) return Stream.value([]);
  return ref.read(reviewServiceProvider).expertReviewsStream(expertId);
});

// ── Saved experts ─────────────────────────────────────────────────────────────

final savedExpertsProvider =
    Provider.autoDispose<List<Expert>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  final allExperts = ref.watch(expertsStreamProvider).valueOrNull ?? [];
  if (user == null) return [];
  final ids = user.savedExpertIds.toSet();
  return allExperts.where((e) => ids.contains(e.id)).toList();
});
