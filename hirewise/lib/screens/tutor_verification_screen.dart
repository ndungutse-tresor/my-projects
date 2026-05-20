import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../models/verification.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/verification_providers.dart';

class TutorVerificationScreen extends ConsumerStatefulWidget {
  const TutorVerificationScreen({super.key});

  @override
  ConsumerState<TutorVerificationScreen> createState() =>
      _TutorVerificationScreenState();
}

class _TutorVerificationScreenState
    extends ConsumerState<TutorVerificationScreen> {
  int _step = 0;
  bool _isSubmitting = false;

  // Step 1 — Profile
  final _bioCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _step1Key = GlobalKey<FormState>();

  // Step 2 — Documents
  File? _idFront;
  File? _idBack;
  File? _profilePhoto;
  final List<File> _qualifications = [];
  File? _professionalLicense;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _bioCtrl.dispose();
    _specialtyCtrl.dispose();
    _expCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  // ── Step navigation ────────────────────────────────────────────────────────

  void _next() {
    if (_step == 0 && !(_step1Key.currentState?.validate() ?? false)) return;
    if (_step == 1 && !_docsComplete()) {
      _showSnack('Please upload all required documents before continuing.');
      return;
    }
    setState(() => _step++);
  }

  void _back() => setState(() => _step--);

  bool _docsComplete() =>
      _idFront != null &&
      _idBack != null &&
      _profilePhoto != null &&
      _qualifications.isNotEmpty;

  // ── File picking ──────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source,
      void Function(File) onPicked) async {
    final picked = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1600);
    if (picked != null) onPicked(File(picked.path));
  }

  Future<void> _pickDoc() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _qualifications.add(File(result.files.single.path!)));
    }
  }

  void _showImageSourceSheet(void Function(File) onPicked) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          _sourceOption(Icons.camera_alt_rounded, 'Take Photo', () {
            Navigator.pop(context);
            _pickImage(ImageSource.camera, (f) => setState(() => onPicked(f)));
          }),
          const SizedBox(height: 10),
          _sourceOption(Icons.photo_library_outlined, 'Choose from Gallery', () {
            Navigator.pop(context);
            _pickImage(ImageSource.gallery, (f) => setState(() => onPicked(f)));
          }),
        ]),
      ),
    );
  }

  Widget _sourceOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFFF4F6FB),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        ]),
      ),
    );
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    setState(() => _isSubmitting = true);
    try {
      final storage = ref.read(storageServiceProvider);
      final vs = ref.read(verificationServiceProvider);

      // Upload profile photo
      final photoResult = await storage.uploadVerificationDoc(
        userId: user.uid,
        docTypeName: DocumentType.profilePhoto.storageName,
        file: _profilePhoto!,
      );
      await vs.saveDocument(
          user.uid,
          VerificationDocument(
            id: DocumentType.profilePhoto.storageName,
            type: DocumentType.profilePhoto,
            storagePath: photoResult.storagePath,
            downloadUrl: photoResult.downloadUrl,
            fileName: 'profile_photo',
            uploadedAt: DateTime.now(),
          ));

      // Upload ID front
      final idFrontResult = await storage.uploadVerificationDoc(
        userId: user.uid,
        docTypeName: DocumentType.nationalIdFront.storageName,
        file: _idFront!,
      );
      await vs.saveDocument(
          user.uid,
          VerificationDocument(
            id: DocumentType.nationalIdFront.storageName,
            type: DocumentType.nationalIdFront,
            storagePath: idFrontResult.storagePath,
            downloadUrl: idFrontResult.downloadUrl,
            fileName: 'national_id_front',
            uploadedAt: DateTime.now(),
          ));

      // Upload ID back
      final idBackResult = await storage.uploadVerificationDoc(
        userId: user.uid,
        docTypeName: DocumentType.nationalIdBack.storageName,
        file: _idBack!,
      );
      await vs.saveDocument(
          user.uid,
          VerificationDocument(
            id: DocumentType.nationalIdBack.storageName,
            type: DocumentType.nationalIdBack,
            storagePath: idBackResult.storagePath,
            downloadUrl: idBackResult.downloadUrl,
            fileName: 'national_id_back',
            uploadedAt: DateTime.now(),
          ));

      // Upload qualifications
      for (int i = 0; i < _qualifications.length; i++) {
        final docId = 'qual_$i';
        final qualResult = await storage.uploadVerificationDoc(
          userId: user.uid,
          docTypeName: DocumentType.qualification.storageName,
          file: _qualifications[i],
          docId: docId,
        );
        await vs.saveDocument(
            user.uid,
            VerificationDocument(
              id: docId,
              type: DocumentType.qualification,
              storagePath: qualResult.storagePath,
              downloadUrl: qualResult.downloadUrl,
              fileName: 'qualification_${i + 1}',
              uploadedAt: DateTime.now(),
            ));
      }

      // Optional professional license
      if (_professionalLicense != null) {
        final licResult = await storage.uploadVerificationDoc(
          userId: user.uid,
          docTypeName: DocumentType.professionalLicense.storageName,
          file: _professionalLicense!,
        );
        await vs.saveDocument(
            user.uid,
            VerificationDocument(
              id: DocumentType.professionalLicense.storageName,
              type: DocumentType.professionalLicense,
              storagePath: licResult.storagePath,
              downloadUrl: licResult.downloadUrl,
              fileName: 'professional_license',
              uploadedAt: DateTime.now(),
            ));
      }

      // Update profile bio/specialty in users collection
      await ref.read(userServiceProvider).updateUser(user.uid, {
        'bio': _bioCtrl.text.trim(),
        'specialty': _specialtyCtrl.text.trim(),
        'experience': _expCtrl.text.trim(),
      });

      // Submit application
      await vs.submitApplication(
        userId: user.uid,
        tutorName: user.name,
        tutorEmail: user.email,
        specialty: _specialtyCtrl.text.trim(),
      );

      if (mounted) {
        setState(() => _step = 3); // success step
      }
    } catch (e) {
      if (mounted) _showSnack('Upload failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _step > 0 && _step < 3
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    size: 18, color: AppTheme.textDark),
                onPressed: _back,
              )
            : null,
        title: const Text('Get Verified',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_step < 3) _buildStepIndicator(),
          Expanded(
            child: _step == 0
                ? _buildStep1()
                : _step == 1
                    ? _buildStep2()
                    : _step == 2
                        ? _buildStep3()
                        : _buildSuccess(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    const steps = ['Profile', 'Documents', 'Review'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: List.generate(steps.length, (i) {
          final done = i < _step;
          final active = i == _step;
          final color = active
              ? AppTheme.primaryBlue
              : done
                  ? const Color(0xFF059669)
                  : Colors.grey.shade300;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                      child: Container(
                          height: 2,
                          color: done
                              ? const Color(0xFF059669)
                              : Colors.grey.shade200)),
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: color),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check_rounded,
                                size: 16, color: Colors.white)
                            : Text('${i + 1}',
                                style: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : Colors.grey.shade500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(steps[i],
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: active
                                ? AppTheme.primaryBlue
                                : AppTheme.textMuted)),
                  ],
                ),
                if (i < steps.length - 1)
                  Expanded(
                      child: Container(
                          height: 2,
                          color: done
                              ? const Color(0xFF059669)
                              : Colors.grey.shade200)),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Step 1: Profile ───────────────────────────────────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _step1Key,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionHeader('Complete Your Profile',
              'Tell students and admins who you are.'),
          const SizedBox(height: 20),
          _formField('Specialty / Subject Area', _specialtyCtrl,
              'e.g. Flutter Development, Mathematics',
              Icons.work_outline_rounded,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null),
          const SizedBox(height: 14),
          _formField('Bio', _bioCtrl, 'Tell students about yourself…',
              Icons.notes_rounded,
              maxLines: 4,
              validator: (v) =>
                  v == null || v.length < 30
                      ? 'Minimum 30 characters'
                      : null),
          const SizedBox(height: 14),
          _formField('Experience', _expCtrl,
              'e.g. 5 years teaching at University of Rwanda',
              Icons.timeline_rounded,
              maxLines: 2,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null),
          const SizedBox(height: 14),
          _formField('Hourly Rate (RWF)', _rateCtrl, 'e.g. 35000',
              Icons.attach_money_rounded,
              keyboardType: TextInputType.number),
          const SizedBox(height: 28),
          _primaryBtn('Continue', _next),
        ]),
      ),
    );
  }

  // ── Step 2: Documents ─────────────────────────────────────────────────────

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('Upload Documents',
            'All documents are encrypted and only visible to HireWise admins.'),
        const SizedBox(height: 20),
        _docTile(
          label: 'Profile Photo *',
          subtitle: 'Clear face photo — no sunglasses or hats',
          icon: Icons.person_rounded,
          file: _profilePhoto,
          onTap: () =>
              _showImageSourceSheet((f) => setState(() => _profilePhoto = f)),
        ),
        const SizedBox(height: 12),
        _docTile(
          label: 'National ID — Front *',
          subtitle: 'Full card visible, well-lit',
          icon: Icons.badge_outlined,
          file: _idFront,
          onTap: () =>
              _showImageSourceSheet((f) => setState(() => _idFront = f)),
        ),
        const SizedBox(height: 12),
        _docTile(
          label: 'National ID — Back *',
          subtitle: 'Full card visible, well-lit',
          icon: Icons.badge_outlined,
          file: _idBack,
          onTap: () =>
              _showImageSourceSheet((f) => setState(() => _idBack = f)),
        ),
        const SizedBox(height: 12),
        _qualificationsSection(),
        const SizedBox(height: 12),
        _docTile(
          label: 'Professional License (optional)',
          subtitle: 'Required for Legal, Finance, Medical sectors',
          icon: Icons.verified_outlined,
          file: _professionalLicense,
          onTap: () async {
            final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']);
            if (result?.files.single.path != null) {
              setState(
                  () => _professionalLicense = File(result!.files.single.path!));
            }
          },
        ),
        const SizedBox(height: 28),
        _primaryBtn('Continue to Review', _next),
      ]),
    );
  }

  Widget _qualificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Qualifications / Certificates *',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.textDark)),
            GestureDetector(
              onTap: _pickDoc,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_rounded,
                        size: 16, color: AppTheme.primaryBlue),
                    SizedBox(width: 4),
                    Text('Add',
                        style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_qualifications.isEmpty)
          _docTile(
            label: 'Add Certificate or Diploma',
            subtitle: 'PDF, JPG or PNG — tap to add',
            icon: Icons.school_outlined,
            file: null,
            onTap: _pickDoc,
          )
        else
          ..._qualifications.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _docTile(
                  label: 'Qualification ${e.key + 1}',
                  subtitle: e.value.path.split('/').last,
                  icon: Icons.description_outlined,
                  file: e.value,
                  onTap: _pickDoc,
                  trailing: IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: 18, color: Colors.red.shade400),
                    onPressed: () =>
                        setState(() => _qualifications.removeAt(e.key)),
                  ),
                ),
              )),
      ],
    );
  }

  Widget _docTile({
    required String label,
    required String subtitle,
    required IconData icon,
    required File? file,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final uploaded = file != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: uploaded
                ? const Color(0xFF059669).withValues(alpha: 0.4)
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: uploaded
                  ? const Color(0xFF059669).withValues(alpha: 0.1)
                  : AppTheme.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              uploaded ? Icons.check_circle_outline_rounded : icon,
              color: uploaded
                  ? const Color(0xFF059669)
                  : AppTheme.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textDark)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          trailing ??
              Icon(
                uploaded
                    ? Icons.edit_outlined
                    : Icons.upload_rounded,
                size: 18,
                color: AppTheme.textMuted,
              ),
        ]),
      ),
    );
  }

  // ── Step 3: Review & Submit ───────────────────────────────────────────────

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('Review & Submit',
            'Once submitted, our team will review within 1–3 business days.'),
        const SizedBox(height: 20),
        _reviewCard('Profile Details', [
          ('Specialty', _specialtyCtrl.text),
          ('Experience', _expCtrl.text),
          ('Bio preview',
              _bioCtrl.text.length > 60
                  ? '${_bioCtrl.text.substring(0, 60)}…'
                  : _bioCtrl.text),
        ]),
        const SizedBox(height: 12),
        _reviewCard('Documents', [
          ('Profile Photo', _profilePhoto != null ? '✓ Uploaded' : '✗ Missing'),
          ('National ID Front',
              _idFront != null ? '✓ Uploaded' : '✗ Missing'),
          ('National ID Back',
              _idBack != null ? '✓ Uploaded' : '✗ Missing'),
          ('Qualifications',
              '${_qualifications.length} file(s) uploaded'),
          if (_professionalLicense != null)
            ('Professional License', '✓ Uploaded'),
        ]),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF059669).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFF059669).withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_outline_rounded,
                  color: Color(0xFF059669), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your documents are encrypted and stored securely. Only HireWise admins can access them.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF059669),
                      height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _isSubmitting
            ? const Center(child: CircularProgressIndicator())
            : _primaryBtn('Submit for Verification', _submit),
      ]),
    );
  }

  Widget _reviewCard(String title, List<(String, String)> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppTheme.textDark)),
          const SizedBox(height: 12),
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(row.$1,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted)),
                    ),
                    Expanded(
                      child: Text(row.$2,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textDark)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Step 4: Success ───────────────────────────────────────────────────────

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  size: 48, color: Color(0xFF059669)),
            ),
            const SizedBox(height: 24),
            const Text('Application Submitted!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark)),
            const SizedBox(height: 12),
            const Text(
              'Our team will review your application within 1–3 business days.\n\nYou\'ll be notified once a decision is made.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                  height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Back to Dashboard',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark)),
        const SizedBox(height: 6),
        Text(subtitle,
            style:
                const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _formField(
    String label,
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.textMuted),
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
          borderSide:
              const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _primaryBtn(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}
