import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/provider/chat_provider.dart';
import 'package:flutter_application_1/src/views/chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/src/provider/auth_provider.dart';
import 'package:flutter_application_1/src/views/account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // Provider.of<AuthProvider>(context, listen: false).getAllUsers();
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Provider.of<AuthProvider>(context, listen: false).getAllUsers();
    setState(() {});
    // await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final apc = Provider.of<ChatServices>(context, listen: false);

    if (ap.allUsers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text(
          "ChadCHAT",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ));
            },
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 40.0,
            ),
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: ap.allUsers.length,
          itemBuilder: (context, index) {
            Future<String?> lastMessageFuture = apc.getLastSentMessage(
                ap.allUsers[index].uid, ap.uid,
                wordLimit: 20);

            return FutureBuilder<String?>(
                future: lastMessageFuture,
                builder: (context, snapshot) {
                  String lastMessage = snapshot.data ?? '';

                  return ListTile(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            receiverUserName: ap.allUsers[index].name,
                            receiverUserProfilePicture:
                                ap.allUsers[index].profilePicture,
                            receiverUserUid: ap.allUsers[index].uid,
                          ),
                        ),
                      );

                      await _initializeData();
                    },
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.background,
                      backgroundImage:
                          NetworkImage(ap.allUsers[index].profilePicture),
                    ),
                    title: Text(
                      ap.allUsers[index].name,
                      style: const TextStyle(
                          color: Color(0xFF549762),
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      lastMessage,
                      style: const TextStyle(color: Color(0xFF989EAE)),
                    ),
                  );
                });
          }),
    );
  }
}
