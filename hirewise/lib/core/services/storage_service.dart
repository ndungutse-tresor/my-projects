import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final _storage = FirebaseStorage.instance;

  // Upload a verification document and return its download URL.
  // docId is used for qualifications (multiple allowed); omit for single-file types.
  Future<({String downloadUrl, String storagePath})> uploadVerificationDoc({
    required String userId,
    required String docTypeName,  // e.g. 'national_id_front'
    required File file,
    String? docId,
  }) async {
    final ext = p.extension(file.path).toLowerCase();
    final fileName = docId != null
        ? 'verification/$userId/$docTypeName/$docId$ext'
        : 'verification/$userId/$docTypeName$ext';

    final ref = _storage.ref(fileName);
    final task = await ref.putFile(
      file,
      SettableMetadata(
        contentType: ext == '.pdf' ? 'application/pdf' : 'image/jpeg',
        customMetadata: {'userId': userId, 'docType': docTypeName},
      ),
    );
    final url = await task.ref.getDownloadURL();
    return (downloadUrl: url, storagePath: fileName);
  }

  // Delete all verification documents for a user (called on rejection cleanup).
  Future<void> deleteVerificationFolder(String userId) async {
    final ref = _storage.ref('verification/$userId');
    try {
      await _deleteRef(ref);
    } catch (_) {
      // Folder may not exist — safe to ignore.
    }
  }

  Future<void> _deleteRef(Reference ref) async {
    final list = await ref.listAll();
    for (final item in list.items) {
      await item.delete();
    }
    for (final prefix in list.prefixes) {
      await _deleteRef(prefix);
    }
  }

  // Upload a public-facing avatar (profile photo shown on listings).
  Future<String> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    final ext = p.extension(file.path).toLowerCase();
    final ref = _storage.ref('avatars/$userId$ext');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }
}
