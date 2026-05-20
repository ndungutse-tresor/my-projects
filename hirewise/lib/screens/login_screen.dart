import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/validation_mixin.dart';
import '../services/app_state.dart';
import '../core/errors/app_exceptions.dart';

enum _Role { student, tutor, admin }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin, ValidationMixin {
  _Role _selectedRole = _Role.student;
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _consentChecked = false;
  int _logoTapCount = 0;
  bool _adminUnlocked = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final _qualCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _appStatementCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _roles = [
    _RoleData(
      role: _Role.student,
      label: 'Student',
      subtitle: 'Learn from experts',
      icon: Icons.school_rounded,
      color: AppTheme.primaryBlue,
      route: '/',
    ),
    _RoleData(
      role: _Role.tutor,
      label: 'Tutor',
      subtitle: 'Teach & earn',
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFF059669),
      route: '/tutor',
    ),
    _RoleData(
      role: _Role.admin,
      label: 'Admin',
      subtitle: 'Manage platform',
      icon: Icons.admin_panel_settings_rounded,
      color: Color(0xFF7C3AED),
      route: '/admin',
    ),
  ];

  _RoleData get _current =>
      _roles.firstWhere((r) => r.role == _selectedRole);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmController.dispose();
    _phoneController.dispose();
    _specialtyCtrl.dispose();
    _qualCtrl.dispose();
    _expCtrl.dispose();
    _appStatementCtrl.dispose();
    super.dispose();
  }

  void _selectRole(_Role role) {
    if (!_isLogin && role == _Role.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Admin accounts are pre-created — sign-up is not available.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF7C3AED),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    if (_selectedRole == role) return;
    setState(() => _selectedRole = role);
    _animController
      ..reset()
      ..forward();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      if (!_isLogin && _selectedRole == _Role.admin) {
        _selectedRole = _Role.student;
      }
    });
    _animController
      ..reset()
      ..forward();
  }

  void _handleLogoTap() {
    _logoTapCount++;
    if (_logoTapCount >= 4) {
      _logoTapCount = 0;
      setState(() => _adminUnlocked = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.admin_panel_settings_rounded,
                  color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Admin access unlocked',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: const Color(0xFF7C3AED),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade500,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isLogin && !_consentChecked) {
      _showError(
          'Please accept the data processing consent to continue.');
      return;
    }
    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        final user = await AppState.instance.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (!mounted) return;
        final route = switch (user.role) {
          'tutor' => '/tutor',
          'admin' => '/admin',
          _ => '/',
        };
        Navigator.pushReplacementNamed(context, route);
      } else {
        await AppState.instance.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          role: _selectedRole.name,
          phone: _phoneController.text.trim(),
          specialty:
              _selectedRole == _Role.tutor ? _specialtyCtrl.text.trim() : '',
          qualifications:
              _selectedRole == _Role.tutor ? _qualCtrl.text.trim() : '',
          experience:
              _selectedRole == _Role.tutor ? _expCtrl.text.trim() : '',
          applicationStatement: _selectedRole == _Role.tutor
              ? _appStatementCtrl.text.trim()
              : '',
        );
        if (!mounted) return;
        if (_selectedRole == _Role.tutor) {
          _showTutorPendingDialog();
          return;
        }
        // Student: show email verification reminder before routing
        _showEmailVerificationReminder();
      }
    } on AppException catch (e) {
      if (e.code == 'email-not-verified') {
        _showVerifyEmailDialog(e.message);
      } else {
        _showError(e.message);
      }
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEmailVerificationReminder() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_unread_outlined,
                    size: 34, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 16),
              const Text('Check Your Inbox',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark)),
              const SizedBox(height: 10),
              const Text(
                'We sent a verification link to your email.\n\n'
                'Please verify your email address, then come back and sign in.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: AppTheme.textMuted, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    await AppState.instance.signOut();
                    nav.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Got it — go to email',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVerifyEmailDialog(String message) {
    bool resending = false;
    bool resent = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          content: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A56DB).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_unread_outlined,
                      size: 34, color: Color(0xFF1A56DB)),
                ),
                const SizedBox(height: 16),
                const Text('Verify Your Email',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark)),
                const SizedBox(height: 10),
                Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textMuted, height: 1.5)),
                if (resent) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Verification email sent!',
                        style: TextStyle(
                            color: Color(0xFF059669),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
                const SizedBox(height: 20),
                if (!resent)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: resending
                          ? null
                          : () async {
                              setD(() => resending = true);
                              await AppState.instance.resendVerificationEmail();
                              setD(() {
                                resending = false;
                                resent = true;
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: resending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Resend Verification Email',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    // Sign them out if resend wasn't used (still signed in)
                    if (!resent) {
                      await AppState.instance.signOut();
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(resent ? 'Close' : 'I\'ll verify later',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailCtrl =
        TextEditingController(text: _emailController.text.trim());
    bool sending = false;
    bool sent = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Reset Password',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter your account email and we\'ll send you a link to reset your password.',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                          height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    if (sent) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669)
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFF059669)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.mark_email_read_outlined,
                                color: Color(0xFF059669), size: 22),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Reset link sent!\nCheck your inbox (and spam folder).',
                                style: TextStyle(
                                    color: Color(0xFF059669),
                                    fontSize: 13,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Done',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        autofocus: true,
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.textDark),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'you@example.com',
                          prefixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF7F8FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppTheme.primaryBlue, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: sending
                              ? null
                              : () async {
                                  final email =
                                      emailCtrl.text.trim();
                                  if (email.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: const Text(
                                          'Please enter your email.'),
                                      backgroundColor:
                                          Colors.red.shade500,
                                      behavior:
                                          SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  12)),
                                      margin: const EdgeInsets.all(16),
                                    ));
                                    return;
                                  }
                                  setSheet(() => sending = true);
                                  try {
                                    await AppState.instance
                                        .sendPasswordReset(email);
                                    setSheet(() {
                                      sending = false;
                                      sent = true;
                                    });
                                  } catch (e) {
                                    setSheet(() => sending = false);
                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                      _showError(e
                                          .toString()
                                          .replaceFirst(
                                              'Exception: ', ''));
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: sending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5))
                              : const Text('Send Reset Link',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTutorPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pending_outlined,
                    size: 36, color: Color(0xFF059669)),
              ),
              const SizedBox(height: 16),
              const Text('Application Submitted!',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark)),
              const SizedBox(height: 10),
              const Text(
                'Your tutor application has been received.\n\n'
                'First: verify your email (check your inbox).\n\n'
                'Then our admin team will review your profile. You\'ll have limited access until approval.\n\n'
                'Typical review time: 1–2 business days.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: AppTheme.textMuted, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    await AppState.instance.signOut();
                    nav.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Got it — check my email',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _current.color;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F9),
      body: Stack(
        children: [
          // Background decorative blobs
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  roleColor.withValues(alpha: 0.20),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -100,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.accentPurple.withValues(alpha: 0.14),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // Centered card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: roleColor.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo & location row
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _handleLogoTap,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [roleColor, AppTheme.accentPurple],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(Icons.bolt_rounded,
                                    color: Colors.white, size: 26),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text('HireWise',
                                style: TextStyle(
                                    color: AppTheme.textDark,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.8)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      size: 13, color: AppTheme.primaryBlue),
                                  SizedBox(width: 3),
                                  Text('Kigali, RW',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.primaryBlue,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Role selector
                        const Text('I am a...',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textMuted,
                                letterSpacing: 0.3)),
                        const SizedBox(height: 10),
                        Builder(builder: (context) {
                          final visibleRoles = _adminUnlocked
                              ? _roles
                              : _roles
                                  .where((r) => r.role != _Role.admin)
                                  .toList();
                          return Row(
                            children: visibleRoles
                                .asMap()
                                .entries
                                .map((e) {
                                  final idx = e.key;
                                  final r = e.value;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selectRole(r.role),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 250),
                                        margin: EdgeInsets.only(
                                            right: idx <
                                                    visibleRoles.length - 1
                                                ? 8
                                                : 0),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        decoration: BoxDecoration(
                                          color: _selectedRole == r.role
                                              ? r.color
                                                  .withValues(alpha: 0.10)
                                              : const Color(0xFFF7F8FA),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: _selectedRole == r.role
                                                ? r.color
                                                : Colors.transparent,
                                            width: 1.8,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(r.icon,
                                                size: 26,
                                                color: _selectedRole ==
                                                        r.role
                                                    ? r.color
                                                    : Colors.grey.shade400),
                                            const SizedBox(height: 6),
                                            Text(r.label,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    color: _selectedRole ==
                                                            r.role
                                                        ? r.color
                                                        : AppTheme
                                                            .textMuted)),
                                            Text(r.subtitle,
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: _selectedRole ==
                                                            r.role
                                                        ? r.color.withValues(
                                                            alpha: 0.7)
                                                        : Colors
                                                            .grey.shade400)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          );
                        }),

                        const SizedBox(height: 24),

                        // Welcome text
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isLogin
                                    ? 'Welcome back.'
                                    : 'Create your account.',
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                    height: 1.2,
                                    letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isLogin
                                    ? 'Sign in as ${_current.label.toLowerCase()} to continue'
                                    : 'Join HireWise as a ${_current.label.toLowerCase()}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                    height: 1.4),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Form
                        SlideTransition(
                          position: _slideAnim,
                          child: FadeTransition(
                            opacity: _fadeAnim,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  if (!_isLogin) ...[
                                    _buildField(
                                      controller: _nameController,
                                      label: 'Full Name',
                                      hint: _selectedRole == _Role.student
                                          ? 'e.g. Jean Claude Nkurunziza'
                                          : _selectedRole == _Role.tutor
                                              ? 'e.g. Dr. Amina Uwase'
                                              : 'Admin Name',
                                      icon: Icons.person_outline_rounded,
                                      accentColor: roleColor,
                                      validator: validateName,
                                    ),
                                    const SizedBox(height: 14),
                                    _buildField(
                                      controller: _phoneController,
                                      label: 'Phone Number',
                                      hint: '+250 78x xxx xxx',
                                      icon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      accentColor: roleColor,
                                    ),
                                    const SizedBox(height: 14),
                                  ],

                                  _buildField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    hint: 'you@example.com',
                                    icon: Icons.mail_outline_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    accentColor: roleColor,
                                    validator: validateEmail,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    hint: '••••••••',
                                    icon: Icons.lock_outline_rounded,
                                    accentColor: roleColor,
                                    obscure: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                        color: AppTheme.textMuted,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                    validator: validatePassword,
                                  ),

                                  if (!_isLogin) ...[
                                    const SizedBox(height: 14),
                                    _buildField(
                                      controller: _confirmController,
                                      label: 'Confirm Password',
                                      hint: '••••••••',
                                      icon: Icons.lock_outline_rounded,
                                      accentColor: roleColor,
                                      obscure: _obscureConfirm,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirm
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 20,
                                          color: AppTheme.textMuted,
                                        ),
                                        onPressed: () => setState(() =>
                                            _obscureConfirm = !_obscureConfirm),
                                      ),
                                      validator: (v) => validateConfirmPassword(
                                          v, _passwordController.text),
                                    ),
                                  ],

                                  if (!_isLogin &&
                                      _selectedRole == _Role.tutor) ...[
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF059669)
                                            .withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                            color: const Color(0xFF059669)
                                                .withValues(alpha: 0.25)),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                              Icons.workspace_premium_rounded,
                                              size: 18,
                                              color: Color(0xFF059669)),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Tutor Application — Your profile will be reviewed by admin before activation.',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF059669),
                                                  height: 1.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    _buildField(
                                      controller: _specialtyCtrl,
                                      label: 'Specialty / Subject Area',
                                      hint:
                                          'e.g. Flutter Development, UI/UX Design',
                                      icon: Icons.work_outline_rounded,
                                      accentColor: roleColor,
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? 'Please enter your specialty'
                                              : null,
                                    ),
                                    const SizedBox(height: 14),
                                    _buildField(
                                      controller: _qualCtrl,
                                      label: 'Qualifications & Certifications',
                                      hint:
                                          'e.g. BSc Computer Science, AWS Certified',
                                      icon: Icons.school_outlined,
                                      accentColor: roleColor,
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? 'Please enter your qualifications'
                                              : null,
                                    ),
                                    const SizedBox(height: 14),
                                    _buildField(
                                      controller: _expCtrl,
                                      label: 'Years of Experience',
                                      hint: 'e.g. 3 years',
                                      icon: Icons.timeline_rounded,
                                      keyboardType: TextInputType.text,
                                      accentColor: roleColor,
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? 'Please enter your experience'
                                              : null,
                                    ),
                                    const SizedBox(height: 14),
                                    _buildField(
                                      controller: _appStatementCtrl,
                                      label: 'Application Statement',
                                      hint:
                                          'Why do you want to tutor on HireWise? What value do you bring to students?',
                                      icon: Icons.description_outlined,
                                      accentColor: roleColor,
                                      maxLines: 4,
                                      validator: (v) =>
                                          (v == null || v.trim().length < 30)
                                              ? 'Please write at least 30 characters'
                                              : null,
                                    ),
                                  ],

                                  if (!_isLogin) ...[
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () => setState(() =>
                                          _consentChecked = !_consentChecked),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Checkbox(
                                              value: _consentChecked,
                                              onChanged: (v) => setState(() =>
                                                  _consentChecked =
                                                      v ?? false),
                                              activeColor: roleColor,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text(
                                              'I consent to the processing of my personal data by HireWise in accordance with Rwanda Law No. 058/2021 on personal data protection. I may request access to or deletion of my data at any time.',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.textMuted,
                                                  height: 1.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  if (_isLogin) ...[
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: _showForgotPasswordDialog,
                                        child: Text('Forgot password?',
                                            style: TextStyle(
                                                color: roleColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 22),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: roleColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5),
                                            )
                                          : Text(
                                              _isLogin
                                                  ? 'Sign In as ${_current.label}'
                                                  : _selectedRole == _Role.tutor
                                                      ? 'Submit Tutor Application'
                                                      : 'Create ${_current.label} Account',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  Row(
                                    children: [
                                      Expanded(
                                          child: Divider(
                                              color: Colors.grey.shade200,
                                              thickness: 1)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14),
                                        child: Text('or',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade400)),
                                      ),
                                      Expanded(
                                          child: Divider(
                                              color: Colors.grey.shade200,
                                              thickness: 1)),
                                    ],
                                  ),

                                  const SizedBox(height: 18),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: _SocialButton(
                                          label: 'Google',
                                          icon: Icons.g_mobiledata_rounded,
                                          color: roleColor,
                                          onTap: _submit,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _SocialButton(
                                          label: 'Apple',
                                          icon: Icons.apple_rounded,
                                          color: roleColor,
                                          onTap: _submit,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isLogin
                                            ? "Don't have an account? "
                                            : 'Already have an account? ',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textMuted),
                                      ),
                                      GestureDetector(
                                        onTap: _toggleMode,
                                        child: Text(
                                          _isLogin ? 'Sign Up' : 'Sign In',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: roleColor,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color accentColor,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark)),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLines: obscure ? 1 : maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon:
                Icon(icon, size: 20, color: Colors.grey.shade400),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.red.shade300, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleData {
  final _Role role;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _RoleData({
    required this.role,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: AppTheme.textDark),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark)),
          ],
        ),
      ),
    );
  }
}
