import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../models/expert.dart';
import '../models/booking.dart';
import '../models/review.dart';
import '../services/app_state.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/app_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;

  AppUser? get _user => ref.read(currentUserProvider).valueOrNull;

  @override
  Widget build(BuildContext context) {
    ref.watch(currentUserProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildProfileBanner()),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(
            child: _buildMenuGroup(context, 'Account', [
              _MenuEntry(
                  icon: Icons.person_outline_rounded,
                  color: AppTheme.primaryBlue,
                  label: 'Edit Profile',
                  onTap: () => _showEditProfile(context)),
              _MenuEntry(
                  icon: Icons.shield_outlined,
                  color: const Color(0xFF7C3AED),
                  label: 'Verification & ID',
                  onTap: () => _showVerification(context)),
              _MenuEntry(
                  icon: Icons.lock_outline_rounded,
                  color: const Color(0xFF0891B2),
                  label: 'Privacy & Security',
                  onTap: () => _showPrivacySecurity(context)),
            ]),
          ),
          SliverToBoxAdapter(
            child: _buildMenuGroup(context, 'Activity', [
              _MenuEntry(
                  icon: Icons.work_outline_rounded,
                  color: const Color(0xFF059669),
                  label: 'My Projects',
                  badge: '2 active',
                  onTap: () => _showMyProjects(context)),
              _MenuEntry(
                  icon: Icons.favorite_outline_rounded,
                  color: const Color(0xFFDC2626),
                  label: 'Saved Experts',
                  badge: '3',
                  onTap: () => _showSavedExperts(context)),
              _MenuEntry(
                  icon: Icons.history_rounded,
                  color: const Color(0xFFD97706),
                  label: 'Booking History',
                  onTap: () => _showBookingHistory(context)),
              _MenuEntry(
                  icon: Icons.star_outline_rounded,
                  color: const Color(0xFFF59E0B),
                  label: 'My Reviews',
                  onTap: () => _showMyReviews(context)),
            ]),
          ),
          SliverToBoxAdapter(
            child: _buildMenuGroup(context, 'Preferences', [
              _MenuEntry(
                  icon: Icons.payment_outlined,
                  color: const Color(0xFF1A56DB),
                  label: 'Payment Methods',
                  onTap: () => _showPaymentMethods(context)),
              _MenuEntry(
                  icon: Icons.notifications_outlined,
                  color: const Color(0xFF7C3AED),
                  label: 'Notifications',
                  onTap: () {},
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (val) =>
                        setState(() => _notificationsEnabled = val),
                    activeThumbColor: AppTheme.primaryBlue,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )),
              _MenuEntry(
                  icon: Icons.language_outlined,
                  color: const Color(0xFF0891B2),
                  label: 'Language & Region',
                  onTap: () => _showLanguageRegion(context)),
            ]),
          ),
          SliverToBoxAdapter(
            child: _buildMenuGroup(context, 'Support', [
              _MenuEntry(
                  icon: Icons.help_outline_rounded,
                  color: const Color(0xFF059669),
                  label: 'Help Center',
                  onTap: () => _showHelpCenter(context)),
              _MenuEntry(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: const Color(0xFF7C3AED),
                  label: 'Contact Support',
                  onTap: () => _showContactSupport(context)),
              _MenuEntry(
                  icon: Icons.info_outline_rounded,
                  color: AppTheme.textMuted,
                  label: 'About HireWise',
                  onTap: () => _showAbout(context)),
            ]),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: GestureDetector(
                onTap: () => _showSignOutDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade100, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded,
                          size: 18, color: Colors.red.shade500),
                      const SizedBox(width: 8),
                      Text('Sign Out',
                          style: TextStyle(
                              color: Colors.red.shade500,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _teamMember('👩‍💻', 'Esther'),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade200,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        _teamMember('🧑‍💻', 'Tresor'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Built for Kigali  ·  2025',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.accentPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('My Profile',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                      GestureDetector(
                        onTap: () => _showPrivacySecurity(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.settings_outlined,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                            child: Center(
                              child: Text(
                                  _user?.initial ?? 'U',
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () => _showPhotoOptions(context),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppTheme.primaryBlue, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt_rounded,
                                    size: 12, color: AppTheme.primaryBlue),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_user?.name ?? 'Student',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(_user?.email ?? '',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 13)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                      _user?.location.isNotEmpty == true
                                          ? _user!.location
                                          : 'Kigali, Rwanda',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final uid = _user?.uid ?? '';
    final bookingsAsync =
        uid.isEmpty ? null : ref.watch(clientBookingsProvider(uid));
    final bookings = bookingsAsync?.valueOrNull ?? [];
    final total = bookings.length;
    final active = bookings
        .where((b) =>
            b.status == BookingStatus.pending ||
            b.status == BookingStatus.confirmed)
        .length;
    final spent = bookings.fold<int>(0, (sum, b) => sum + b.servicePrice);
    final spentLabel = spent >= 1000000
        ? 'RWF ${(spent / 1000000).toStringAsFixed(1)}M'
        : spent >= 1000
            ? 'RWF ${(spent / 1000).toStringAsFixed(0)}K'
            : 'RWF $spent';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('$total', 'Bookings'),
          Container(height: 36, width: 1, color: Colors.grey.shade200),
          _buildStatItem('$active', 'Active'),
          Container(height: 36, width: 1, color: Colors.grey.shade200),
          _buildStatItem(
              _user?.createdAt != null
                  ? '${_user!.createdAt.year}'
                  : '—',
              'Since'),
          Container(height: 36, width: 1, color: Colors.grey.shade200),
          _buildStatItem(total == 0 ? 'RWF 0' : spentLabel, 'Spent'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlue)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(
      BuildContext context, String title, List<_MenuEntry> entries) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(title,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade400,
                    letterSpacing: 0.6)),
          ),
          ...entries.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            return Column(
              children: [
                InkWell(
                  onTap: e.onTap,
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: e.color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(e.icon, size: 20, color: e.color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(e.label,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textDark)),
                        ),
                        if (e.trailing != null)
                          e.trailing!
                        else if (e.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue
                                  .withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(e.badge!,
                                style: const TextStyle(
                                    color: AppTheme.primaryBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          )
                        else
                          Icon(Icons.chevron_right_rounded,
                              size: 20, color: Colors.grey.shade300),
                      ],
                    ),
                  ),
                ),
                if (i < entries.length - 1)
                  Divider(
                      height: 1,
                      indent: 66,
                      endIndent: 16,
                      color: Colors.grey.shade100),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Change Profile Photo',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark)),
            const SizedBox(height: 16),
            _photoOption(Icons.camera_alt_rounded, 'Take Photo',
                'Use your device camera', () {
              Navigator.of(context).pop();
              _showSnack(context, 'Camera opened — photo captured!');
              setState(() {});
            }),
            const SizedBox(height: 10),
            _photoOption(Icons.photo_library_outlined, 'Choose from Gallery',
                'Select from your photos', () {
              Navigator.of(context).pop();
              _showSnack(context, 'Gallery opened — photo selected!');
              setState(() {});
            }),
            const SizedBox(height: 10),
            _photoOption(Icons.person_outline_rounded, 'Use Name Initial',
                'Keep the current avatar (${_user?.initial ?? "U"})', () {
              Navigator.of(context).pop();
              _showSnack(context, 'Using name initial as avatar');
            }),
          ],
        ),
      ),
    );
  }

  Widget _photoOption(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FB),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textDark)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    final nameCtrl = TextEditingController(text: _user?.name ?? '');
    final emailCtrl = TextEditingController(text: _user?.email ?? '');
    final phoneCtrl = TextEditingController(text: _user?.phone ?? '');
    final locationCtrl = TextEditingController(
        text: _user?.location.isNotEmpty == true
            ? _user!.location
            : 'Kigali, Rwanda');
    final bioCtrl = TextEditingController(text: _user?.bio ?? '');

    _showSheet(
      context,
      title: 'Edit Profile',
      child: StatefulBuilder(builder: (ctx, setSt) {
        return Column(
          children: [
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _showPhotoOptions(context);
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                      ),
                      child: Center(
                        child: Text(_user?.initial ?? 'U',
                            style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryBlue)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _showPhotoOptions(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sheetField('Full Name', nameCtrl, Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _sheetField('Email', emailCtrl, Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _sheetField('Phone', phoneCtrl, Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _sheetField('Location', locationCtrl, Icons.location_on_outlined),
            const SizedBox(height: 12),
            _sheetField('Bio', bioCtrl, Icons.notes_rounded, maxLines: 3),
            const SizedBox(height: 20),
            _primaryButton('Save Changes', () async {
              final uid = _user?.uid;
              if (uid != null) {
                await ref.read(userServiceProvider).updateUser(uid, {
                  if (nameCtrl.text.isNotEmpty) 'name': nameCtrl.text,
                  'phone': phoneCtrl.text,
                  'location': locationCtrl.text,
                  'bio': bioCtrl.text,
                });
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) _showSnack(context, 'Profile updated successfully');
            }),
          ],
        );
      }),
    );
  }

  void _showVerification(BuildContext context) {
    _showSheet(
      context,
      title: 'Verification & ID',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFF059669).withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      color: Color(0xFF059669), shape: BoxShape.circle),
                  child: const Icon(Icons.verified_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Identity Verified',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF059669))),
                      SizedBox(height: 2),
                      Text('Your account has been verified',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _verificationItem(
              'Government ID', 'National ID Card', true, Icons.badge_outlined),
          const SizedBox(height: 10),
          _verificationItem(
              'Phone Number',
              (_user?.phone.isNotEmpty == true) ? _user!.phone : 'Not added',
              _user?.phone.isNotEmpty == true,
              Icons.phone_outlined),
          const SizedBox(height: 10),
          _verificationItem('Email Address', _user?.email ?? '', true,
              Icons.email_outlined),
          const SizedBox(height: 10),
          _verificationItem(
              'Bank Account', 'Not yet linked', false, Icons.account_balance_outlined),
          const SizedBox(height: 20),
          _primaryButton('Link Bank Account', () {
            Navigator.pop(context);
            _showSnack(context, 'Redirecting to bank link…');
          }),
        ],
      ),
    );
  }

  Widget _verificationItem(
      String title, String subtitle, bool verified, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.textDark)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Icon(
            verified ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: verified ? const Color(0xFF059669) : Colors.grey.shade300,
            size: 20,
          ),
        ],
      ),
    );
  }

  void _showPrivacySecurity(BuildContext context) {
    bool twoFA = true;
    bool biometrics = false;
    bool activityVisible = true;

    _showSheet(
      context,
      title: 'Privacy & Security',
      child: StatefulBuilder(builder: (ctx, setSt) {
        return Column(
          children: [
            _toggleTile(
              ctx,
              icon: Icons.security_rounded,
              color: const Color(0xFF0891B2),
              title: 'Two-Factor Authentication',
              subtitle: 'Secure your account with OTP on login',
              value: twoFA,
              onChanged: (v) => setSt(() => twoFA = v),
            ),
            const SizedBox(height: 10),
            _toggleTile(
              ctx,
              icon: Icons.fingerprint_rounded,
              color: const Color(0xFF7C3AED),
              title: 'Biometric Login',
              subtitle: 'Use fingerprint or Face ID to sign in',
              value: biometrics,
              onChanged: (v) => setSt(() => biometrics = v),
            ),
            const SizedBox(height: 10),
            _toggleTile(
              ctx,
              icon: Icons.visibility_outlined,
              color: const Color(0xFF059669),
              title: 'Profile Visible to Experts',
              subtitle: 'Experts can see your profile when you hire',
              value: activityVisible,
              onChanged: (v) => setSt(() => activityVisible = v),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _showSnack(context, 'Password reset email sent');
              },
              icon: const Icon(Icons.lock_reset_rounded, size: 18),
              label: const Text('Change Password'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
                side: const BorderSide(color: AppTheme.primaryBlue),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showMyProjects(BuildContext context) {
    final uid = _user?.uid;
    _showSheet(
      context,
      title: 'My Projects',
      child: uid == null
          ? const Center(child: Text('Sign in to view projects'))
          : StreamBuilder(
              stream: ref.read(bookingServiceProvider).clientBookings(uid),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                        color: AppTheme.primaryBlue),
                  ));
                }
                final bookings = snapshot.data ?? [];
                final active = bookings
                    .where((b) =>
                        b.status == BookingStatus.pending ||
                        b.status == BookingStatus.confirmed)
                    .toList();
                if (active.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.folder_off_outlined,
                          size: 48, color: AppTheme.textMuted),
                      SizedBox(height: 12),
                      Text('No active projects',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark)),
                      SizedBox(height: 4),
                      Text('Book an expert to start a project',
                          style:
                              TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    ]),
                  );
                }
                return Column(
                  children: active.map((b) {
                    final p = _Project(
                      b.serviceName,
                      b.expertName,
                      b.status == BookingStatus.confirmed
                          ? 'Confirmed'
                          : 'Pending',
                      b.status == BookingStatus.confirmed
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                      'RWF ${(b.servicePrice / 1000).toStringAsFixed(0)}K',
                      '${b.scheduledAt.day}/${b.scheduledAt.month}/${b.scheduledAt.year}',
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _projectCard(p),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }

  Widget _projectCard(_Project p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(p.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textDark)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: p.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(p.status,
                    style: TextStyle(
                        color: p.statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 13, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(p.expert,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textMuted)),
              const Spacer(),
              Text(p.amount,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 12, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(p.dates,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  void _showSavedExperts(BuildContext context) {
    _showSheet(
      context,
      title: 'Saved Experts',
      child: Consumer(
        builder: (ctx, innerRef, _) {
          final saved = innerRef.watch(savedExpertsProvider);
          return saved.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_outline_rounded,
                            size: 40, color: AppTheme.textMuted),
                        SizedBox(height: 10),
                        Text('No saved experts yet',
                            style: TextStyle(
                                fontSize: 14, color: AppTheme.textMuted)),
                        Text('Tap the heart on any expert card to save them.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: saved
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _savedExpertCard(context, e),
                          ))
                      .toList(),
                );
        },
      ),
    );
  }

  Widget _savedExpertCard(BuildContext context, Expert e) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryBlue.withValues(alpha: 0.12),
            ),
            child: Center(
              child: Text(e.name[0],
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryBlue)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textDark)),
                Text(e.title,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 13, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 2),
                    Text('${e.rating}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark)),
                    const SizedBox(width: 6),
                    Text('from ₦${(e.startingPrice / 1000).round()}k',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_rounded,
                color: Color(0xFFDC2626), size: 22),
            onPressed: () {
              Navigator.pop(context);
              _showSnack(context, '${e.name} removed from saved');
            },
          ),
        ],
      ),
    );
  }

  void _showBookingHistory(BuildContext context) {
    final uid = _user?.uid;
    _showSheet(
      context,
      title: 'Booking History',
      child: uid == null
          ? const Center(child: Text('Sign in to view bookings'))
          : StreamBuilder(
              stream: ref
                  .read(bookingServiceProvider)
                  .clientBookings(uid),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                        color: AppTheme.primaryBlue),
                  ));
                }
                final bookings = snapshot.data ?? [];
                if (bookings.isEmpty) {
                  return Column(
                    children: [
                      const SizedBox(height: 24),
                      const Icon(Icons.work_off_outlined,
                          size: 48, color: AppTheme.textMuted),
                      const SizedBox(height: 12),
                      const Text('No bookings yet',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark)),
                      const SizedBox(height: 4),
                      const Text('Book an expert to get started',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textMuted)),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return Column(
                  children: bookings.map((b) {
                    final statusColor = switch (b.status) {
                      BookingStatus.confirmed => AppTheme.primaryBlue,
                      BookingStatus.completed => const Color(0xFF059669),
                      BookingStatus.cancelled => const Color(0xFFDC2626),
                      _ => const Color(0xFFD97706),
                    };
                    final fireBooking = _Booking(
                      b.serviceName,
                      b.expertName,
                      'RWF ${(b.servicePrice / 1000).toStringAsFixed(0)}K',
                      '${b.scheduledAt.day}/${b.scheduledAt.month}/${b.scheduledAt.year}',
                      b.status.name[0].toUpperCase() +
                          b.status.name.substring(1),
                      statusColor,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _bookingCard(fireBooking),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }

  Widget _bookingCard(_Booking b) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: b.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.work_outline_rounded,
                color: b.statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textDark)),
                Text(b.expert,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(b.amount,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.textDark)),
              Text(b.date,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMuted)),
              Container(
                margin: const EdgeInsets.only(top: 3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: b.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(b.status,
                    style: TextStyle(
                        color: b.statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMyReviews(BuildContext context) {
    final uid = _user?.uid ?? '';
    _showSheet(
      context,
      title: 'My Reviews',
      child: uid.isEmpty
          ? const Center(child: Text('Sign in to view reviews'))
          : StreamBuilder<List<Review>>(
              stream:
                  ref.read(reviewServiceProvider).clientReviewsStream(uid),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                        color: AppTheme.primaryBlue),
                  ));
                }
                final reviews = snapshot.data ?? [];
                if (reviews.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.rate_review_outlined,
                              size: 40, color: AppTheme.textMuted),
                          SizedBox(height: 10),
                          Text('No reviews yet',
                              style: TextStyle(
                                  fontSize: 14, color: AppTheme.textMuted)),
                          Text('Reviews you leave for experts appear here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: reviews
                      .map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _reviewCard(r),
                          ))
                      .toList(),
                );
              },
            ),
    );
  }

  Widget _reviewCard(Review r) {
    final dateStr = () {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[r.createdAt.month - 1]} ${r.createdAt.day}, ${r.createdAt.year}';
    }();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(r.expertName.isNotEmpty ? r.expertName[0] : '?',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBlue)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.expertName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppTheme.textDark)),
                    if (r.expertTitle.isNotEmpty)
                      Text(r.expertTitle,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Text(dateStr,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
                5,
                (i) => Icon(Icons.star_rounded,
                    size: 14,
                    color: i < r.stars
                        ? const Color(0xFFF59E0B)
                        : Colors.grey.shade200)),
          ),
          const SizedBox(height: 6),
          Text(r.comment,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textDark, height: 1.4)),
        ],
      ),
    );
  }

  void _showPaymentMethods(BuildContext context) {
    final name = _user?.name.isNotEmpty == true ? _user!.name : 'You';
    _showSheet(
      context,
      title: 'Payment Methods',
      child: Column(
        children: [
          _paymentCard(
            'MTN Mobile Money',
            _user?.phone.isNotEmpty == true ? _user!.phone : 'Not linked',
            '$name — MoMo',
            const Color(0xFFFFCB05),
            Icons.phone_android_rounded,
            isDefault: true,
            textColor: Colors.black87,
          ),
          const SizedBox(height: 10),
          _paymentCard(
            'Airtel Money',
            'Not linked',
            '$name — Airtel',
            const Color(0xFFED1C24),
            Icons.phone_android_rounded,
          ),
          const SizedBox(height: 10),
          _paymentCard(
            'Bank of Kigali',
            'Not linked',
            '$name — BK',
            const Color(0xFF1A56DB),
            Icons.account_balance_rounded,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCB05).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFFFCB05).withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: Color(0xFFB45309)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'MTN & Airtel Mobile Money are the primary payment methods in Rwanda.',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB45309),
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(String brand, String number, String detail, Color color,
      IconData icon, {bool isDefault = false, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDefault
                ? AppTheme.primaryBlue.withValues(alpha: 0.4)
                : Colors.grey.shade100,
            width: isDefault ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(brand,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppTheme.textDark)),
                    if (isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Default',
                            style: TextStyle(
                                color: AppTheme.primaryBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ]
                  ],
                ),
                Text(number,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
                Text(detail,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageRegion(BuildContext context) {
    const languages = [
      ('English', 'en', true),
      ('Français', 'fr', false),
      ('Igbo', 'ig', false),
      ('Yoruba', 'yo', false),
      ('Hausa', 'ha', false),
    ];
    int selected = 0;

    _showSheet(
      context,
      title: 'Language & Region',
      child: StatefulBuilder(builder: (ctx, setSt) {
        return Column(
          children: [
            ...languages.asMap().entries.map((entry) {
              final i = entry.key;
              final lang = entry.value;
              return InkWell(
                onTap: () => setSt(() => selected = i),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        selected == i
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected == i
                            ? AppTheme.primaryBlue
                            : Colors.grey.shade400,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang.$1,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textDark)),
                            Text(lang.$2.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 11, color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            _primaryButton('Apply', () {
              Navigator.pop(ctx);
              _showSnack(context,
                  'Language set to ${languages[selected].$1}');
            }),
          ],
        );
      }),
    );
  }

  void _showHelpCenter(BuildContext context) {
    const faqs = [
      ('How do I hire an expert?',
          'Browse the Explore tab, tap an expert\'s card, review their profile and services, then tap "Hire Now" to send a request.'),
      ('What payment methods are accepted?',
          'We accept Visa, Mastercard, and direct bank transfer via GTBank, Access Bank, and Zenith Bank.'),
      ('Can I cancel a booking?',
          'Yes. Go to My Projects, select the booking, and tap "Cancel". Cancellations within 24 hours are eligible for a full refund.'),
      ('How are experts verified?',
          'Every expert submits a government-issued ID and professional credentials. Our team reviews and approves each profile manually.'),
      ('How do I leave a review?',
          'After a project is marked complete, you\'ll receive a prompt to rate and review the expert. You can also go to My Reviews to submit one.'),
    ];

    _showSheet(
      context,
      title: 'Help Center',
      child: Column(
        children: faqs
            .map((faq) => _FaqTile(question: faq.$1, answer: faq.$2))
            .toList(),
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();

    _showSheet(
      context,
      title: 'Contact Support',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 16, color: AppTheme.primaryBlue),
                SizedBox(width: 8),
                Text('Typical response time: under 2 hours',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sheetField('Subject', subjectCtrl, Icons.subject_rounded),
          const SizedBox(height: 12),
          _sheetField('Message', messageCtrl, Icons.message_outlined,
              maxLines: 4,
              hint: 'Describe your issue in detail…'),
          const SizedBox(height: 20),
          _primaryButton('Send Message', () {
            Navigator.pop(context);
            _showSnack(context, 'Support message sent! We\'ll be in touch soon.');
          }),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    _showSheet(
      context,
      title: 'About HireWise',
      child: Column(
        children: [
          // ET monogram badge
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
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('HireWise',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark)),
          const SizedBox(height: 4),
          const Text('Version 1.0.0 (Build 100)',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 16),
          const Text(
            'HireWise connects clients with verified professional experts across tech, design, law, finance, and more. Hire with confidence, pay securely, and get results.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: AppTheme.textMuted, height: 1.5),
          ),
          const SizedBox(height: 20),
          _aboutRow(Icons.email_outlined, 'support@hirewise.app'),
          const SizedBox(height: 8),
          _aboutRow(Icons.language_outlined, 'hirewise-ten.vercel.app'),
          const SizedBox(height: 8),
          _aboutRow(Icons.location_on_outlined, 'Kigali, Rwanda'),
          const SizedBox(height: 24),

          // Team card
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _teamMember('👩‍💻', 'Esther'),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    _teamMember('🧑‍💻', 'Tresor'),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Built for Kigali  ·  2025',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 15, color: AppTheme.textMuted),
        const SizedBox(width: 6),
        Text(text,
            style:
                const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout_rounded,
                    size: 28, color: Colors.red.shade400),
              ),
              const SizedBox(height: 16),
              const Text('Sign Out?',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark)),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to sign out\nof your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                    height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textMuted,
                        side: BorderSide(color: Colors.grey.shade200),
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await ref.read(authServiceProvider).signOut();
                        if (context.mounted) {
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil('/', (_) => false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Sign Out',
                          style:
                              TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSheet(BuildContext context,
      {required String title, required Widget child}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF4F6FB),
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: AppTheme.textDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
      String label, TextEditingController ctrl, IconData icon,
      {int maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
      String? hint}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppTheme.textMuted),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryBlue),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }

  Widget _toggleTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.textDark)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryBlue,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

Widget _teamMember(String emoji, String name) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(emoji, style: const TextStyle(fontSize: 28)),
      const SizedBox(height: 6),
      Text(
        name,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.textDark,
        ),
      ),
    ],
  );
}

class _Project {
  final String title;
  final String expert;
  final String status;
  final Color statusColor;
  final String amount;
  final String dates;

  const _Project(this.title, this.expert, this.status, this.statusColor,
      this.amount, this.dates);
}

class _Booking {
  final String title;
  final String expert;
  final String amount;
  final String date;
  final String status;
  final Color statusColor;

  const _Booking(this.title, this.expert, this.amount, this.date, this.status,
      this.statusColor);
}


class _MenuEntry {
  final IconData icon;
  final Color color;
  final String label;
  final String? badge;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuEntry({
    required this.icon,
    required this.color,
    required this.label,
    this.badge,
    this.trailing,
    required this.onTap,
  });
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding:
              const EdgeInsets.fromLTRB(14, 0, 14, 12),
          title: Text(widget.question,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark)),
          iconColor: AppTheme.primaryBlue,
          collapsedIconColor: AppTheme.textMuted,
          onExpansionChanged: (_) {},
          children: [
            Text(widget.answer,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                    height: 1.5)),
          ],
        ),
      ),
    );
  }
}
