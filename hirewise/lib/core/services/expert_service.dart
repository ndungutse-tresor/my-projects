import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/expert.dart' as model;

// Re-export so callers don't need to import the model separately.
export '../../models/expert.dart'
    show Expert, ExpertService, ClientReview, kExperts, kSectors, kFeaturedSkills;

class ExpertService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _experts => _db.collection('experts');

  Future<List<model.Expert>> getExperts({String? sector}) async {
    Query query = _experts;
    if (sector != null && sector != 'All') {
      query = query.where('sector', isEqualTo: sector);
    }
    final result = await query.get();
    return result.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      data['id'] = d.id;
      return model.Expert.fromMap(data);
    }).toList();
  }

  Stream<List<model.Expert>> expertsStream({String? sector}) {
    Query query = _experts;
    if (sector != null && sector != 'All') {
      query = query.where('sector', isEqualTo: sector);
    }
    return query.snapshots().map((snap) => snap.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          data['id'] = d.id;
          return model.Expert.fromMap(data);
        }).toList());
  }

  Future<model.Expert?> getExpert(String id) async {
    final doc = await _experts.doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return model.Expert.fromMap(data);
  }

  Stream<model.Expert?> expertStream(String id) {
    if (id.isEmpty) return Stream.value(null);
    return _experts.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return model.Expert.fromMap(data);
    });
  }

  Future<void> upsertExpert(model.Expert expert) async {
    final map = expert.toMap();
    map.remove('id');
    await _experts.doc(expert.id).set(map, SetOptions(merge: true));
  }

  Future<void> addService(String expertId, model.ExpertService service) async {
    final doc = await _experts.doc(expertId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final services = List<Map<String, dynamic>>.from(
        (data['services'] as List? ?? [])
            .map((s) => s as Map<String, dynamic>));
    services.add(service.toMap());
    await _experts.doc(expertId).update({'services': services});
  }

  Future<void> removeService(String expertId, String serviceName) async {
    final doc = await _experts.doc(expertId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final services = List<Map<String, dynamic>>.from(
        (data['services'] as List? ?? [])
            .map((s) => s as Map<String, dynamic>));
    services.removeWhere((s) => s['name'] == serviceName);
    await _experts.doc(expertId).update({'services': services});
  }

  // Seeds the hardcoded kExperts list into Firestore on first launch.
  Future<void> seedExperts() async {
    final existing = await _experts.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final expert in model.kExperts) {
      final ref = _experts.doc(expert.id);
      final map = expert.toMap();
      map.remove('id');
      batch.set(ref, map, SetOptions(merge: true));
    }
    await batch.commit();
  }
}
