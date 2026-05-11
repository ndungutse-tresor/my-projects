import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TutorResourcesScreen extends StatefulWidget {
  const TutorResourcesScreen({super.key});

  @override
  State<TutorResourcesScreen> createState() => _TutorResourcesScreenState();
}

class _TutorResourcesScreenState extends State<TutorResourcesScreen> {
  static const _color = Color(0xFF059669);

  final List<_TutorResource> _resources = [
    _TutorResource(
      name: 'Flutter Widgets Cheatsheet.pdf',
      student: 'Jean Claude Nkurunziza',
      subject: 'Flutter Development',
      date: 'Apr 15, 2025',
      size: '1.2 MB',
      ext: 'pdf',
      iconColor: const Color(0xFFEF4444),
    ),
    _TutorResource(
      name: 'UI Design Principles.pptx',
      student: 'Marie Ange Habimana',
      subject: 'UI/UX Design',
      date: 'Apr 12, 2025',
      size: '3.4 MB',
      ext: 'pptx',
      iconColor: const Color(0xFFD97706),
    ),
    _TutorResource(
      name: 'Python Basics Notes.pdf',
      student: 'Eric Mugisha',
      subject: 'Python Basics',
      date: 'Apr 8, 2025',
      size: '890 KB',
      ext: 'pdf',
      iconColor: const Color(0xFFEF4444),
    ),
  ];

  final List<String> _students = [
    'Jean Claude Nkurunziza',
    'Marie Ange Habimana',
    'Eric Mugisha',
    'Alice Uwimana',
    'Patrick Habimana',
  ];

  final List<String> _fileTypes = [
    'PDF Document',
    'PowerPoint Presentation',
    'Word Document',
    'Excel Spreadsheet',
    'Video Lecture',
    'Audio Recording',
    'ZIP Archive',
    'Image',
  ];

