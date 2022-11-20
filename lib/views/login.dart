import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tempo_application/controller/userControl.dart';
import 'package:tempo_application/main.dart';
import 'package:tempo_application/views/registerScreen.dart';
import 'package:tempo_application/model/resultRecord.dart';
import 'package:tempo_application/model/userModel.dart';

// LOGIN GUI && FUNCTIONS
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

  final UserController _userController = Get.put(
      UserController()); // CREATING AN INSTANCE OF USERCONTROLLER CLASS IN USER MODEL

  saveUser() async {
    await storage.write(key: "email", value: email.text);
    await storage.write(key: "password", value: password.text);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  //When user will login this function will call, and get the details of user past results and assign them to user controller
  // PULLING THE RECORDS FROM FIREBASE
  getResults() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("tests")
        .doc(_userController.loginUser.value.email)
        .collection("results")
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      // LOOP TO CHECK AND PULL EACH RECORD
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
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        SizedBox(height: 0.h),
                        Text(
                          'sign in to continue',
                          style: TextStyle(
                              color: const Color(0xff737373), fontSize: 14.sp),
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
                            )),
                        SizedBox(
                          height: 20.h,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.20),
                              borderRadius: BorderRadius.circular(10.r)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 3),
                          margin: EdgeInsets.symmetric(horizontal: 0.w),
                          child: TextField(
                            style: TextStyle(color: Colors.black54),
                            controller: password,
                            obscureText: passObscure,
                            decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Colors.grey,
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
                                    fontSize: 14.sp,
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
                        Center(
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
                                        'Alert! Your email is badly formatted'));
                              } else {
                                try {
                                  //if Every condition fulfills then sign in user and store details of user to mobile local storage
                                  FirebaseAuth _auth =
                                      FirebaseAuth.instance; // FIREBASE OBJECT
                                  await _auth
                                      .signInWithEmailAndPassword(
                                          // CALLING FUNCTION BUILT IN FIREBASEVAUTH CLASS
                                          email: email.text,
                                          password: password.text)
                                      .then((value) async {
                                    if (value.user != null) {
                                      // IF IT = NULL THE PASSWORD OR EMAIL ARE INCORRECT, IF ITS NOT NULL IT LOGS IN CORRECTLT
                                      saveUser(); // CALLING THIS FUNCTION KEEPS THE USER LOGGED IN
                                      await FirebaseFirestore
                                          .instance // GET USER INFO FROM FIREBASE
                                          .collection(
                                              "users") // FOUND IN THE USERS COLLECTION
                                          .doc(value.user!.uid) // UNDER USER ID
                                          .get()
                                          .then((value) {
                                        if (value.data() != null) {
                                          FUser fUser =
                                              FUser.fromJson(value.data()!);
                                          _userController.loginUser.value =
                                              fUser; // PASS THE USER LOGIN INFO TO USERCONTROLLER FOUND IN USERMODEL
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
                                vertical: 14.h,
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16.sp),
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
                                  fontSize: 14.sp,
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
                                      fontSize: 14.sp),
                                )),
                            Text(
                              ' OR ',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 14.sp),
                            ),
                            InkWell(
                                onTap: () {
                                  _userController.isGuest.value = true;
                                  Get.to(() => const MyApp());
                                },
                                child: Text(
                                  ' Guest Account',
                                  style: TextStyle(
                                      color: Color(0xff2F00F9),
                                      fontSize: 14.sp),
                                )),
                          ],
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
      child: TextField(
        style: TextStyle(color: Colors.black54),
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: icon,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xff737373),
                fontWeight: FontWeight.normal)),
      ),
    );
  }

// LOGO FUNCTION
// USED ANYWHERE TO DISPLAY LOGO
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
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14.sp),
        ),
      ),
    );
  }
}
