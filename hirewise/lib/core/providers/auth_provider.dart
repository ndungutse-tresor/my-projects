import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final userServiceProvider = Provider<UserService>((ref) => UserService());

// Raw Firebase auth stream — emits whenever sign-in/sign-out happens
final firebaseAuthStreamProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Current AppUser derived from Firebase auth state + Firestore user doc.
// Uses asyncExpand (switchMap) so the Firestore stream is re-subscribed
// whenever the Firebase user changes.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final userService = ref.read(userServiceProvider);
  return FirebaseAuth.instance.authStateChanges().asyncExpand((firebaseUser) {
    if (firebaseUser == null) return Stream.value(null);
    return userService.userStream(firebaseUser.uid);
  });
});
