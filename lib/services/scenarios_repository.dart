import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roi_calculator/logic/calculator_logic.dart';
import 'package:roi_calculator/models/scenario.dart';

/// Handles Firestore CRUD for saved scenarios under the current user.
class ScenariosRepository {
  ScenariosRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _scenariosRef() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not signed in');
    return _firestore.collection('users').doc(uid).collection('scenarios');
  }

  /// Stream of scenarios for the current user, newest first.
  Stream<List<Scenario>> watchScenarios() {
    return _scenariosRef()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Scenario.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Save a new scenario. Returns the new document id.
  Future<String> addScenario({
    required String name,
    required double billAmount,
    required bool isMonthly,
    required double windowPercent,
    required double projectCost,
    required Climate climate,
    required int yearsSlider,
  }) async {
    final ref = _scenariosRef().doc();
    final scenario = Scenario(
      id: ref.id,
      name: name,
      billAmount: billAmount,
      isMonthly: isMonthly,
      windowPercent: windowPercent,
      projectCost: projectCost,
      climate: climate,
      yearsSlider: yearsSlider,
      createdAt: DateTime.now(),
    );
    await ref.set(scenario.toMap());
    return ref.id;
  }

  /// Delete a scenario by id.
  Future<void> deleteScenario(String id) async {
    await _scenariosRef().doc(id).delete();
  }
}
