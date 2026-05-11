import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import 'biometric_enrollment_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _studentIdCtrl;
  late final TextEditingController _departmentCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _phoneCtrl;
  String? _cardImagePath;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _firstNameCtrl = TextEditingController(text: u.firstName);
    _lastNameCtrl = TextEditingController(text: u.lastName);
    _studentIdCtrl = TextEditingController(text: u.studentId);
    _departmentCtrl = TextEditingController(text: u.department);
    _yearCtrl = TextEditingController(text: u.yearOfStudy);
    _phoneCtrl = TextEditingController(text: u.phone);
    _cardImagePath = u.studentCardImage;
  }

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl, _lastNameCtrl, _studentIdCtrl,
      _departmentCtrl, _yearCtrl, _phoneCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _cardImagePath = picked.path);
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_firstNameCtrl.text.trim().isEmpty ||
        _lastNameCtrl.text.trim().isEmpty ||
        _studentIdCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await StorageService.updateUser(widget.user.id, {
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'studentId': _studentIdCtrl.text.trim(),
        'department': _departmentCtrl.text.trim(),
        'yearOfStudy': _yearCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'studentCardImage': _cardImagePath,
      });

      if (result['success'] == true && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BiometricEnrollmentScreen(user: result['user'] as User),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Complete your profile and upload your student card',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Personal Information'),
            _field(_firstNameCtrl, 'First Name *'),
            _field(_lastNameCtrl, 'Last Name *'),
            TextField(
              controller: _studentIdCtrl,
              enabled: widget.user.studentId.isEmpty,
              decoration: const InputDecoration(labelText: 'Student ID *'),
            ),
            const SizedBox(height: 12),
            _field(_departmentCtrl, 'Department'),
            _field(_yearCtrl, 'Year of Study (1-5)', type: TextInputType.number),
            _field(_phoneCtrl, 'Phone Number', type: TextInputType.phone),
            const SizedBox(height: 8),
            _sectionTitle('Student Card Photo'),
            const Text(
              'Upload a photo of your student ID card for verification',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _showImageOptions,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _cardImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(_cardImagePath!), fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to upload student card',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
            ),
            if (_cardImagePath != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _cardImagePath = null),
                child: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleSave,
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
                    : const Text('Save & Continue',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 8),
        child: Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
      );

  Widget _field(TextEditingController ctrl, String label,
          {TextInputType type = TextInputType.text}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(controller: ctrl, keyboardType: type, decoration: InputDecoration(labelText: label)),
      );
}
