import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<User> _all = [];
  List<User> _signed = [];
  List<User> _unsigned = [];
  String _activeTab = 'all';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final all = await StorageService.getAllStudents();
    setState(() {
      _all = all;
      _signed = all.where((u) => u.hasSigned).toList();
      _unsigned = all.where((u) => !u.hasSigned).toList();
      _loading = false;
    });
  }

  List<User> get _displayList {
    switch (_activeTab) {
      case 'signed':
        return _signed;
      case 'unsigned':
        return _unsigned;
      default:
        return _all;
    }
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
      body: Column(
        children: [
          // Green header
          Container(
            color: const Color(0xFF4CAF50),
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin Dashboard',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text('University Stipend Management',
                        style: TextStyle(color: Color(0xFFE8F5E9), fontSize: 13)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _handleLogout,
                ),
              ],
            ),
          ),
          // Stats row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _statCard('Total', _all.length, Colors.blueGrey, 'all'),
                _statCard('Signed', _signed.length, const Color(0xFF4CAF50), 'signed'),
                _statCard('Not Signed', _unsigned.length, Colors.red, 'unsigned'),
              ],
            ),
          ),
          // Tab bar
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                _tab('All (${_all.length})', 'all'),
                const SizedBox(width: 6),
                _tab('Signed (${_signed.length})', 'signed'),
                const SizedBox(width: 6),
                _tab('Not Signed (${_unsigned.length})', 'unsigned'),
              ],
            ),
          ),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: _displayList.isEmpty
                        ? const Center(child: Text('No students found', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: _displayList.length,
                            itemBuilder: (_, i) => _studentCard(_displayList[i]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, int count, Color color, String tab) {
    final active = _activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = tab),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE8F5E9) : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: active ? Border.all(color: const Color(0xFF4CAF50), width: 2) : null,
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
              ),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, String key) {
    final active = _activeTab == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF4CAF50) : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _studentCard(User u) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF4CAF50),
              child: Text(
                u.initials,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u.fullName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('ID: ${u.studentId}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  if (u.department.isNotEmpty || u.yearOfStudy.isNotEmpty)
                    Text(
                      '${u.department} ${u.yearOfStudy.isNotEmpty ? "– Year ${u.yearOfStudy}" : ""}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _badge(
                        u.hasSigned ? 'Signed' : 'Not Signed',
                        u.hasSigned ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                        u.hasSigned ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      ),
                      if (u.isBiometricEnrolled) ...[
                        const SizedBox(width: 6),
                        _badge('Biometric', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
                      ],
                    ],
                  ),
                  if (u.signedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Signed: ${DateFormat('MMM d, y – HH:mm').format(u.signedAt!)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
        child: Text(label, style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.bold)),
      );
}
