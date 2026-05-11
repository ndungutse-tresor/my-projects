import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class BiometricEnrollmentScreen extends StatefulWidget {
  final User user;
  const BiometricEnrollmentScreen({super.key, required this.user});

  @override
  State<BiometricEnrollmentScreen> createState() =>
      _BiometricEnrollmentScreenState();
}

class _BiometricEnrollmentScreenState extends State<BiometricEnrollmentScreen> {
  final _auth = LocalAuthentication();
  bool _deviceHasBiometric = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final hasHardware = await _auth.canCheckBiometrics;
      final isEnrolled = await _auth.isDeviceSupported();
      setState(() => _deviceHasBiometric = hasHardware && isEnrolled);
    } catch (_) {
      setState(() => _deviceHasBiometric = false);
    }
  }

  Future<void> _enrollBiometric() async {
    setState(() => _loading = true);

    try {
      final bool canCheck;
      try {
        canCheck = await _auth.canCheckBiometrics;
      } catch (_) {
        _showInfo('Biometric authentication is not supported on this platform.');
        return;
      }
      if (!canCheck) {
        _showInfo('This device does not support biometric authentication.');
        return;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: 'Verify to enroll biometric for stipend signing',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        final result = await StorageService.updateUser(widget.user.id, {
          'isBiometricEnrolled': true,
        });

        if (result['success'] == true && mounted) {
          _showSuccess('Biometric enrolled! You can now sign for your stipend.', () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => HomeScreen(user: result['user'] as User),
              ),
            );
          });
        }
      } else {
        _showInfo('Enrollment failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _skipEnrollment() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Skip Biometric?'),
        content: const Text(
            'You can still sign for stipend, but without biometric verification. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)),
              );
            },
            child: const Text('Skip', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccess(String msg, VoidCallback onOk) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Success!'),
        content: Text(msg),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onOk();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Biometric')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, size: 100, color: Color(0xFF4CAF50)),
            const SizedBox(height: 24),
            const Text(
              'Biometric Enrollment',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Register your fingerprint or face to verify your identity when signing for stipend',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Why add biometric?',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                          fontSize: 15)),
                  SizedBox(height: 8),
                  Text('• Ensures it\'s really you signing'),
                  Text('• Faster than typing password'),
                  Text('• More secure than password alone'),
                  Text('• Prevents others from signing for you'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _deviceHasBiometric
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                        SizedBox(width: 10),
                        Text('Biometric available on this device',
                            style: TextStyle(color: Color(0xFF2E7D32))),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Color(0xFFE65100)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No biometrics enrolled on this device. Please set up fingerprint or face ID in device settings.',
                            style: TextStyle(color: Color(0xFFE65100)),
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: (_loading || !_deviceHasBiometric) ? null : _enrollBiometric,
                icon: const Icon(Icons.fingerprint),
                label: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Enroll My Biometric',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _skipEnrollment,
              child: const Text('Skip for now', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