  void _showFilePicker(BuildContext ctx, TextEditingController nameCtrl,
      StateSetter setInner) {
    final sampleFiles = [
      ('Flutter Widgets Reference.pdf', 'pdf', '1.2 MB'),
      ('UI Design Cheatsheet.pptx', 'pptx', '3.4 MB'),
      ('Python Exercises Week 3.docx', 'docx', '890 KB'),
      ('Database Schema Template.xlsx', 'xlsx', '450 KB'),
      ('Lecture Recording.mp4', 'mp4', '45.6 MB'),
      ('Assignment Brief.pdf', 'pdf', '210 KB'),
    ];

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.folder_outlined, color: Color(0xFF059669), size: 22),
            SizedBox(width: 8),
            Text('Select File',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14, color: Color(0xFF059669)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                          'Select a file to upload from your device',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF059669))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...sampleFiles.map((f) => ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _extColor(f.$2).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(f.$2.toUpperCase(),
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: _extColor(f.$2))),
                      ),
                    ),
                    title: Text(f.$1,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text(f.$3,
                        style: const TextStyle(fontSize: 11)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setInner(() => nameCtrl.text = f.$1);
                    },
                  )),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_rounded,
                      size: 20, color: AppTheme.textMuted),
                ),
                title: const Text('Enter custom filename',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted)),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    String selectedStudent = _students[0];
    String selectedType = _fileTypes[0];
    final nameCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(builder: (ctx, setInner) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF4F6FB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Upload Resource',
                        style: TextStyle(
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
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => _showFilePicker(ctx, nameCtrl, setInner),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: nameCtrl.text.isNotEmpty
                              ? _color.withValues(alpha: 0.4)
                              : Colors.grey.shade300,
                          style: BorderStyle.solid,
                          width: nameCtrl.text.isNotEmpty ? 1.5 : 1),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          nameCtrl.text.isNotEmpty
                              ? Icons.check_circle_rounded
                              : Icons.cloud_upload_outlined,
                          color: nameCtrl.text.isNotEmpty
                              ? _color
                              : Colors.grey.shade400,
                          size: 36,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nameCtrl.text.isNotEmpty
                              ? nameCtrl.text
                              : 'Tap to select a file',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: nameCtrl.text.isNotEmpty
                                  ? _color
                                  : AppTheme.textMuted),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          nameCtrl.text.isNotEmpty
                              ? 'Tap to change file'
                              : 'PDF, PPTX, DOCX, XLSX, MP4 supported',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                _field('Resource Name', nameCtrl, Icons.description_outlined,
                    hint: 'e.g. Week 3 - Flutter Widgets.pdf'),
                const SizedBox(height: 12),
                _field('Subject / Topic', subjectCtrl, Icons.subject_rounded,
                    hint: 'e.g. Flutter Development'),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStudent,
                      isExpanded: true,
                      icon: const Icon(Icons.expand_more_rounded,
                          color: AppTheme.textMuted),
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.textDark),
                      onChanged: (v) =>
                          setInner(() => selectedStudent = v!),
                      items: _students
                          .map((s) => DropdownMenuItem(
                              value: s,
                              child: Row(
                                children: [
                                  const Icon(
                                      Icons.person_outline_rounded,
                                      size: 16,
                                      color: AppTheme.textMuted),
                                  const SizedBox(width: 8),
                                  Text(s),
                                ],
                              )))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true,
                      icon: const Icon(Icons.expand_more_rounded,
                          color: AppTheme.textMuted),
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.textDark),
                      onChanged: (v) =>
                          setInner(() => selectedType = v!),
                      items: _fileTypes
                          .map((t) => DropdownMenuItem(
                              value: t, child: Text(t)))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please select or name a file first'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      final ext = name.contains('.')
                          ? name.split('.').last.toLowerCase()
                          : 'file';
                      setState(() {
                        _resources.insert(
                          0,
                          _TutorResource(
                            name: name,
                            student: selectedStudent,
                            subject: subjectCtrl.text.isEmpty
                                ? 'General'
                                : subjectCtrl.text,
                            date: 'Just now',
                            size: 'Uploaded',
                            ext: ext,
                            iconColor: _extColor(ext),
                          ),
                        );
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '$name shared with $selectedStudent'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: _color,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    icon: const Icon(Icons.cloud_upload_rounded, size: 20),
                    label: const Text('Upload & Share',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Color _extColor(String ext) {
    return switch (ext) {
      'pdf' => const Color(0xFFEF4444),
      'pptx' || 'ppt' => const Color(0xFFD97706),
      'xlsx' || 'xls' => const Color(0xFF059669),
      'docx' || 'doc' => AppTheme.primaryBlue,
      'mp4' || 'mov' => const Color(0xFF7C3AED),
      _ => AppTheme.textMuted,
    };
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {String? hint}) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
      decoration: InputDecoration(
        hintText: hint ?? label,
        labelText: label,
        prefixIcon:
            Icon(icon, size: 18, color: AppTheme.textMuted),
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
          borderSide: const BorderSide(color: _color),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<_TutorResource>>{};
    for (final r in _resources) {
      grouped.putIfAbsent(r.student, () => []).add(r);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadDialog,
        backgroundColor: _color,
        icon: const Icon(Icons.upload_rounded, color: Colors.white),
        label: const Text('Upload Resource',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Resources',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark)),
                          Text('Files shared with your students',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${_resources.length} files',
                          style: const TextStyle(
                              color: _color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
            if (_resources.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_open_outlined,
                          size: 56, color: AppTheme.textMuted),
                      SizedBox(height: 12),
                      Text('No resources uploaded yet',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted)),
                      Text('Tap Upload to share files with students',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final student = grouped.keys.elementAt(i);
                    final files = grouped[student]!;
                    return Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: _color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(student[0],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: _color)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(student,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppTheme.textDark)),
                              ),
                              Text('${files.length} file(s)',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...files.map((r) => _resourceTile(context, r)),
                        ],
                      ),
                    );
                  },
                  childCount: grouped.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _resourceTile(BuildContext context, _TutorResource r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: r.iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(r.ext.toUpperCase(),
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: r.iconColor)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.textDark),
                    overflow: TextOverflow.ellipsis),
                Text('${r.subject}  •  ${r.size}',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted)),
                Text(r.date,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${r.name} sent again to ${r.student}'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.send_rounded,
                      size: 15, color: _color),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  setState(() => _resources.remove(r));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${r.name} deleted'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 15, color: Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TutorResource {
  final String name;
  final String student;
  final String subject;
  final String date;
  final String size;
  final String ext;
  final Color iconColor;

  const _TutorResource({
    required this.name,
    required this.student,
    required this.subject,
    required this.date,
    required this.size,
    required this.ext,
    required this.iconColor,
  });
}
