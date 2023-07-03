import 'dart:core';
import 'dart:core';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tempo_application/controller/user_controller.dart';
import 'package:tempo_application/views/add_profile_pic.dart';

import '../model/user_model.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Email, username, password, and confirm user text field controllers
  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  // This boolean variable keeps the password field text hide
  bool passObscure = true;
  bool confirmPassObscure = true;
  bool loading = false;
  String nameError = '';
  String emailError = '';
  String passwordError = '';
  String passwordNotMatched = '';
  String exceptionMessage = '';

  final UserController _userController = Get.put(UserController());

  SnackBar snackBar(String message) {
    return SnackBar(
      backgroundColor: Colors.red,
      // This ScreenUtilIntil gets the screen size and pixels details and
      // divide the size of screen widgets according to screen
      content: ScreenUtilInit(
        builder: (context, child) => Text(
          message,
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 10.sp),
        ),
      ),
    );
  }

  final storage = const FlutterSecureStorage();
// When user registers then the email and password of user saved in mobile local storage to keep
// them login when user open app again without asking again to login
  saveUser() async {
    await storage.write(key: "email", value: _email.text);
    await storage.write(key: "password", value: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    //Gesture detector widget detect the tap on itself
    return GestureDetector(
      onTap: () {
        // When user tapped on text field then it will enabled
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset:
              true, // When keyboard opens then the UI of system will  not be disturbed
          body: ScreenUtilInit(
            builder: (context, child) => SingleChildScrollView(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 22.w, vertical: 10),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 35.h,
                        ),
                        buildLogo(), // Show logo on top of screen
                        SizedBox(
                          height: 35.h,
                        ),
                        Text(
                          'New Here?'.toUpperCase(),
                          style: TextStyle(
                              height: 0.65,
                              fontSize: 6.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Create new account',
                          style: TextStyle(
                              color: const Color(0xff737373), fontSize: 4.sp),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        // User name Text field with _name controller and Person Icon

                        Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: exceptionMessage.isNotEmpty,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.50),
                                    borderRadius: BorderRadius.circular(10.r)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 4.w),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 0.w, vertical: 5.w),
                                child: Text(
                                  exceptionMessage,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(10.r)),
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              margin: EdgeInsets.symmetric(horizontal: 0.w),
                              child: TextFormField(
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 5.sp,
                                    fontWeight: FontWeight.normal),
                                controller: _name,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 12.h),
                                  border: InputBorder.none,
                                  hintText: 'Name',
                                  hintStyle: TextStyle(
                                      fontSize: 5.sp,
                                      color: const Color(0xff737373),
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 60.0, top: 6.0, bottom: 0.0),
                              child: Text(
                                nameError,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            )
                          ],
                        ),

                        SizedBox(
                          height: 14.5.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildTextField(
                                hint: 'Email',
                                controller: _email,
                                icon: const Icon(
                                  Icons.email,
                                  color: Colors.grey,
                                  size: 20,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 60.0, top: 6.0, bottom: 0.0),
                              child: Text(
                                emailError,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            )
                          ],
                        ),

                        SizedBox(
                          height: 14.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .35,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(10.r)),
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              margin: EdgeInsets.symmetric(horizontal: 0.w),
                              child: TextField(
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 5.sp,
                                    fontWeight: FontWeight.normal),
                                controller: _password,
                                obscureText: passObscure,
                                decoration: InputDecoration(
                                    focusColor: Colors.white70,
                                    prefixIcon: const Icon(
                                      Icons.lock,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    suffixIcon: GestureDetector(
                                      child: Icon(
                                        passObscure == true
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      // If user press unhide icon then password will be visible to user
                                      onTap: () {
                                        setState(() {
                                          if (passObscure == true) {
                                            passObscure = false;
                                          } else
                                            passObscure = true;
                                        });
                                      },
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 12.h),
                                    border: InputBorder.none,
                                    hintText: "Password",
                                    hintStyle: TextStyle(
                                        fontSize: 5.sp,
                                        color: const Color(0xff737373),
                                        fontWeight: FontWeight.normal)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 60.0, top: 6.0, bottom: 0.0),
                              child: Text(
                                passwordError,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 14.5.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .35,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(10.r)),
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              margin: EdgeInsets.symmetric(horizontal: 0.w),
                              child: TextField(
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 5.sp,
                                    fontWeight: FontWeight.normal),
                                controller: _confirmPassword,
                                obscureText: confirmPassObscure,
                                decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.lock,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    suffixIcon: GestureDetector(
                                      child: Icon(
                                        confirmPassObscure == true
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          if (confirmPassObscure == true) {
                                            confirmPassObscure = false;
                                          } else
                                            confirmPassObscure = true;
                                        });
                                      },
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 6.h),
                                    border: InputBorder.none,
                                    hintText: 'Confirm password',
                                    hintStyle: TextStyle(
                                        fontSize: 5.sp,
                                        color: const Color(0xff737373),
                                        fontWeight: FontWeight.normal)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 60.0, top: 6.0, bottom: 0.0),
                              child: Text(
                                passwordNotMatched,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: InkWell(
                            onTap: () async {
                              //Start  loader
                              setState(() {
                                loading = true;
                              });
                              // If any text field is empty then ask user to fill it
                              bool notEmpty = (_name.text != '' &&
                                  _email.text != '' &&
                                  _password.text != '' &&
                                  _confirmPassword.text != '');
                              if (!notEmpty) {
                                setState(() {
                                  loading = false;
                                  nameError = 'Name can\'t be empty';
                                  emailError = 'Email can\'t be empty';
                                  passwordError =
                                      'Password can\'t be less than 8 characters';
                                });
                              }
                              if (_name.text.isEmpty) {
                                setState(() {
                                  loading = false;
                                  nameError = 'Name can\'t be empty';
                                  emailError = '';
                                  passwordError = '';
                                });
                                /*   ScaffoldMessenger.of(context).showSnackBar(
                                    snackBar('Please enter your name'));*/
                              } else {
                                setState(() {
                                  loading = false;
                                  nameError = '';
                                });
                              }
                              if (_email.text.isEmpty ||
                                  !(_email.text.contains("@")) ||
                                  !(_email.text.contains("."))) {
                                setState(() {
                                  loading = false;
                                  emailError = 'Email must contain @ and .';
                                });
                                /*ScaffoldMessenger.of(context).showSnackBar(snackBar(
                                    'Alert! Your email is formatted incorrectly'));*/
                              } else {
                                setState(() {
                                  loading = false;
                                  emailError = '';
                                });
                              }
                              if (_password.text.isEmpty ||
                                  (_password.text.length < 7)) {
                                setState(() {
                                  loading = false;
                                  passwordError =
                                      'Password must be at least 8 characters';
                                });
                                /*ScaffoldMessenger.of(context).showSnackBar(snackBar(
                                    'Please enter a password with at least 8 characters'));*/
                              } else {
                                setState(() {
                                  loading = false;
                                  passwordError = '';
                                });
                              }
                              if (_password.text != (_confirmPassword.text)) {
                                setState(() {
                                  loading = false;
                                  passwordNotMatched = 'Passwords do not match';
                                });
                                /*ScaffoldMessenger.of(context).showSnackBar(
                                    snackBar('Your password doesn\'t match'));*/
                              } else {
                                setState(() {
                                  loading = false;
                                  passwordNotMatched = '';
                                });
                              }

                              if (emailError == '' &&
                                  passwordError == '' &&
                                  emailError == '' &&
                                  passwordNotMatched == '') {
                                try {
                                  // Register user with email and password
                                  FirebaseAuth _auth = FirebaseAuth.instance;
                                  UserCredential _newUser = await _auth
                                      .createUserWithEmailAndPassword(
                                    email: _email.text.trim(),
                                    password: _password.text,
                                  );
                                  // Add other details of user to Firebase
                                  if (_newUser.user != null) {
                                    FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(_auth.currentUser!.uid)
                                        .set({
                                      "email": _email.text.trim(),
                                      "name": _name.text.trim(),
                                      "uid": _auth.currentUser!.uid,
                                      "photo": "",
                                    });
                                    FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(_newUser.user!.uid)
                                        .get()
                                        .then((value) {
                                      FUser user =
                                          FUser.fromJson(value.data()!);
                                      _userController.loginUser.value = user;
                                      setState(() {
                                        loading = false;
                                      });
                                      saveUser();
                                      // After saving the details move user to add profile picture screen
                                      _userController.isGuest.value = false;
                                      Get.to(() => const AddProfilePic());
                                    });
                                  } else {
                                    // Close loader
                                    setState(() {
                                      loading = false;
                                    });
                                  }
                                } on FirebaseAuthException catch (e) {
                                  setState(() {
                                    loading = false;
                                  });
                                  log('Exceptttion $e');
                                  setState(() {
                                    exceptionMessage = e.message!;
                                  });
                                  /* ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar(e.message!));*/
                                }
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                vertical: 10.h,
                              ),
                              // width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Color(0xff2F00F9),
                                  borderRadius: BorderRadius.circular(10.r)),
                              child: Text(
                                'Register'.toUpperCase(),
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 5.sp),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: TextStyle(
                                  fontSize: 4.sp,
                                  color: const Color(0xff737373)),
                            ),
                            InkWell(
                                onTap: () {
                                  // If user already has an account then navigate user to login screen again
                                  Get.to(() => const LoginScreen());
                                },
                                child: Text(
                                  ' Login',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 197, 3, 250),
                                      fontSize: 4.sp),
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                  if (loading) CircularProgressIndicator()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      {required String hint,
      required TextEditingController controller,
      required Icon icon}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10.r)),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      margin: EdgeInsets.symmetric(horizontal: 0.w),
      child: TextField(
        style: TextStyle(
            color: Colors.black54,
            fontSize: 5.sp,
            fontWeight: FontWeight.normal),
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: icon,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 5.sp,
                color: const Color(0xff737373),
                fontWeight: FontWeight.normal)),
      ),
    );
  }

  Widget buildLogo() {
    return SizedBox(
      height: 120.h,
      child: Image.asset('assets/images/new.PNG'),
    );
  }
}
