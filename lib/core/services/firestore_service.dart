import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Central place to obtain the Firestore instance that points to the
/// non-default database we created (ID: `eatsoon001`).  By funnelling all
/// Firestore access through this helper we avoid sprinkling the databaseId
/// throughout the codebase and keep migration easy.
class FirestoreService {
  FirestoreService._();

  static const String _databaseId = 'eatsoon001';

  /// Shared instance configured for the custom database.
  static final FirebaseFirestore instance = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: _databaseId,
  );
} 