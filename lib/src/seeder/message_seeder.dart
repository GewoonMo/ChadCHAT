import 'package:cloud_firestore/cloud_firestore.dart';

class MessageSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedMessages() async {
    await addMessageToDatabase(
        "WJ73vRLB5iUVhCxTLJDBUThQWw83",
        "VawWTp6jcLcTfp1IgstqSJMFG5Y2",
        'Hallo hoe gaat het',
        Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))));
    await addMessageToDatabase(
        "WJ73vRLB5iUVhCxTLJDBUThQWw83",
        "VawWTp6jcLcTfp1IgstqSJMFG5Y2",
        'Goed en met jou',
        Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))));
  }

  Future<void> addMessageToDatabase(String senderId, String receiverId,
      String message, Timestamp timestamp) async {
    await _firestore
        .collection('chat_rooms')
        .doc('VawWTp6jcLcTfp1IgstqSJMFG5Y2_WJ73vRLB5iUVhCxTLJDBUThQWw83')
        .collection('messages')
        .add({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    });
  }
}
