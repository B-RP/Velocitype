//import 'dart:html';

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tempo_application/controller/user_controller.dart';
import 'package:tempo_application/controller/words_controller.dart';
import 'package:tempo_application/model/result_record.dart';
import 'package:tempo_application/views/add_profile_pic.dart';
import 'package:tempo_application/views/login.dart';
import 'package:tempo_application/views/splash_screen.dart';
import 'data.dart';
import 'menu.dart';

Future<void> main() async {
  // These two line are used to initialize the firebase database when app starts
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,

    options: const FirebaseOptions(
      apiKey: "AIzaSyCo1YdvFr51U6_qf9cqu3e5n68Fq8XdiaA",
      authDomain: "tempo-app-b2bb7.firebaseapp.com",
      projectId: "tempo-app-b2bb7",
      storageBucket: "tempo-app-b2bb7.appspot.com",
      messagingSenderId: "607142924875",
      appId: "1:607142924875:web:3772b01be6f10f17cf73ce",
      measurementId: "G-8EQ3ZQYKQ1",
    ),
  );
  runApp(const GetMaterialApp(
      home: SplashScreen())); // App moves to the splash screen
}

// This MyApp screen is actually home page when user login then this screen will open
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This _wordController is an instance of Words Controller
  // it keep the record of words and current word index and number of right words
  final WordsController _wordsController = Get.put(WordsController());

  // When this screen will open the first function which will call is the initState function,'
  // it will help to get the require things necessary to initialize elements of screen
  // In our case we are setting the current word index to 0 means first and score is set to 0
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _wordsController.index.value = 0;
    _wordsController.score.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Tempo App',
        theme: ThemeData(
            primaryColor: Colors.redAccent, primaryColorDark: Colors.red
            //colorSchemeSeed: const Color.fromARGB(255, 255, 255, 255),
            //useMaterial3: true
            ),
        home: const MainPage());
  }
}

//Main application
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    //double appWidth = MediaQuery.of(context).size.width;
    final textFieldController = TextEditingController();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5), BlendMode.darken),
                    image: const AssetImage(
                      "assets/images/background.png",
                    ))),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: Timer(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: WordBank(),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                          child: InteractionRow())
                    ]))));
  }
}

class Timer extends StatefulWidget {
  const Timer({super.key});
  @override
  State<Timer> createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  @override
  Widget build(BuildContext context) {
    return const Text(
      "0:40",
      style: TextStyle(
        fontSize: 40,
        color: Colors.white,
      ),
    );
  }
}

class Word extends StatefulWidget {
  String s = " ";
  Color color;
  Word({super.key, required this.s, required this.color});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _WordState(s: s);
}

class _WordState extends State<Word> {
  _WordState({
    required this.s,
  });

  String s = "";
  bool focused = false;
  bool correct = true;

  @override
  Widget build(BuildContext context) {
    return Text(
      s,
      style: TextStyle(
        fontSize: 20,
        color: widget.color,
        decoration: TextDecoration.underline,
      ),
    );
  }
}

class WordBank extends StatefulWidget {
  WordBank({super.key});

  int currentIndex = 0;

  void increaseIndex() {
    currentIndex++;
  }

  @override
  State<StatefulWidget> createState() => _WordBankState();
}

class _WordBankState extends State<WordBank> {
  final WordsController _wordsController = Get.put(WordsController());

  @override
  Widget build(BuildContext context) {
    return Container(
      //  color: Colors.pink,
      width: MediaQuery.of(context).size.width,
      child: (Obx(() => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Wrap(
                  children: [
                    for (int index = 0; index <= 23; index++) ...[
                      Word(
                        s: _wordsController.wordLine1[index],
                        color: _wordsController.index.value == index
                            ? Colors.white
                            : Colors.blue,
                      )
                    ],
                  ],
                ),
              ]))),
    );
  }
}

class InteractionRow extends StatefulWidget {
  InteractionRow({super.key});

  @override
  State<InteractionRow> createState() => _InteractionRowState();
}

class _InteractionRowState extends State<InteractionRow> {
  final textFieldController = TextEditingController();
  final Data _data = Data();
  final WordsController _wordsController = Get.put(WordsController());

