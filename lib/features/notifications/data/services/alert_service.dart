import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eat_soon/features/notifications/data/models/alert_model.dart';

class AlertService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<AlertModel> get _alertsCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception("User not authenticated");
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('alerts')
        .withConverter<AlertModel>(
          fromFirestore: (snapshot, _) => AlertModel.fromFirestore(snapshot),
          toFirestore: (alert, _) => alert.toFirestore(),
        );
  }

  Future<void> saveAlert(AlertModel alert) async {
    await _alertsCollection.doc(alert.notificationId.toString()).set(alert);
  }

  Stream<List<AlertModel>> getVisibleAlertsStream() {
    return _alertsCollection
        .where('visible', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<AlertModel>> getAllAlertsStream() {
    return _alertsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<List<AlertModel>> getVisibleAlerts() async {
    final snapshot =
        await _alertsCollection.where('visible', isEqualTo: true).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> markAllAsRead() async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshot =
        await _alertsCollection.where('read', isEqualTo: false).get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  Future<void> hideAlert(int notificationId) async {
    try {
      await _alertsCollection.doc(notificationId.toString()).update({
        'visible': false,
      });
    } catch (e) {
      // It might not exist, which is fine.
    }
  }

  Future<void> hideAllAlerts() async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshot =
        await _alertsCollection.where('visible', isEqualTo: true).get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'visible': false, 'read': true});
    }
    await batch.commit();
  }
}
