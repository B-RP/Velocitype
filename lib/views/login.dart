import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tempo_application/controller/user_controller.dart';
import 'package:tempo_application/main.dart';
import 'package:tempo_application/views/register_screen.dart';

import '../model/result_record.dart';
import '../model/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool loading = false;
  bool passObscure = true;

  final storage = const FlutterSecureStorage();

  final UserController _userController = Get.put(UserController());

  saveUser() async {
    await storage.write(key: "email", value: email.text);
    await storage.write(key: "password", value: password.text);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

// GET RESULTS FUNCTION
// When user logs in this function calls, gets the user's details like past results, and assigns them to user controller
  getResults() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("tests")
        .doc(_userController.loginUser.value.email)
        .collection("results")
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      for (var element in querySnapshot.docs) {
        _userController.records.add(ResultRecord(
          score: element.get("score"),
          time: element.get("time"),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392.72727272727275, 750.909090909091),
      builder: (context, child) => GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            body: SingleChildScrollView(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20.h,
                        ),
                        SizedBox(
                          height: 65.h,
                        ),
                        buildLogo(),
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(
                          'Welcome back!',
                          style: TextStyle(
                              height: 0.65,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        SizedBox(height: 0.h),
                        Text(
                          'Sign in to continue',
                          style: TextStyle(
                              color: const Color(0xff737373), fontSize: 4.sp),
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        buildTextField(
                            hint: 'Email',
                            controller: email,
                            icon: const Icon(
                              Icons.email,
                              color: Colors.grey,
                              size: 20,
                            )),
                        SizedBox(
                          height: 20.h,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.20),
                              borderRadius: BorderRadius.circular(10.r)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 5.h),
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          child: TextField(
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 6.sp,
                                fontWeight: FontWeight.normal),
                            controller: password,
                            obscureText: passObscure,
                            decoration: InputDecoration(
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
                                    fontSize: 6.sp,
                                    color: const Color(0xff737373),
                                    fontWeight: FontWeight.normal)),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: Center(
                            child: InkWell(
                              onTap: () async {
                                // Show loader
                                setState(() {
                                  loading = true;
                                });
                                //If email or password text field is empty then show message to fill that field
                                if (email.text == "" && password.text == "") {
                                  setState(() {
                                    loading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      snackBar(
                                          'Alert! Please enter all details'));
                                }
                                //Check Email is well formatted or not
                                else if (email.text.isEmpty ||
                                    !(email.text.contains("@")) ||
                                    !(email.text.contains("."))) {
                                  setState(() {
                                    loading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      snackBar(
                                          'Alert! Your email is formatted incorrectly'));
                                } else {
                                  try {
                                    // If every condition fulfills then sign in user and store details of user to mobile local storage
                                    FirebaseAuth _auth = FirebaseAuth.instance;
                                    await _auth
                                        .signInWithEmailAndPassword(
                                            email: email.text,
                                            password: password.text)
                                        .then((value) async {
                                      if (value.user != null) {
                                        saveUser();
                                        await FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(value.user!.uid)
                                            .get()
                                            .then((value) {
                                          if (value.data() != null) {
                                            FUser fUser =
                                                FUser.fromJson(value.data()!);
                                            _userController.loginUser.value =
                                                fUser;
                                          }
                                        });
                                        getResults();
                                        _userController.isGuest.value = false;
                                        //Navigate user to Home page
                                        Get.offAll(() => const MyApp());
                                      }
                                    });
                                  } on FirebaseAuthException catch (e) {
                                    setState(() {
                                      loading = false;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar(e.message!));
                                    });
                                  }
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: const Color(0xff2F00F9),
                                    borderRadius: BorderRadius.circular(10.r)),
                                padding: EdgeInsets.symmetric(
                                  vertical: 10.h,
                                ),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 6.sp),
                                ),
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
                              'New user?',
                              style: TextStyle(
                                  fontSize: 4.sp,
                                  color: const Color(0xff737373)),
                            ),
                            InkWell(
                                onTap: () {
                                  Get.to(() => const RegisterScreen());
                                },
                                child: Text(
                                  '  Register',
                                  style: TextStyle(
                                      color: const Color(0xffE98445),
                                      fontSize: 4.sp),
                                )),
                            Text(
                              ' OR ',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 4.sp),
                            ),
                            InkWell(
                                onTap: () {
                                  _userController.isGuest.value = true;
                                  Get.to(() => const MyApp());
                                },
                                child: Text(
                                  'Guest Account',
                                  style: TextStyle(
                                      color: Color(0xff2F00F9), fontSize: 4.sp),
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        )
                      ],
                    ),
                  ),
                  if (loading) const CircularProgressIndicator()
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
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.20),
          borderRadius: BorderRadius.circular(10.r)),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      width: MediaQuery.of(context).size.width * 0.35,
      child: TextField(
        style: TextStyle(
            color: Colors.black54,
            fontSize: 6.sp,
            fontWeight: FontWeight.normal),
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: icon,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 6.sp,
                color: const Color(0xff737373),
                fontWeight: FontWeight.normal)),
      ),
    );
  }

  Widget buildLogo() {
    return SizedBox(
      height: 200.h,
      width: 200.h,
      child: Image.asset('assets/images/new.PNG'),
    );
  }

  SnackBar snackBar(String message) {
    return SnackBar(
      backgroundColor: Colors.red,
      content: ScreenUtilInit(
        builder: (context, child) => Text(
          message,
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 10.sp),
        ),
      ),
    );
  }
}
