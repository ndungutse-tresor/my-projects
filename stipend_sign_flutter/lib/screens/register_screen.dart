import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import 'profile_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _studentIdCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    for (final c in [
      _emailCtrl, _passwordCtrl, _confirmCtrl, _firstNameCtrl,
      _lastNameCtrl, _studentIdCtrl, _departmentCtrl, _yearCtrl, _phoneCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_emailCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.isEmpty ||
        _firstNameCtrl.text.trim().isEmpty ||
        _lastNameCtrl.text.trim().isEmpty ||
        _studentIdCtrl.text.trim().isEmpty) {
      _showError('Please fill in all required fields');
      return;
    }

    if (_passwordCtrl.text != _confirmCtrl.text) {
      _showError('Passwords do not match');
      return;
    }

    if (_passwordCtrl.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await StorageService.registerUser(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        studentId: _studentIdCtrl.text.trim(),
        department: _departmentCtrl.text.trim(),
        yearOfStudy: _yearCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );

      if (result['success'] == true) {
        final user = result['user'] as User;
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => ProfileScreen(user: user)),
          );
        }
      } else {
        _showError(result['message'] as String);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('Account Details'),
            _field(_emailCtrl, 'Email *', TextInputType.emailAddress),
            _field(_passwordCtrl, 'Password *', TextInputType.text, obscure: _obscure, suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            )),
            _field(_confirmCtrl, 'Confirm Password *', TextInputType.text, obscure: _obscure),
            const SizedBox(height: 8),
            _sectionTitle('Personal Information'),
            _field(_firstNameCtrl, 'First Name *', TextInputType.name),
            _field(_lastNameCtrl, 'Last Name *', TextInputType.name),
            _field(_studentIdCtrl, 'Student ID *', TextInputType.text),
            _field(_departmentCtrl, 'Department', TextInputType.text),
            _field(_yearCtrl, 'Year of Study (1-5)', TextInputType.number),
            _field(_phoneCtrl, 'Phone Number', TextInputType.phone),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Already have an account? Login',
                style: TextStyle(color: Color(0xFF4CAF50), fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 4),
        child: Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
      );

  Widget _field(
    TextEditingController ctrl,
    String label,
    TextInputType type, {
    bool obscure = false,
    Widget? suffixIcon,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: ctrl,
          keyboardType: type,
          obscureText: obscure,
          decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
        ),
      );
}
