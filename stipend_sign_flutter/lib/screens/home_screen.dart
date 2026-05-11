import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

const double _campusLat = -1.9406;
const double _campusLon = 30.0894;
const double _geofenceRadius = 100.0;

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User _user;
  bool _loading = false;
  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    final current = await StorageService.getCurrentUser();
    if (current != null && mounted) setState(() => _user = current);
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled. Please enable them.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permission denied.');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showError('Location permission permanently denied. Please enable in settings.');
      return false;
    }
    return true;
  }

  Future<void> _handleSign() async {
    if (_user.hasSigned) {
      _showInfo('You have already signed for this period.');
      return;
    }

    setState(() => _loading = true);

    try {
      if (_user.isBiometricEnrolled) {
        try {
          final authenticated = await _localAuth.authenticate(
            localizedReason: 'Verify your identity to sign for stipend',
            options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
          );
          if (!authenticated) {
            _showError('Biometric verification failed.');
            return;
          }
        } catch (_) {
          // Biometric not available on this platform — skip verification
        }
      }

      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final distance = Geolocator.distanceBetween(
        position.latitude, position.longitude,
        _campusLat, _campusLon,
      );

      if (distance > _geofenceRadius) {
        _showError(
          'You must be on campus to sign for stipend.\n'
          'You are ${distance.toStringAsFixed(0)}m from campus.',
        );
        return;
      }

      final result = await StorageService.markStudentSigned(_user.id);
      if (result['success'] == true && mounted) {
        final updated = result['user'] as User;
        setState(() => _user = updated);
        _showSuccessDialog(updated.signedAt!);
      } else {
        _showError('Failed to record your signing. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccessDialog(DateTime signedAt) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Success!'),
        content: Text(
          'You have successfully signed for the stipend.\n\n'
          'Time: ${DateFormat('MMM d, y – HH:mm').format(signedAt)}\n'
          'Location: On campus',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await StorageService.logoutUser();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Stipend Signing'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome,', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
            Text(
              _user.fullName,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 16),
            // Profile card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFF4CAF50),
                      child: Text(
                        _user.initials,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('Student ID', _user.studentId),
                          _infoRow('Department', _user.department.isNotEmpty ? _user.department : 'Not specified'),
                          _infoRow('Year', _user.yearOfStudy.isNotEmpty ? _user.yearOfStudy : 'Not specified'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Signing status card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Signing Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (_user.hasSigned) ...[
                      const Icon(Icons.check_circle, size: 60, color: Color(0xFF4CAF50)),
                      const SizedBox(height: 8),
                      const Text(
                        'You have signed for this period',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                      ),
                      if (_user.signedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Signed on: ${DateFormat('MMM d, y – HH:mm').format(_user.signedAt!)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ] else ...[
                      const Icon(Icons.hourglass_empty, size: 60, color: Color(0xFFFF9800)),
                      const SizedBox(height: 8),
                      const Text(
                        "You haven't signed yet",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFFF9800)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap the button below to sign for your stipend',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_user.hasSigned)
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _handleSign,
                  icon: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.how_to_reg),
                  label: Text(
                    _loading ? 'Processing...' : 'Sign for Stipend',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            if (_user.isBiometricEnrolled) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fingerprint, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Text('Fingerprint Enabled', style: TextStyle(color: Color(0xFF2E7D32))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF1565C0), size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Campus Location: Nyaruugenge Campus',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'You must be within 100m of campus to sign',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(text: '$label: ', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      );
}
