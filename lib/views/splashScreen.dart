import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:tempo_application/controller/userControl.dart';
import 'package:tempo_application/views/login.dart';
import '../main.dart';
import 'package:tempo_application/model/resultRecord.dart';
import 'package:tempo_application/model/userModel.dart';

// FIRST SCREEN BLANK SCREEN WITH THE SPLASH LOGO
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserController _userController = Get.put(UserController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
            height: 200, child: Image.asset('assets/images/logoGif.gif')),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // This function get the user details
    checkUser();
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

// When app runs this function call and
  checkUser() async {
    const storage = FlutterSecureStorage();
    // Get the stored details of last user and keep its login again  if it doesn't logout
    String? email = await storage.read(key: "email");
    String? password = await storage.read(key: "password");
    if (await storage.read(key: "email") != null &&
        await storage.read(key: "password") != null) {
      try {
        FirebaseAuth _auth = FirebaseAuth.instance;
        UserCredential newUser = await _auth.signInWithEmailAndPassword(
            email: email!, password: password!);
        // get the records of results and give them to user controller
        if (newUser.user != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(newUser.user!.uid)
              .get()
              .then((value) {
            FUser fUser = FUser.fromJson(value.data()!);
            _userController.loginUser.value = fUser;
          });
          getResults();
          // Navigate user to Home page
          Get.offAll(() => const MyApp());
        }
      } on FirebaseAuthException catch (e) {
        snackBar(e.message.toString());
        // if user is not logged in then navigate user to login screen
        Future.delayed(const Duration(milliseconds: 1500), () {
          Get.offAll(() => const LoginScreen());
        });
      }
    } else {
      Future.delayed(const Duration(milliseconds: 2000), () {
        //  Get.offAll(() => const MyApp());
        Get.offAll(() => const LoginScreen());
      });
    }
  }

// Function to get user past results record and then send to user controller
  getResults() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("tests")
        .doc(_userController.loginUser.value.email)
        .collection("results")
        .get();
    for (var element in querySnapshot.docs) {
      _userController.records.add(ResultRecord(
        score: element.get("score"),
        time: element.get("time"),
      ));
    }
  }
}
