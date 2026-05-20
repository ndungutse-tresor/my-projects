import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/verification.dart';
import '../../models/report.dart';
import '../services/storage_service.dart';
import '../services/verification_service.dart';
import '../services/report_service.dart';
import 'auth_provider.dart';

// ── Service providers ─────────────────────────────────────────────────────────

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

final verificationServiceProvider =
    Provider<VerificationService>((ref) => VerificationService());

final reportServiceProvider =
    Provider<ReportService>((ref) => ReportService());

// ── Tutor's own application stream ───────────────────────────────────────────

final myVerificationProvider =
    StreamProvider.autoDispose<VerificationApplication?>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null || user.role != 'tutor') return Stream.value(null);
  return ref
      .read(verificationServiceProvider)
      .applicationStream(user.uid);
});

// ── Admin queue streams ───────────────────────────────────────────────────────

final pendingVerificationsProvider =
    StreamProvider<List<VerificationApplication>>((ref) {
  return ref
      .read(verificationServiceProvider)
      .pendingApplicationsStream();
});

final pendingReportsProvider =
    StreamProvider<List<Report>>((ref) {
  return ref.read(reportServiceProvider).pendingReportsStream();
});

// ── Audit log ─────────────────────────────────────────────────────────────────

final auditLogProvider =
    StreamProvider.autoDispose.family<List<AuditLogEntry>, String>(
  (ref, tutorId) => ref
      .read(verificationServiceProvider)
      .auditLogStream(tutorId),
);

final allAuditLogProvider = StreamProvider<List<AuditLogEntry>>((ref) {
  return ref.read(verificationServiceProvider).allAuditLogStream();
});
