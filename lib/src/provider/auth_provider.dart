import 'dart:async';
import 'dart:convert';
// import 'dart:html' as html;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/model/user_model.dart';
import 'package:flutter_application_1/src/utilities/utilities.dart';
import 'package:flutter_application_1/src/views/verification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'dart:html' if (dart.library.html) 'dart:html' as html;

// Abstract class for handling files
abstract class PlatformFile {
  Future<String> getDownloadUrl();
}

class WebFile implements PlatformFile {
  final Uint8List webFile;

  // html.File? webFile;

  WebFile(this.webFile);

  @override
  Future<String> getDownloadUrl() async {
    if (kDebugMode) {
      print("WebFile: $webFile");
    }

    final storageRef =
        FirebaseStorage.instance.ref().child("web/path/${DateTime.now()}.png");

    await storageRef.putBlob(webFile);

    return await storageRef.getDownloadURL();
  }
}

// Future<Uint8List> blobToUint8List(dynamic blob) async {
//   final reader = html.FileReader();
//   Completer<Uint8List> completer = Completer();

//   reader.onLoad.listen((e) {
//     completer.complete(Uint8List.fromList(reader.result as List<int>));
//   });

//   reader.readAsArrayBuffer(blob);
//   return completer.future;
// }

// }

class MobileFile implements PlatformFile {
  final File mobileFile;

  MobileFile(this.mobileFile);

  @override
  Future<String> getDownloadUrl() async {
    final storageRef =
        FirebaseStorage.instance.ref().child("mobile/path/$mobileFile");
    final uploadTask = storageRef.putFile(mobileFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}

class AuthProvider extends ChangeNotifier {
  bool _isAuth = false;
  bool get isAuth => _isAuth;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _uid;
  String get uid => _uid!;

  UserModel? _userModel;
  UserModel get userModel => _userModel!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  AuthProvider() {
    checkSignIn();
    // signOut();
  }

  // ----------------------------------------------------------------
  // Check if user is signed in
  // ----------------------------------------------------------------

  void checkSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isAuth = s.getBool('isAuth') ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    await s.setBool('isAuth', true);
    _isAuth = true;
    notifyListeners();
  }

  // ----------------------------------------------------------------
  // Sign In With Firebase Authentication using Phone Number
  // ----------------------------------------------------------------

  void SignInWithPhoneNumber(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _firebaseAuth.signInWithCredential(credential);
          },
          verificationFailed: (error) {
            throw Exception(error.message);
          },
          codeSent: (verificationId, forceResendingToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VerificationScreen(verificationId: verificationId),
              ),
            );
          },
          codeAutoRetrievalTimeout: (verificationId) {});
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  // ----------------------------------------------------------------
  // Verify the phone number with the credential
  // ----------------------------------------------------------------

  void VerifyPhoneNumberWithCode({
    required BuildContext context,
    required String verificationId,
    required String userCode,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userCode);

      User user = (await _firebaseAuth.signInWithCredential(credential)).user!;

      if (user != null) {
        _uid = user.uid;
        onSuccess();
      }

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // ----------------------------------------------------------------
  // Database Operations and Methods - checkExistingUser
  // ----------------------------------------------------------------

  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("users").doc(_uid).get();
    if (snapshot.exists) {
      print("User already exists");
      return true;
    } else {
      print("New User");
      return false;
    }
  }

  void saveUserDataToFirestore({
    required BuildContext context,
    required UserModel userModel,
    required PlatformFile platformFile,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final String downloadUrl = await platformFile.getDownloadUrl();
      userModel.profilePicture = downloadUrl;
      userModel.createdAt = DateTime.now().toString();
      userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
      userModel.uid = _firebaseAuth.currentUser!.uid;

      _userModel = userModel;

      // Uplaod to the database
      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .set(userModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // ----------------------------------------------------------------
  // Upload the file to the storage
  // ----------------------------------------------------------------

  // Make file change from web and movbile

  Future<String> saveFileToStorage(String ref, File file) async {
    if (kIsWeb) {
      // print random text to check for errors
      if (kDebugMode) {
        print("Web");
      }
      final storageRef = FirebaseStorage.instance.ref().child(ref);

      await storageRef.putBlob(file.readAsBytesSync().buffer.asUint8List());

      // await storageRef.putData(file.readAsBytesSync());

      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } else {
      if (kDebugMode) {
        print("Mobile");
      }

      UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    }
  }

  // Storing data locally
  Future saveUserDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("user_model", jsonEncode(userModel.toMap()));
  }

  Future getDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("user_model") ?? "";
    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  Future getDataFromFS() async {
    await _firebaseFirestore
        .collection("users")
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      _userModel = UserModel(
        name: snapshot['name'],
        bio: snapshot['bio'],
        profilePicture: snapshot['profilePicture'],
        createdAt: snapshot['createdAt'],
        phoneNumber: snapshot['phoneNumber'],
        uid: snapshot['uid'],
      );
      _uid = userModel.uid;
    });
  }

  Future userSignOut() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isAuth = false;
    notifyListeners();
    s.clear();
  }
}
