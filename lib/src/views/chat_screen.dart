import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/model/message_model.dart';
import 'package:flutter_application_1/src/provider/chat_provider.dart';
// import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String receiverUserName;
  final String receiverUserProfilePicture;
  final String receiverUserUid;
  const ChatScreen(
      {super.key,
      required this.receiverUserName,
      required this.receiverUserProfilePicture,
      required this.receiverUserUid});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatServices _chatServices = ChatServices();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    // send the message to the chat service if it is available
    if (_messageController.text.isNotEmpty) {
      await _chatServices.sendMessage(
          widget.receiverUserUid, _messageController.text);
      _messageController.clear();
    }
  }

  void _deleteMessage(String messageId) async {
    await _chatServices.deleteMessage(
        widget.receiverUserUid, _firebaseAuth.currentUser!.uid, messageId);
  }

  void _editMessage(String messageId, String editedMessage) {
    TextEditingController editController =
        TextEditingController(text: editedMessage);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Edit Message',
              style: TextStyle(color: Colors.white),
            ),
            content: TextFormField(
              controller: editController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'type your edited message',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF549762)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text(
                  'Save',
                  style: TextStyle(color: Color(0xFF549762)),
                ),
                onPressed: () async {
                  await _chatServices.editMessage(
                    widget.receiverUserUid,
                    _firebaseAuth.currentUser!.uid,
                    messageId,
                    editController.text,
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
    // await _chatServices.editMessage(widget.receiverUserUid,
    //     _firebaseAuth.currentUser!.uid, messageId, editedMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF252B3A),
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    NetworkImage(widget.receiverUserProfilePicture),
              ),
              const SizedBox(width: 10),
              Text(
                widget.receiverUserName,
                style: const TextStyle(color: Colors.white),
              ),
              Container(
                color: const Color(0xFF252B3A),
              )
            ],
          ),
          backgroundColor: const Color(0xFF252B3A),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildMessagesList(),
            ),
            _buildMessageInput(),
          ],
        ));
  }

// build the messages list input
  Widget _buildMessageInput() {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: kIsWeb
          ? const EdgeInsets.fromLTRB(16, 16, 16, 75)
          : const EdgeInsets.fromLTRB(16, 16, 16, 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFF549762),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Type a message',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send_outlined),
            iconSize: 30,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  // build the message item

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    final provider = ChatServices();

    var aligment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: aligment,
        children: [
          if (data['senderId'] != _firebaseAuth.currentUser!.uid)
            CircleAvatar(
              backgroundImage: NetworkImage(widget.receiverUserProfilePicture),
            ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: (data['senderId'] == _firebaseAuth.currentUser!.uid)
                    ? const Color(0xFF8A90A1)
                    : const Color(0xFF549762),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['senderName'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    provider.formatTime(data['timestamp'] as Timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data['message'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  if (data['senderId'] == _firebaseAuth.currentUser!.uid)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.white,
                          onPressed: () {
                            _editMessage(document.id, data['message']);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.white,
                          onPressed: () {
                            _deleteMessage(document.id);
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // build the messages list
  Widget _buildMessagesList() {
    return StreamBuilder(
        stream: _chatServices.getMessages(
            _firebaseAuth.currentUser!.uid, widget.receiverUserUid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
          });

          return ListView.builder(
            controller: _scrollController,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var document = snapshot.data!.docs[index];
              return _buildMessageItem(document);
            },
          );
        });
  }
}
