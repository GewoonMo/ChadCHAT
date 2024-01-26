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

// Create a new message from the message
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
  Future<String?> getLastSentMessage(
      String receiverUserId, String currentUserId,
      {int wordLimit = 10}) async {
    String? lastMessage;

    try {
      List<String> userIds = [currentUserId, receiverUserId];
      userIds.sort();
      String chatRoomId = userIds.join('_');

      QuerySnapshot<Map<String, dynamic>> lastMessageQuerySnapshot =
          await _firestore
              .collection('chat_rooms')
              .doc(chatRoomId)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (lastMessageQuerySnapshot.docs.isNotEmpty) {
        lastMessage =
            lastMessageQuerySnapshot.docs.first.data()['message'] as String?;
        if (lastMessage != null && lastMessage.split(' ').length > wordLimit) {
          lastMessage =
              '${lastMessage.split(' ').take(wordLimit).join(' ')} ...';
        }
      }
    } catch (e) {
      print('Error getting last message: $e');
    }

    return lastMessage;
  }

// ----------------------------------------------------------------
// Delete message
// ----------------------------------------------------------------

  Future<void> deleteMessage(
      String receiverUserId, String currentUserId, String messageId) async {
    try {
      List<String> userIds = [currentUserId, receiverUserId];
      userIds.sort();
      String chatRoomId = userIds.join('_');

      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

// ----------------------------------------------------------------
// Edit message
// ----------------------------------------------------------------

  Future<void> editMessage(String receiverUserId, String currentUserId,
      String messageId, String editedMessage) async {
    try {
      List<String> userIds = [currentUserId, receiverUserId];
      userIds.sort();
      String chatRoomId = userIds.join('_');

      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({'message': editedMessage});
    } catch (e) {
      print('Error editing message: $e');
    }
  }

  Future<Timestamp?> getLastSentMessageTime(
      String receiverUserId, String currentUserId) async {
    Timestamp? lastMessageTime;

    try {
      List<String> userIds = [currentUserId, receiverUserId];
      userIds.sort();
      String chatRoomId = userIds.join('_');

      QuerySnapshot<Map<String, dynamic>> lastMessageQuerySnapshot =
          await _firestore
              .collection('chat_rooms')
              .doc(chatRoomId)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (lastMessageQuerySnapshot.docs.isNotEmpty) {
        lastMessageTime = lastMessageQuerySnapshot.docs.first
            .data()['timestamp'] as Timestamp?;
      }
    } catch (e) {
      print('Error getting last message: $e');
    }

    return lastMessageTime;
  }
}
