import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:tempo_application/controller/userControl.dart';
import 'package:tempo_application/model/resultRecord.dart';
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

// This function is call also when we user signout because storage
// contain the details of previous user so if user logout then we
// have to remove its details as well so this function will remove the user details from mobile storage

  deleteUser() async {
    await storage.delete(key: "email");
    await storage.delete(key: "password");
  }

  // WHen user press log out or signout then this function will call this allow user to sign out from the app
  void signOutGoogle() async {
    try {
      await _auth.signOut();
      deleteUser();
      _userController.records.value =
          []; // Remove all the records of previous user
      Get.offAll(const LoginScreen()); // Navigate user to Login Screen
    } catch (e) {
      // when there will any run time exception
      log("*******************Exception******************");
      log(e.toString());
      showToast("Something went wrong..");
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
      content: Column(
        children: [
          //Get image of user from firebase and show it into circle shade widget
          CircleAvatar(
            radius: 30.0,
            backgroundImage: NetworkImage(_userController.loginUser.value
                .profileImage), //Network image is used becuase this image is placed on firebase storage when is online so for online images we use network image
            backgroundColor: Colors.transparent,
          ),
          Center(
              //Showing name of user
              child: Text(
            _userController.loginUser.value.name,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          )),
          Center(
              //Showing email of user
              child: Text(
            _userController.loginUser.value.email,
            style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.normal,
                fontSize: 12),
          )),
          Center(
              //signout or logout button
              child: TextButton(
            onPressed: () {
              // This function execute when user press the button
              signOutGoogle();
            },
            child: const Text(
              'Logout',
            ),
          )),
          const Text(
            "Past Results",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Expanded(
            //if _userconyrolller have records then it will show all records
            // listwise otherwise show the text that no record found
            child: _userController.records.isNotEmpty
                ? ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _userController.records
                        .length, //the list will call itself number of records times
                    itemBuilder: (context, index) {
                      //This card widget will show number of records times
                      return Card(
                        //Card with circular border
                        color: Colors.white.withOpacity(0.75),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: Center(
                                    child: Text(
                                  "Score Card",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                )),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    //THis line will use to convert String of time into Date and Tme Format and then converting it into 2022-12-28 this format
                                    DateFormat('yyyy-MM-dd').format(
                                        DateTime.parse(_userController.records
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
                                    "40 sec",
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
                                        const Text(
                                          "Correct: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          //index hold the values of current element
                                          _userController.records
                                              .elementAt(index)
                                              .score
                                              .toString(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          "Wrong: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          //index hold the values of current element
                                          '${40 - _userController.records.elementAt(index).score}',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          "Key Acc: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          //index hold the values of current element
                                          _data.calcKeyAccuracy().toString(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          "Word Acc: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                            //index hold the values of current element
                                            _data
                                                .calcWordAccuracy()
                                                .toString()),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          "Percentage: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          "${(_userController.records.elementAt(index).score * 100) ~/ 40}%",
                                          style: TextStyle(
                                              color: ((_userController.records
                                                                  .elementAt(
                                                                      index)
                                                                  .score *
                                                              100) ~/
                                                          40) <
                                                      50
                                                  ? Colors.red
                                                  : Colors.green,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0),
                                      child: Row(
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
                                            _data.calcWPM(20.0).toString(),
                                            style: TextStyle(
                                                color: ((_userController.records
                                                                    .elementAt(
                                                                        index)
                                                                    .score *
                                                                100) ~/
                                                            40) <
                                                        50
                                                    ? Colors.red
                                                    : Colors.green,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    })
                // If no record found in db then this widget will execute
                : const Center(
                    child: Text(
                    "No Past Result Found .. ",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  )),
          )
        ],
      ),
    );
  }
}






















// OLD MENU CODE
/*
class Menu extends StatelessWidget {
  const Menu(BuildContext context, {super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Builder(
        builder: (context) {
          //get available height and width of the build area of the widget
          var height = MediaQuery.of(context).size.height;
          var width = MediaQuery.of(context).size.width;

          return Container(
              height: height - 150,
              width: width - 150,
              child: Column(children: [
                Row(children: [
                  Spacer(),
                  new IconButton(
                      icon: Icon(
                        Icons.minimize_rounded,
                        color: Color.fromARGB(255, 99, 96, 96),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ]),
                Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      Text(
                        "70 WPM",
                        style: TextStyle(
                          fontSize: 80,
                          color: Color.fromARGB(255, 31, 38, 169),
                        ),
                      ),
                      Text(
                        "Top 15%",
                        style: TextStyle(
                          fontSize: 30,
                          color: Color.fromARGB(255, 31, 38, 169),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(children: [
                            Text(
                              "Keystrokes    (320 | 0) 320",
                              style: TextStyle(
                                fontSize: 35,
                                color: Color.fromARGB(255, 58, 58, 61),
                              ),
                            ),
                            Text(
                              "Accuracy       100.00%",
                              style: TextStyle(
                                fontSize: 35,
                                color: Color.fromARGB(255, 58, 58, 61),
                              ),
                            ),
                            Text(
                              "Correct words      70",
                              style: TextStyle(
                                fontSize: 35,
                                color: Color.fromARGB(255, 58, 58, 61),
                              ),
                            ),
                            Text(
                              "Wrong words        0",
                              style: TextStyle(
                                fontSize: 35,
                                color: Color.fromARGB(255, 58, 58, 61),
                              ),
                            )
                          ]))
                    ]))
              ]));
        },
      ),
    );
  }
}
*/