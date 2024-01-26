import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSeeder {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedUsers() async {
    // Create a list of users
    await createUser(
      name: "user 1",
      bio: "Dit is de bio van user een.",
      phoneNumber: "+31612345678",
    );

    await createUser(
      name: "user 2",
      bio: "Dit is de bio van user twee.",
      phoneNumber: "+31687654321",
    );
  }

  Future<void> createUser({
    required String name,
    required String bio,
    required String phoneNumber,
  }) async {
    try {
      // Create a new user
      ConfirmationResult confirmationResult =
          await _firebaseAuth.signInWithPhoneNumber(phoneNumber);

      String verificationId = confirmationResult.verificationId;

      String userCode = "666666";

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userCode,
      );

      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      String uid = userCredential.user!.uid;

      String profilePicture = 'lib/src/assets/images/placeholder_image.jpg';

      UserModel newUser = UserModel(
        name: name,
        bio: bio,
        profilePicture: profilePicture,
        createdAt: DateTime.now().toString(),
        phoneNumber: phoneNumber,
        uid: uid,
      );

      await _firestore.collection("users").doc(uid).set(newUser.toMap());

      if (kDebugMode) {
        print("User created: $uid");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error creating user: $e");
      }
    }
  }
}
