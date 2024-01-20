import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

Future<File?> pickImage(BuildContext context) async {
  File? profileImageFile;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      profileImageFile = File(pickedImage.path);
    }
  } catch (e) {
    // ignore: use_build_context_synchronously
    showSnackBar(context, e.toString());
  }

  return profileImageFile;
}
