import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:tempo_application/controller/user_controller.dart';
import 'package:tempo_application/model/result_record.dart';
import 'package:tempo_application/views/login.dart';
import 'package:tempo_application/widget/toast.dart';

import 'data.dart';

class Menu extends StatefulWidget {
  const Menu(BuildContext context, {super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final UserController _userController = Get.put(UserController());
  final GoogleSignIn googleSignIn = GoogleSignIn();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final storage = const FlutterSecureStorage();
  final Data _data = Data();
  @override
  initState() {
    super.initState();
  }

// THIS FUNCTION IS CALLED ALSO WHEN THE USER SIGNS OUT
// BC STORAGE CONTAINS THE DETAILS OF PREVIOUS USER
// IF USER LOGS OUT THEN THE USER'S DETAILS ARE REMOVED
  deleteUser() async {
    await storage.delete(key: "email");
    await storage.delete(key: "password");
  }

// WHEN USER PRESSES logout, THIS FUNCTION GETS CALLED AND ALLOWS USER TO SIGN OUT FROM THE APP
  void signOutGoogle() async {
    try {
      await _auth.signOut();
      deleteUser();
      _userController.records.value =
          []; // Remove all the records of previous user
      Get.offAll(const LoginScreen()); // Navigate user to Login Screen
    } catch (e) {
      // RUNTIME EXCEPTION catch block EXECUTION
      log("-EXCEPTION!-");
      log(e.toString());
      showToast("Something went wrong");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width / 2,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Get image of user from Firebase and show it into circle shade widget
              Row(
                children: [
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.close,
                      size: 40,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
              _userController.loginUser.value.profileImage != ""
                  ? SizedBox(
                      height: 90,
                      width: 90,
                      child: CircleAvatar(
                        radius: 90.0,
                        backgroundImage: NetworkImage(_userController
                            .loginUser
                            .value
                            .profileImage), //Network image is used becuase this image is placed on Firebase storage when is online so for online images we use network image
                        backgroundColor: Colors.transparent,
                      ),
                    )
                  : SizedBox(
                      height: 90,
                      width: 90,
                      child: CircleAvatar(
                        radius: 90.0,
                        backgroundImage: AssetImage(
                            "assets/images/dummy.jpeg"), // Network image is used becuase this image is placed on Firebase storage when is online so for online images we use network image
                        backgroundColor: Colors.transparent,
                      ),
                    ),
              Center(
                  // Showing name of user
                  child: Text(
                _userController.loginUser.value.name,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              )),
              Center(
                  // Showing email of user
                  child: Text(
                _userController.loginUser.value.email,
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.normal,
                    fontSize: 20),
              )),
              Center(
                  // signout or logout button
                  child: TextButton(
                onPressed: () {
                  // This function executes when user presses the button
                  signOutGoogle();
                },
                child: Text('Logout',
                    style: TextStyle(
                        color: Color.fromARGB(255, 195, 0, 255),
                        fontWeight: FontWeight.normal,
                        fontSize: 18)),
              )),
              Text(
                "Past results",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30.0,
              ),
              _userController.records.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 50.0),
                      width: MediaQuery.of(context).size.width * .40,
                      child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _userController.records
                              .length, // the list will call itself number of records times
                          itemBuilder: (context, index) {
                            // This card widget will show number of records times
                            return Card(
                              // Card with circular border
                              color: Colors.white.withOpacity(0.75),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10.0),
                                      child: Center(
                                          child: Text(
                                        "${_userController.records.elementAt(index).wpm} WPM",
                                        style: TextStyle(
                                            fontSize: 28,
                                            color: Color(0xff2F00F9),
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          "Date ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          "Time ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          // This line will use to convert String of time into Date and Time Format and then converting it into 2022-12-28 this format
                                          DateFormat('yyyy-MM-dd').format(
                                              DateTime.parse(_userController
                                                  .records
                                                  .elementAt(index)
                                                  .time)),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        const Text(
                                          // Get exact time from Date and Time
                                          /*DateFormat.Hms().format(DateTime.parse(
                                            _userController.records
                                                .elementAt(index)
                                                .time))*/
                                          "60 sec",
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Keystrokes: ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 40.0,
                                              ),
                                              Text(
                                                // index hold the values of current element
                                                "${_userController.records.elementAt(index).keyStrokes}%",
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Word Accuracy: ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Text(
                                                // index hold the values of current element
                                                '${_userController.records.elementAt(index).wordAccuracy}%',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Accuracy: ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 40.0,
                                              ),
                                              Text(
                                                '${_userController.records.elementAt(index).accuracy}%',
                                                //"${(_userController.records.elementAt(index).score * 100) ~/ 24}%",
                                                style: TextStyle(
                                                    color: (int.parse(
                                                                _userController
                                                                    .records
                                                                    .elementAt(
                                                                        index)
                                                                    .accuracy)) <
                                                            50
                                                        ? Colors.red
                                                        : Colors.green,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "WPM: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                Text(
                                                  //"${(_userController.records.elementAt(index).score * 100) ~/ 40}%",
                                                  '${_userController.records.elementAt(index).wpm}',
                                                  /*style: TextStyle(
                                                      color: (int.parse(
                                                                  _userController
                                                                      .records
                                                                      .elementAt(
                                                                          index)
                                                                      .score)) <
                                                              50
                                                          ? Colors.red
                                                          : Colors.green,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),*/
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12.0),
                                          child: Row(
                                            children: [
                                              const Text(
                                                "Correct Words: ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 40.0,
                                              ),
                                              Text(_userController.records
                                                      .elementAt(index)
                                                      .correctWords
                                                  // index hold the values of current element
                                                  //_userController.records
                                                  //    .elementAt(index)
                                                  //    .score
                                                  //    .toString(),
                                                  ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12.0),
                                          child: Row(
                                            children: [
                                              const Text(
                                                "Wrong words: ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 40.0,
                                              ),
                                              Text(_userController.records
                                                      .elementAt(index)
                                                      .wrongWords
                                                  // index hold the values of current element
                                                  //'${24 - _userController.records.elementAt(index).score}',
                                                  ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    )
                  // If no record found in db then this widget will execute
                  : const Center(
                      child: Text(
                      "No past results found",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                      ),
                    ))
            ],
          ),
        ),
      ),
    );
  }
}
