import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String title;
  final String body;
  final String? payload;
  final int notificationId;
  final Timestamp timestamp;
  final bool read;
  final bool visible;

  AlertModel({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    required this.notificationId,
    required this.timestamp,
    this.read = false,
    this.visible = true,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AlertModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      payload: data['payload'],
      notificationId: data['notificationId'] ?? 0,
      timestamp: data['timestamp'] ?? Timestamp.now(),
      read: data['read'] ?? false,
      visible: data['visible'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'payload': payload,
      'notificationId': notificationId,
      'timestamp': timestamp,
      'read': read,
      'visible': visible,
    };
  }
}
