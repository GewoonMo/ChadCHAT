// ----------------------------------------------------------------
// Impiorts the following functions from the Flutter Package:
// ----------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/provider/auth_provider.dart';
import 'package:flutter_application_1/src/views/account_screen.dart';
import 'package:flutter_application_1/src/views/user_information_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class VerificationScreen extends StatefulWidget {
  final String verificationId;
  const VerificationScreen({super.key, required this.verificationId});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

// ----------------------------------------------------------------
// Verify Screen State
// ----------------------------------------------------------------

class _VerificationScreenState extends State<VerificationScreen> {
  String? verificationCode;
  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              )
            : Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      // Icon or Image Placeholder
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          borderRadius:
                              BorderRadius.circular(75), // Adjust as needed
                        ),
                        child: Image.asset(
                          'lib/src/assets/images/chadchat_logo.png',
                          width: 100,
                          height: 100,
                          // fit: BoxFit.cover,
                          // color: Colors.white, // Adjust the color as needed
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Verrify Account',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Er is een code verstuurd naar de nummer die je hebt opgegeven. Vul deze hieronder in om je account te bevestigen',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Pinput(
                        length: 6,
                        showCursor: true,
                        defaultPinTheme: PinTheme(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onCompleted: (value) {
                          setState(() {
                            verificationCode = value;
                          });
                        },
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (verificationCode != null) {
                              verifyPhoneNumber(context, verificationCode!);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Please enter 6 digit verification code"),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF549762),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 19),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Verify Code",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Didn't receive the code?",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 15),
                      const Text(
                        "Resend New Code",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF549762),
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Verify Phonenummber
  // ----------------------------------------------------------------

  void verifyPhoneNumber(BuildContext context, String verificationCode) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    ap.VerifyPhoneNumberWithCode(
        context: context,
        verificationId: widget.verificationId,
        userCode: verificationCode,
        onSuccess: () {
          ap.checkExistingUser().then((value) async {
            if (value == true) {
              ap
                  .getDataFromFS()
                  .then(
                    (value) => ap.saveUserDataToSP().then(
                          (value) => ap.setSignIn().then(
                                (value) => Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AccountScreen()),
                                    (route) => false),
                              ),
                        ),
                  )
                  .catchError(
                    (e) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    ),
                  );
            } else {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserInformationScreen()),
                  (route) => false);
            }
          }).catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ),
            );
          });
        });
  }
}
