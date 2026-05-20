import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/expert_profile_screen.dart';
import 'screens/inbox_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/book_expert_screen.dart';
import 'screens/tutor_shell.dart';
import 'screens/admin_shell.dart';
import 'screens/tutor_verification_screen.dart';
import 'screens/student_study_screen.dart';
import 'models/expert.dart';
import 'services/app_state.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // On web, explicitly use LOCAL persistence so the session survives
  // tab reloads, new tabs, and browser restarts (stored in IndexedDB).
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
  // Admins are seeded manually via admin panel → Settings → Seed Demo Tutors
  runApp(const ProviderScope(child: HireWiseApp()));
}

class HireWiseApp extends ConsumerWidget {
  const HireWiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'HireWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const AuthGate());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/tutor':
            return MaterialPageRoute(builder: (_) => const TutorShell());
          case '/tutor/verify':
            return MaterialPageRoute(
                builder: (_) => const TutorVerificationScreen());
          case '/admin':
            return MaterialPageRoute(builder: (_) => const AdminShell());
          case '/expert':
            final expert = settings.arguments as Expert;
            return MaterialPageRoute(
              builder: (_) => ExpertProfileScreen(expert: expert),
            );
          case '/book':
            final expert = settings.arguments as Expert;
            return MaterialPageRoute(
              builder: (_) => BookExpertScreen(expert: expert),
            );
          default:
            return MaterialPageRoute(builder: (_) => const AuthGate());
        }
      },
    );
  }
}

// Watches the Firebase auth stream and routes to the correct shell.
// Also syncs AppState.currentUser so screens not yet on Riverpod still work.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => const _SplashScreen(),
      // Firestore error — if Firebase Auth still has a live session keep
      // showing the splash so the stream can recover, rather than booting
      // the user back to the login screen.
      error: (_, __) => FirebaseAuth.instance.currentUser != null
          ? const _SplashScreen()
          : const LoginScreen(),
      data: (user) {
        // Keep AppState in sync for screens that haven't migrated yet.
        AppState.instance.currentUser = user;
        if (user == null) return const LoginScreen();
        return switch (user.role) {
          'tutor' => const TutorShell(),
          'admin' => const AdminShell(),
          _ => const MainShell(),
        };
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.accentPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'ET',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'HireWise',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kigali\'s Expert Marketplace',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Student shell ─────────────────────────────────────────────────────────────

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    StudentStudyScreen(),
    InboxScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final totalUnread = ref.watch(conversationsProvider).valueOrNull
            ?.fold<int>(0, (acc, c) => acc + c.unreadCount) ??
        0;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book_rounded,
                  label: 'Study',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: 'Inbox',
                  isActive: _currentIndex == 2,
                  badge: totalUnread,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    this.badge = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryBlue.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? AppTheme.primaryBlue
                      : Colors.grey.shade400,
                  size: 24,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive
                        ? AppTheme.primaryBlue
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            if (badge > 0)
              Positioned(
                top: -4,
                right: -8,
                child: Container(
                  width: 17,
                  height: 17,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
