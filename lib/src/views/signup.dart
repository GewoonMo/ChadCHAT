import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/src/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();

  Country selectedCountry = Country(
    phoneCode: "31",
    countryCode: "NL",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Netherlands",
    example: "Netherlands",
    displayName: "Netherlands",
    displayNameNoCountryCode: "NL",
    e164Key: "",
  );

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final TextEditingController _phoneNumberController = TextEditingController();
  // String _verfiicationId;

  @override
  Widget build(BuildContext context) {
    _phoneNumberController.selection = TextSelection.fromPosition(
      TextPosition(offset: _phoneNumberController.text.length),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
            child: Column(
              children: [
                // Icon or Image Placeholder
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(75), // Adjust as needed
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
                  'Register for ChadCHAT',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Add your phone number to get started, we will send you a verification code',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  cursorColor: Colors.white38,
                  controller: _phoneNumberController,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  onChanged: (value) => setState(() {
                    // Handle country code changes
                    _phoneNumberController.text = value;
                  }),
                  decoration: InputDecoration(
                    hintText: "Enter phone number",
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: Colors.white38,
                      fontSize: 15,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white38),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white38),
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                              context: context,
                              countryListTheme: const CountryListThemeData(
                                  flagSize: 25, bottomSheetHeight: 550),
                              onSelect: (value) {
                                setState(() {
                                  selectedCountry = value;
                                });
                              });
                        },
                        child: Text(
                          "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    suffixIcon: _phoneNumberController.text.length > 9
                        ? Container(
                            height: 30,
                            width: 30,
                            margin: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF549762)),
                            child: const Icon(
                              Icons.done,
                              color: Colors.white,
                              size: 20,
                            ))
                        : null,
                  ),
                ),
                const SizedBox(
                  height: 50,
                  width: double.infinity,
                ),
                const Text(
                  'By tapping Sign Up, you agree to our Terms, Data Policy and Cookies Policy.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => verifyPhoneNumber(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF549762),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 19),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
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

  void verifyPhoneNumber() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = _phoneNumberController.text.trim();
    ap.SignInWithPhoneNumber(
        context, "+${selectedCountry.phoneCode}$phoneNumber");
  }
}