  final UserController _userController = Get.put(
      UserController()); // This is user controller it keep the record of results of user and other details of user
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Obx widget listen the runtime changes of the getx controllers
        // in work case _wordController changes will be listen by this obx widget
        //Visibility widget is use when you want to show and hide some widget in
        // particular condition in our case we want to hide the input text field and other element of row when
        // all answers will be given
        Obx(() => Visibility(
              visible: _wordsController.index.value < 24,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: <
                      Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: TextField(
                      onChanged: (text) {
                        if (text[text.length - 1] == " ") {
                          _wordsController.checkWord(text);
                          textFieldController.clear();
                        }
                        if (_wordsController.index.value == 24 &&
                            _userController.isGuest.value == false) {
                          // Test > user_email > results > recordId > time and score
                          // Try keyword handles the runtime exception, if any occur then it will shift the control
                          // to the catch block
                          try {
                            FirebaseFirestore.instance
                                .collection("tests")
                                .doc(_userController.loginUser.value.email)
                                .collection("results")
                                .add({
                              "score": _wordsController.score.value,
                              "time": DateTime.now().toString(),
                            }).whenComplete(() {
                              // when record will inserted then toast will show on screen
                              // with message that result added successfully
                              //Adding the new record to user controller
                              _userController.records.add(ResultRecord(
                                  score: _wordsController.score.value,
                                  time: DateTime.now().toString()));
                              log("Score Card");
                              showDialog<void>(
                                context: context,
                                barrierDismissible:
                                    false, // user must tap button!
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Score Card'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 30.0,
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
                                                //THis line will use to convert String of time into Date and Tme Format and then converting it into 2022-12-28 this format
                                                DateFormat('yyyy-MM-dd').format(
                                                    DateTime.parse(
                                                        _userController.records
                                                            .last.time)),
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Text(
                                                  // Get exact time from Date and Time
                                                  /*DateFormat.Hms().format(DateTime.parse(
                                          _userController.records.last.time)),*/
                                                  "40 sec"),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Text(
                                                      "Correct: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    Text(
                                                      //index hold the values of current element
                                                      _userController
                                                          .records.last.score
                                                          .toString(),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      "Wrong: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    Text(
                                                      //index hold the values of current element
                                                      '${40 - _userController.records.last.score}',
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Text(
                                                      "Key Acc: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    Text(
                                                      //index hold the values of current element
                                                      _data
                                                          .calcKeyAccuracy()
                                                          .toString(),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      "Word Acc: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Text(
                                                      "Percentage: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    Text(
                                                      "${(_userController.records.last.score * 100) ~/ 40}%", //
                                                      style: TextStyle(
                                                          color: ((_userController
                                                                              .records
                                                                              .last
                                                                              .score *
                                                                          100) ~/
                                                                      40) <
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
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 12.0),
                                                  child: Row(
                                                    children: [
                                                      const Text(
                                                        "WPM: ",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Text(
                                                        //"${(_userController.records.elementAt(index).score * 100) ~/ 40}%",
                                                        _data
                                                            .calcWPM(10.0)
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: ((_userController.records.last.score *
                                                                            100) ~/
                                                                        40) <
                                                                    50
                                                                ? Colors.red
                                                                : Colors.green,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Again Test'),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // This line close the pop up
                                          _wordsController.index.value = 0;
                                          _wordsController.score.value = 0;
                                          //Code to open screen MyApp
                                          Get.off(() => const MyApp());
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Past Results'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _wordsController.index.value = 0;
                                          _wordsController.score.value = 0;
                                          //Code to open screen MyApp
                                          Get.off(() => const MyApp());
                                          showGeneralDialog(
                                            context: context,
                                            pageBuilder: (ctx, a1, a2) {
                                              return Menu(context);
                                            },
                                            transitionBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              const begin = Offset(0.0, 1.0);
                                              const end = Offset.zero;
                                              const curve = Curves.ease;

                                              var tween = Tween(
                                                      begin: begin, end: end)
                                                  .chain(
                                                      CurveTween(curve: curve));

                                              return SlideTransition(
                                                position:
                                                    animation.drive(tween),
                                                child: child,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              log("show end Alert Dialog");
                            });
                          } catch (e) {
                            // If any exception occurs in try block then this catch block will execute and
                            //in our case exception will show in red toast
                            Fluttertoast.showToast(
                                msg: e.toString(),
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        }
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Type to begin test"),
                      controller: textFieldController),
                ),
                IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      // reseting state and call the Home page again
                      _wordsController.index.value = 0;
                      _wordsController.score.value = 0;
                      Get.off(() => const MyApp());
                    },
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.white,
                      hoverColor: Colors.white,
                      focusColor: Colors.white,
                      highlightColor: Colors.white,
                    )),
                _userController.isGuest.value == false
                    ? IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          showGeneralDialog(
                            context: context,
                            pageBuilder: (ctx, a1, a2) {
                              return Menu(context);
                            },
                            transitionBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          );
                        },
                      )
                    : const SizedBox(),
              ]),
            )),
        const SizedBox(
          height: 20.0,
        ),
        /* Obx(() => Center(
                child: Visibility(
              visible: _wordsController.index.value == 24,
              child: Text(
                "Score: ${_wordsController.score}/24",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ))),*/

        //When user typed all 24 words and user will not be guest user than score with respective time
        //will be enter to firebase
        /*    Obx(() => Center(
                child: Visibility(
              visible: _wordsController.index.value == 24 &&
                  _userController.isGuest.value == false,
              child: ElevatedButton(
                onPressed: () {
                  // Test > user_email > results > recordId > time and score
                  // Try keyword handles the runtime exception, if any occur then it will shift the control
                  // to the catch block
                  try {
                    FirebaseFirestore.instance
                        .collection("tests")
                        .doc(_userController.loginUser.value.email)
                        .collection("results")
                        .add({
                      "score": _wordsController.score.value,
                      "time": DateTime.now().toString(),
                    }).whenComplete(() {
                      // when record will inserted then toast will show on screen
                      // with message that result added successfully
                      //Adding the new record to user controller
                      _userController.records.add(ResultRecord(
                          score: _wordsController.score.value,
                          time: DateTime.now().toString()));
                      log("Score Card");
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Score Card'),
                            content: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 30.0,
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
                                        //THis line will use to convert String of time into Date and Tme Format and then converting it into 2022-12-28 this format
                                        DateFormat('yyyy-MM-dd').format(
                                            DateTime.parse(_userController
                                                .records.last.time)),
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      Text(
                                          // Get exact time from Date and Time
                                          */ /*DateFormat.Hms().format(DateTime.parse(
                                            _userController.records.last.time)),*/ /*
                                          "40 sec"),
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
                                              _userController.records.last.score
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
                                              '${40 - _userController.records.last.score}',
                                            ),
                                          ],
                                        )
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
                                              _data
                                                  .calcKeyAccuracy()
                                                  .toString(),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
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
                                              "${(_userController.records.last.score * 100) ~/ 40}%", //
                                              style: TextStyle(
                                                  color: ((_userController
                                                                      .records
                                                                      .last
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
                                                _data.calcWPM(10.0).toString(),
                                                style: TextStyle(
                                                    color: ((_userController
                                                                        .records
                                                                        .last
                                                                        .score *
                                                                    100) ~/
                                                                40) <
                                                            50
                                                        ? Colors.red
                                                        : Colors.green,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Again Test'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // This line close the pop up
                                  _wordsController.index.value = 0;
                                  _wordsController.score.value = 0;
                                  //Code to open screen MyApp
                                  Get.off(() => const MyApp());
                                },
                              ),
                              TextButton(
                                child: const Text('Past Results'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _wordsController.index.value = 0;
                                  _wordsController.score.value = 0;
                                  //Code to open screen MyApp
                                  Get.off(() => const MyApp());
                                  showGeneralDialog(
                                    context: context,
                                    pageBuilder: (ctx, a1, a2) {
                                      return Menu(context);
                                    },
                                    transitionBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      const begin = Offset(0.0, 1.0);
                                      const end = Offset.zero;
                                      const curve = Curves.ease;

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));

                                      return SlideTransition(
                                        position: animation.drive(tween),
                                        child: child,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                      log("show end Alert Dialog");
                    });
                  } catch (e) {
                    // If any exception occurs in try block then this catch block will execute and
                    //in our case exception will show in red toast
                    Fluttertoast.showToast(
                        msg: e.toString(),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.00, vertical: 8.0),
                  child: Text("Submit"),
                ),
              ),
            ))),*/
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }
}
