import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/src/provider/auth_provider.dart';
import 'package:flutter_application_1/src/views/welcome_page.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // bool needsWeb = Platform.isLinux | Platform.isWindows;

  // await Firebase.initializeApp(
  //     options: needsWeb
  //         ? DefaultFirebaseOptions.web
  //         : DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, Key? k});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
        child: MaterialApp(
          title: 'ChadCHAT',
          theme: ThemeData(
            // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            colorScheme: ThemeData().colorScheme.copyWith(
                  background: const Color(0xFF252B3A),
                ),
            // set the background color here
          ),
          home: const WelcomeScreen(),
        ));
  }
}
