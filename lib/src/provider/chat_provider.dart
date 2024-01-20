import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/model/message_model.dart';
import 'package:intl/intl.dart';

class ChatServices extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send Messages
  Future<void> sendMessage(String receiverId, String message) async {
    final String currendUserId = _firebaseAuth.currentUser!.uid;

// if the currentuser id the same is as the one in the firebasestorte then give me his name
    final String currentUserName = await _firestore
        .collection('users')
        .doc(currendUserId)
        .get()
        .then((value) => value.data()!['name'] as String);

    // test currrenyUserName
    if (kDebugMode) {
      print('currentUserName: $currentUserName');
    }
    // final String timestamp = Timestamp.now().toString();
    final Timestamp timestamp = Timestamp.now();

    // Create a new message
    Message newMessage = Message(
      senderId: currendUserId,
      senderName: currentUserName,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // Construct chat room id fro mcurrent user id and receuiver id
    List<String> chatRoomIds = [currendUserId, receiverId];
    chatRoomIds.sort();
    String chatRoomId = chatRoomIds.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userId, String receiverUserId) {
    List<String> chatRoomIds = [userId, receiverUserId];
    chatRoomIds.sort();
    String chatRoomId = chatRoomIds.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  String formatTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    return formattedTime;
  }

  //getLastSentMessage
  String? getLastSentMessage(String userId, String uid) {
    String? lastMessage;
    _firestore
        .collection('chat_rooms')
        .where('chat_room_id', arrayContains: userId)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        String chatRoomId = value.docs.first.id;
        _firestore
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            lastMessage = value.docs.first.data()['message'] as String?;
          }
        });
      }
    });
    return lastMessage;
  }
}
