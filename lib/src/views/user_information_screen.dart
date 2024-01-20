import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/model/user_model.dart';
import 'package:flutter_application_1/src/utilities/utilities.dart';
import 'package:flutter_application_1/src/provider/auth_provider.dart';
import 'package:flutter_application_1/src/views/account_screen.dart';
import 'package:flutter_application_1/src/views/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// import 'dart:html' as html;

import 'package:provider/provider.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  // File? profileImageFile;
  File? _pickedImage;
  Uint8List webImage = Uint8List(8);
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  ImageProvider<Object>? _avatarImage; // Added this variable

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  // void selectedImage() async {
  //   profileImageFile = await pickImage(context);
  //   setState(() {});
  // }

  Future<void> _pickImage() async {
    if (!kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          _pickedImage = selected;
        });
      } else {
        showSnackBar(context, "No image selected");
      }
    } else if (kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          _pickedImage = File(image.path);
        });
      } else {
        showSnackBar(context, "No image selected");
      }
    } else {
      showSnackBar(context, "Something is wrong");
    }

    // Update the _avatarImage based on the selected image
    setState(() {
      if (kIsWeb) {
        _avatarImage = MemoryImage(webImage);
      } else {
        _avatarImage = FileImage(_pickedImage!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: SafeArea(
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              )
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 25.0, horizontal: 5.0),
                child: Center(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => _pickImage(),
                        child: _pickedImage == null
                            ? const CircleAvatar(
                                backgroundColor:
                                    Color.fromARGB(255, 16, 59, 168),
                                radius: 50,
                                child: Icon(
                                  Icons.account_circle,
                                  size: 100,
                                  color: Colors.white,
                                ),
                              )
                            : CircleAvatar(
                                radius: 50,
                                backgroundImage: _avatarImage ??
                                    const AssetImage(
                                        'lib/src/assets/images/chadchat_logo.png'),
                              ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        margin: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            // Name field
                            textField(
                                inputType: TextInputType.name,
                                hintText: "Mohammed el Malki",
                                icon: Icons.account_circle,
                                maxLines: 1,
                                controller: nameController),
                            // Bio Field
                            textField(
                                inputType: TextInputType.text,
                                hintText: "Omschrijving bio",
                                icon: Icons.edit,
                                maxLines: 1,
                                controller: bioController),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => storeUserData(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF549762),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 19),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget textField(
      {required String hintText,
      required IconData icon,
      required TextInputType inputType,
      required int maxLines,
      required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: Colors.green,
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.green,
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          hintText: hintText,
          alignLabelWithHint: true,
          border: InputBorder.none,
          fillColor: Colors.grey[200],
          filled: true,
        ),
      ),
    );
  }

  void storeUserData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    UserModel userModel = UserModel(
      name: nameController.text.trim(),
      bio: bioController.text.trim(),
      profilePicture: "",
      createdAt: "",
      phoneNumber: "",
      uid: "",
    );

    print("_pickedImage: $_pickedImage");
// I/flutter ( 4513): _pickedImage: File: '/data/user/0/com.example.flutter_application_1/cache/595c6e08-b63b-453c-ae8c-35db946958bb/1000000025.png'
    if (_pickedImage != null) {
      PlatformFile platformFile;
      if (kIsWeb) {
        var bytes = await _pickedImage!.readAsBytes();
        platformFile = WebFile(bytes);
      } else {
        platformFile = MobileFile(_pickedImage!);
      }

      ap.saveUserDataToFirestore(
        context: context,
        userModel: userModel,
        platformFile: platformFile,
        onSuccess: () {
          ap.saveUserDataToSP().then(
                (value) => ap.setSignIn().then(
                      (value) => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false),
                    ),
              );
        },
      );
    } else {
      showSnackBar(context, "Please Upload your profile picture");
    }
  }
}
