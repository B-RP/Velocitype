import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:tempo_application/controller/user_controller.dart';
import 'package:tempo_application/model/result_record.dart';
import 'package:tempo_application/views/edit_profile.dart';
import 'package:tempo_application/views/login.dart';
import 'package:tempo_application/widget/toast.dart';

import 'data.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

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
              showRecords
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          showRecords = false;
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        child: const Icon(
                          Icons.close,
                          size: 40.0,
                          color: Colors.black87,
                        ),
                      ),
                    )
                  : const SizedBox(),
              showRecords == false
                  ? Column(
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
                              ),
                            )
                          ],
                        ),
                        _userController.loginUser.value.profileImage != ""
                            ? SizedBox(
                                height: 150,
                                width: 150,
                                child: CircleAvatar(
                                  radius: 150.0,
                                  backgroundImage: NetworkImage(_userController
                                      .loginUser
                                      .value
                                      .profileImage), //Network image is used becuase this image is placed on Firebase storage when is online so for online images we use network image
                                  backgroundColor: Colors.transparent,
                                ),
                              )
                            : SizedBox(
                                height: 150,
                                width: 150,
                                child: CircleAvatar(
                                  radius: 150,
                                  backgroundImage: AssetImage(
                                      "assets/images/dummy.jpeg"), // Network image is used becuase this image is placed on Firebase storage when is online so for online images we use network image
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                        SizedBox(
                          height: 12.0,
                        ),
                        Center(
                            // Showing name of user
                            child: Text(
                          _userController.loginUser.value.name.toUpperCase(),
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        )),
                        SizedBox(
                          height: 12.0,
                        ),
                        Center(
                            // Showing email of user
                            child: Text(
                          _userController.loginUser.value.email,
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.normal,
                              fontSize: 20),
                        )),

                        SizedBox(
                          height: 30.0,
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width / 2) * 0.50,
                          child: Center(
                            child: InkWell(
                              onTap: () async {
                                setState(() {
                                  showRecords = true;
                                });
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
                                  'PAST RESULTS',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 6.sp),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width / 2) * 0.50,
                          child: Center(
                            child: InkWell(
                              onTap: () async {
                                Get.to(() => const EditProfile());
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
                                  'EDIT PROFILE',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 6.sp),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width / 2) * 0.50,
                          child: Center(
                            child: InkWell(
                              onTap: () async {
                                signOutGoogle();
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
                                  'LOGOUT',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 6.sp),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                      ],
                    )
                  : const SizedBox(),
              showRecords == true
                  ? Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r)),
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                      ),
                      child: Text(
                        'PAST RESULTS',
                        style: GoogleFonts.poppins(
                            color: const Color(0xff2F00F9),
                            fontSize: 28,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  : const SizedBox(),
              showRecords
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
                              color: Color(0xFFD9DDE0),
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
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: Center(
                                          child: Text(
                                        "${_userController.records.elementAt(index).wpm} WPM",
                                        style: GoogleFonts.poppins(
                                            fontSize: 28,
                                            color: const Color(0xff2F00F9),
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20.0,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Date ".toUpperCase(),
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Text(
                                                        "Keystrokes: "
                                                            .toUpperCase(),
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Text(
                                                        "Accuracy: "
                                                            .toUpperCase(),
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Text(
                                                        "Correct Words: "
                                                            .toUpperCase(),
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 20.0,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        // This line will use to convert String of time into Date and Time Format and then converting it into 2022-12-28 this format
                                                        DateFormat('MM-dd-yyyy')
                                                            .format(DateTime.parse(
                                                                _userController
                                                                    .records
                                                                    .elementAt(
                                                                        index)
                                                                    .time)),
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Text(
                                                        // index hold the values of current element
                                                        "${double.parse(_userController.records.elementAt(index).keyStrokes).toStringAsFixed(2)}%",
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Text(
                                                        '${_userController.records.elementAt(index).accuracy}%',
                                                        //"${(_userController.records.elementAt(index).score * 100) ~/ 24}%",
                                                        style: TextStyle(
                                                            color: (int.parse(_userController
                                                                        .records
                                                                        .elementAt(
                                                                            index)
                                                                        .accuracy)) <
                                                                    50
                                                                ? Colors.red
                                                                : Colors.green,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Text(_userController
                                                              .records
                                                              .elementAt(index)
                                                              .correctWords
                                                          // index hold the values of current element
                                                          //_userController.records
                                                          //    .elementAt(index)
                                                          //    .score
                                                          //    .toString(),
                                                          ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Time ".toUpperCase(),
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Text(
                                                        "Word Accuracy: "
                                                            .toUpperCase(),
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Text(
                                                        "WPM: ".toUpperCase(),
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Text(
                                                        "Wrong words: "
                                                            .toUpperCase(),
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 20.0,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        // Get exact time from Date and Time
                                                        /*DateFormat.Hms().format(DateTime.parse(
                                                _userController.records
                                                    .elementAt(index)
                                                    .time))*/
                                                        "60 sec",
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Text(
                                                        // index hold the values of current element
                                                        '${(double.parse(_userController.records.elementAt(index).wordAccuracy).toStringAsFixed(2))}%',
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
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
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Text(_userController
                                                              .records
                                                              .elementAt(index)
                                                              .wrongWords
                                                          // index hold the values of current element
                                                          //'${24 - _userController.records.elementAt(index).score}',
                                                          ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                    ],
                                                  ),
                                                ],
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
                  : Center(
                      child: Text(
                      _userController.records.isEmpty
                          ? "" //"No past results found"
                          : "",
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

  bool showRecords = false;
}
