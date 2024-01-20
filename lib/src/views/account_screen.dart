import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/provider/auth_provider.dart'
    as local_auth_provider;
import 'package:flutter_application_1/src/views/signup.dart';
import 'package:flutter_application_1/src/views/welcome_page.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final ap =
        Provider.of<local_auth_provider.AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("ChadCHAT"),
        actions: [
          IconButton(
            onPressed: () async {
              await ap.userSignOut().then(
                    (value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      ),
                    ) as FutureOr Function(dynamic value),
                  );
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignupScreen(),
                  ));
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.background,
            backgroundImage: NetworkImage(ap.userModel.profilePicture),
            radius: 50,
          ),
          const SizedBox(height: 20),
          Text(ap.userModel.name),
          Text(ap.userModel.phoneNumber),
          Text(ap.userModel.bio),
        ],
      )),
    );
  }
}
