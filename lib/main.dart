//import 'dart:html';

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tempo_application/controller/user_controller.dart';
import 'package:tempo_application/controller/words_controller.dart';
import 'package:tempo_application/model/result_record.dart';
import 'package:tempo_application/views/add_background_image.dart';
import 'package:tempo_application/views/add_profile_pic.dart';
import 'package:tempo_application/views/login.dart';
import 'package:tempo_application/views/splash_screen.dart';
import 'data.dart';
import 'menu.dart';

Future<void> main() async {
  // These two lines are used to initialize the Firebase database when app starts
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,

    options: const FirebaseOptions(
        apiKey: "AIzaSyBeDZzmHDrp8nmTrWNjHX8vBoVQUmd3xhA",
        authDomain: "velocitype-c4e92.firebaseapp.com",
        projectId: "velocitype-c4e92",
        storageBucket: "velocitype-c4e92.appspot.com",
        messagingSenderId: "677022620040",
        appId: "1:677022620040:web:cc16de75779019731f823d",
        measurementId: "G-QBZYVGCFTZ"),
  );
  runApp(GetMaterialApp(home: SplashScreen()));
}

// This MyApp screen is actually home page when user login then this screen opens
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This _wordController is an instance of Words Controller
  // it keep the record of words and current word index and number of right words
  final WordsController _wordsController = Get.put(WordsController());

  // When this screen opens the first function which will call is the initState function,'
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
        title: 'Velocitype',
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
  final GlobalKey<_WordBankState> _wordKey = GlobalKey();
  final GlobalKey<_CountdownTimerState> _timerKey = GlobalKey();
  final GlobalKey<_InteractionRowState> _InterRowKey = GlobalKey();
  final WordsController _wordsController = Get.put(WordsController());
  final UserController _userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(() => Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), BlendMode.darken),
              image: (_userController.isGuest.value == true)
                  ? AssetImage("assets/images/background.png")
                      as ImageProvider<Object>
                  : (_userController.loginUser.value.backgroundImage == "")
                      ? AssetImage("assets/images/background.png")
                          as ImageProvider<Object>
                      : NetworkImage(
                          _userController.loginUser.value.backgroundImage,
                        ) as ImageProvider<Object>,
            )),
            child: Padding(
                padding: const EdgeInsets.all(100),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: CountdownTimer(
                          key: _timerKey,
                          //TEST FINISHED
                          timerFinished: () {
                            //Data.calcWordAccuracy();
                            Data.timerActive = false;
                            _wordsController.testBegin.value = false;
                            _InterRowKey.currentState?.showMenu();
                            _wordKey.currentState?.refresh();
                            _timerKey.currentState?.resetTimer();
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: WordBank(
                          key: _wordKey,
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                          child: InteractionRow(
                              key: _InterRowKey,
                              refreshTest: () {
                                Data.newTest();
                                Data.timerActive = false;
                                _wordsController.index.value;
                                _wordKey.currentState?.refresh();
                                _timerKey.currentState?.resetTimer();
                              },
                              checkIndex: () {
                                _wordKey.currentState?.moveToNextWord();
                              },
                              startTimer: () {
                                _timerKey.currentState?.startTimer();
                              },
                              checkWord: () {
                                log('Check Word');
                                if (Data.checkWord(
                                    Data.inputTyped, Data.targetWord)) {
                                  log("Change word Color");
                                  _wordKey.currentState?.changeColor("g");
                                } else {
                                  _wordKey.currentState?.changeColor("r");
                                }
                              },
                              checkFullWord: () {
                                log('Check Full Word');
                                if (Data.checkFullWord(
                                    Data.inputTyped, Data.targetWord)) {
                                  _wordKey.currentState?.changeColor("g");
                                } else {
                                  _wordKey.currentState?.changeColor("r");
                                }
                              }))
                    ])))));
  }
}

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({super.key, required this.timerFinished});

  final VoidCallback timerFinished;
  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? countdownTimer;
  Duration testDuration = const Duration(minutes: 1);
  final WordsController _wordController = Get.put(WordsController());

  @override
  void initState() {
    super.initState();
  }

  void startTimer() {
    _wordController.testBegin.value = true;
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    _wordController.testBegin.value = false;
    setState(() => countdownTimer!.cancel());
  }

  void resetTimer() {
    stopTimer();
    setState(() => testDuration = const Duration(minutes: 1));
  }

  void setCountDown() {
    const reduceSecondsBy = 1;

    setState(() {
      final seconds = testDuration.inSeconds - reduceSecondsBy;

      if (seconds < 0) {
        countdownTimer?.cancel();
        widget.timerFinished();
      } else {
        testDuration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(testDuration.inMinutes.remainder(60));
    final seconds = strDigits(testDuration.inSeconds.remainder(60));

    return Text(
      '$minutes:$seconds',
      style: TextStyle(
        fontSize: 40,
        color: Colors.white,
      ),
    );
  }
}

class Word extends StatefulWidget {
  String s = " ";
  Word({super.key, required this.s});

  @override
  State<StatefulWidget> createState() => _WordState(s: s);
}

class _WordState extends State<Word> {
  _WordState({
    required this.s,
  });

  Color c = Colors.white;

  void changeWord(String s) {
    setState(() {
      this.s = s;
    });
  }

  void underLine() {
    setState(() {
      wordStyle = TextStyle(fontSize: 25, color: c);
    });
  }

  void removeUnderline() {
    setState(() {
      wordStyle = TextStyle(
        fontSize: 25,
        color: c,
      );
    });
  }

  //parameter color will receive only "g" for green "r" for red and "w" for white
  void setColor(String color) {
    if (color == "g") {
      c = Colors.green;
    } else if (color == "r") {
      c = Colors.red;
    } else if (color == "w") {
      c = Colors.white;
    }

    setState(() {
      wordStyle = TextStyle(
        fontSize: 25,
        color: c,
      );
    });
  }

  String s = "";

  TextStyle wordStyle = const TextStyle(
    fontSize: 25,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Text(
      s,
      style: wordStyle,
      maxLines: 1,
    );
  }
}

class WordBank extends StatefulWidget {
  const WordBank({super.key});

  @override
  State<StatefulWidget> createState() => _WordBankState();
}

class _WordBankState extends State<WordBank> {
  final List<GlobalKey<_WordState>> _wordKeys = [
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
  ];

  final List<GlobalKey<_WordState>> _wordKeys2 = [
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
    GlobalKey<_WordState>(),
  ];

  int currentWord = 0;
  var wordLine1 = Data.fillList();
  var wordLine2 = Data.fillList();

  void moveToNextWord() {
    _wordKeys[currentWord].currentState?.removeUnderline();
    if (currentWord < 11) {
      _wordKeys[currentWord + 1].currentState?.underLine();
    }

    if (currentWord == 11) {
      currentWord = 0;
      selectFirst();
      refresh();
    } else {
      currentWord++;
    }

    Data.targetWord = wordLine1[currentWord];
  }

  void selectFirst() {
    _wordKeys[0].currentState?.underLine();
    _wordKeys[11].currentState?.removeUnderline();
  }

  void refresh() {
    currentWord = 0;
    wordLine1 = wordLine2;
    wordLine2 = Data.fillList();

    for (int i = 0; i < _wordKeys.length; i++) {
      _wordKeys[i].currentState?.changeWord(wordLine1[i]);
      _wordKeys2[i].currentState?.changeWord(wordLine2[i]);
    }

    for (int i = 0; i < _wordKeys.length; i++) {
      _wordKeys[i].currentState?.setColor("w");
    }

    Data.targetWord = wordLine1[0];
  }

  void changeColor(String color) {
    _wordKeys[currentWord].currentState?.setColor(color);
  }

  @override
  Widget build(BuildContext context) {
    Data.targetWord = wordLine1[0];
    return (Column(children: [
      Wrap(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Word(s: wordLine1[0], key: _wordKeys[0]),
          Word(s: wordLine1[1], key: _wordKeys[1]),
          Word(s: wordLine1[2], key: _wordKeys[2]),
          Word(s: wordLine1[3], key: _wordKeys[3]),
          Word(s: wordLine1[4], key: _wordKeys[4]),
          Word(s: wordLine1[5], key: _wordKeys[5]),
          Word(s: wordLine1[6], key: _wordKeys[6]),
          Word(s: wordLine1[7], key: _wordKeys[7]),
          Word(s: wordLine1[8], key: _wordKeys[8]),
          Word(s: wordLine1[9], key: _wordKeys[9]),
          Word(s: wordLine1[10], key: _wordKeys[10]),
          Word(s: wordLine1[11], key: _wordKeys[11])
        ],
      ),
      Wrap(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Word(s: wordLine2[0], key: _wordKeys2[0]),
          Word(s: wordLine2[1], key: _wordKeys2[1]),
          Word(s: wordLine2[2], key: _wordKeys2[2]),
          Word(s: wordLine2[3], key: _wordKeys2[3]),
          Word(s: wordLine2[4], key: _wordKeys2[4]),
          Word(s: wordLine2[5], key: _wordKeys2[5]),
          Word(s: wordLine2[6], key: _wordKeys2[6]),
          Word(s: wordLine2[7], key: _wordKeys2[7]),
          Word(s: wordLine2[8], key: _wordKeys2[8]),
          Word(s: wordLine2[9], key: _wordKeys2[9]),
          Word(s: wordLine2[10], key: _wordKeys2[10]),
          Word(s: wordLine2[11], key: _wordKeys2[11])
        ],
      )
    ]));
  }
}

class InteractionRow extends StatefulWidget {
  const InteractionRow(
      {super.key,
      required this.checkIndex,
      required this.checkWord,
      required this.startTimer,
      required this.checkFullWord,
      required this.refreshTest});

  final VoidCallback checkIndex;
  final VoidCallback checkWord;
  final VoidCallback startTimer;
  final VoidCallback checkFullWord;
  final VoidCallback refreshTest;

  @override
  State<InteractionRow> createState() => _InteractionRowState();
}

class _InteractionRowState extends State<InteractionRow> {
  final textFieldController = TextEditingController();
  //final Data _data = Data();

  //not using wordsController in the final version of the project
  final WordsController _wordsController = Get.put(WordsController());

  final UserController _userController = Get.put(
      UserController()); // This is user controller it keep the record of results of user and other details of user

  //this function is called when the timer ends and the test is finished
  void showMenu() {
    // double wordAccuracy =
    //     double.parse(_userController.records.last.wordAccuracy);

    try {
      if ((_userController.isGuest.value == false)) {
        FirebaseFirestore.instance
            .collection("tests")
            .doc(_userController.loginUser.value.email)
            .collection("results")
            .add({
          "score": Data.totalWords.toString(),
          "time": DateTime.now().toString(),
          "keyStrokes": Data.calcKeyAccuracy().toString(),
          "wordAccuracy": Data.calcWordAccuracy().toString(),
          "accuracy": (((Data.totalWords - Data.totalIncWords) * 100) ~/
                  Data.totalWords)
              .toString(),
          "wpm": Data.totalWords.toString(),
          "correctWords": (Data.totalWords - Data.totalIncWords).toString(),
          "wrongWords": Data.totalIncWords.toString(),
        }).whenComplete(() {
          // When record will inserted then toast will show on screen,
          // with message that result added successfully
          // Adding the new record to user controller
          _userController.records.add(ResultRecord(
            score: Data.totalWords.toString(),
            time: DateTime.now().toString(),
            keyStrokes: Data.calcKeyAccuracy().toString(),
            wordAccuracy: Data.calcWordAccuracy().toString(),
            accuracy: (((Data.totalWords - Data.totalIncWords) * 100) ~/
                    Data.totalWords)
                .toString(),
            wpm: Data.totalWords.toString(),
            correctWords: (Data.totalWords - Data.totalIncWords).toString(),
            wrongWords: Data.totalIncWords.toString(),
          ));
          log("Score Card");
          showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                content: SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  /*  height:
                                          MediaQuery.of(context).size.height,*/
                  child: SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width * .40,
                      child: Column(
                        children: [
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(
                          //       vertical: 8.0, horizontal: 8.0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //      Container(),
                          //       Center(
                          //         child: Text(
                          //           'RESULTS'.toUpperCase(),
                          //           style: GoogleFonts.poppins(
                          //               color: const Color(0xff2F00F9), fontSize: 28),
                          //         ),
                          //       ),
                          //       GestureDetector(
                          //           onTap: () {
                          //             Navigator.of(context).pop();
                          //             Get.back(); // This line close the pop up
                          //           },
                          //           child: Icon(
                          //             Icons.close,
                          //             size: 35,
                          //             color: Colors.grey,
                          //           ))
                          //     ],
                          //   ),
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Get.back(); // This line close the pop up
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 35,
                                    color: Colors.grey,
                                  ))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  'RESULT'.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xff2F00F9),
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 50.0),
                            child: Card(
                              //Card with circular border
                              color: Color(0xFFD9DDE0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10.0),
                                      child: Center(
                                          child: Text(
                                        '${Data.totalWords.toString()} WPM',
                                        style: GoogleFonts.poppins(
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
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 40.0,
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Date".toUpperCase(),
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      //THis line will use to convert String of time into Date and Tme Format and then converting it into 2022-12-28 this format
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(DateTime.parse(
                                                              _userController
                                                                  .records
                                                                  .last
                                                                  .time)),
                                                    ),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                    Text(
                                                      //index hold the values of current element
                                                      _userController.records
                                                          .last.keyStrokes,
                                                    ),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                    Text(
                                                      "${_userController.records.last.accuracy}%",
                                                      style: TextStyle(
                                                          color: ((int.parse(
                                                                      _userController
                                                                          .records
                                                                          .last
                                                                          .accuracy)) <
                                                                  50
                                                              ? Colors.red
                                                              : Colors.green),
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                    Text(
                                                      //index hold the values of current element
                                                      _userController.records
                                                          .last.correctWords
                                                          .toString(),
                                                    ),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                        Expanded(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                      "Word Acc: "
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "60 sec",
                                                    ),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                    Text(
                                                        //index hold the values of current element
                                                        /*wordAccuracy
                                                          .toStringAsFixed(2)
                                                          .toString(),*/
                                                        _userController.records
                                                            .last.wordAccuracy),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                    Text(
                                                      //"${(_userController.records.last.score * 100) ~/ 40}%",
                                                      _userController
                                                          .records.last.wpm,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                    Text(
                                                      //index hold the values of current element
                                                      _userController.records
                                                          .last.wrongWords,
                                                    ),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                        SizedBox(
                                          width: 40.0,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: <Widget>[
                  _userController.isGuest.value == false
                      ? Center(
                          child: InkWell(
                            onTap: () async {
                              Navigator.of(context)
                                  .pop(); // This line close the pop up
                              _wordsController.index.value = 0;
                              _wordsController.score.value = 0;

                              //widget.
                              //Code to open screen MyApp
                              // Get.off(() => const MyApp()); // breaks for whatever reason
                            },
                            child: Container(
                              width: 320,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: const Color(0xff2F00F9),
                                  borderRadius: BorderRadius.circular(10.r)),
                              // padding: EdgeInsets.symmetric(
                              //   vertical: 10.h,
                              // ),
                              child: Text(
                                'Take test again'.toUpperCase(),
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 5.sp),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  (_userController.isGuest.value == false)
                      ? Container()
                      : const SizedBox(),
                ],
              );
            },
          );
          log("show end Alert Dialog");
        });
      } else {
        {
          // when record will inserted then toast will show on screen
          // with message that result added successfully
          //Adding the new record to user controller
          _userController.records.add(ResultRecord(
            score: Data.totalWords.toString(),
            time: DateTime.now().toString(),
            keyStrokes: Data.calcKeyAccuracy().toStringAsFixed(2),
            wordAccuracy: Data.calcWordAccuracy().toStringAsFixed(2),
            accuracy: (((Data.totalWords - Data.totalIncWords) * 100) ~/
                    Data.totalWords)
                .toString(),
            wpm: Data.totalWords.toString(),
            correctWords: (Data.totalWords - Data.totalIncWords).toString(),
            wrongWords: Data.totalIncWords.toString(),
          ));
          log("Score Card");
          showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                content: SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  /*  height:
                                          MediaQuery.of(context).size.height,*/
                  child: SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width * .40,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: Row(
                              children: [
                                const Spacer(),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      Get.back(); // This line close the pop up
                                      _wordsController.index.value = 0;
                                      _wordsController.score.value = 0;
                                      //Code to open screen MyApp
                                      Get.off(() => const MyApp());
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 35,
                                      color: Colors.grey,
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 50.0),
                            child: Card(
                              //Card with circular border
                              color: Color(0xFFD9DDE0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: Center(
                                          child: Text(
                                        "${_userController.records.last.wpm} WPM",
                                        style: GoogleFonts.poppins(
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
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 40.0,
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
                                                      CrossAxisAlignment.start,
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      //THis line will use to convert String of time into Date and Tme Format and then converting it into 2022-12-28 this format
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(DateTime.parse(
                                                              _userController
                                                                  .records
                                                                  .last
                                                                  .time)),
                                                    ),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                    Text(
                                                      //index hold the values of current element
                                                      _userController.records
                                                          .last.keyStrokes,
                                                    ),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                    Text(
                                                      "${_userController.records.last.accuracy}%",
                                                      style: TextStyle(
                                                          color: ((int.parse(
                                                                      _userController
                                                                          .records
                                                                          .last
                                                                          .accuracy)) <
                                                                  50
                                                              ? Colors.red
                                                              : Colors.green),
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                    Text(
                                                      //index hold the values of current element
                                                      _userController.records
                                                          .last.correctWords
                                                          .toString(),
                                                    ),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                        Expanded(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                      "Word Acc: "
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "60 sec",
                                                    ),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                    Text(
                                                        //index hold the values of current element
                                                        _userController.records
                                                            .last.wordAccuracy),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                    Text(
                                                      //"${(_userController.records.last.score * 100) ~/ 40}%",
                                                      _userController
                                                          .records.last.wpm,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                    Text(
                                                      //index hold the values of current element
                                                      _userController.records
                                                          .last.wrongWords,
                                                    ),
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: <Widget>[
                  _userController.isGuest.value == false
                      ? TextButton(
                          child: Text(
                            'Take test again'.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff2F00F9)),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pop(); // This line close the pop up
                            _wordsController.index.value = 0;
                            _wordsController.score.value = 0;
                            //Code to open screen MyApp
                            Get.off(() => const MyApp());
                          },
                        )
                      : const SizedBox(),
                  (_userController.isGuest.value == false)
                      ? TextButton(
                          child: Text(
                            'Show past results'.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff2F00F9)),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _wordsController.index.value = 0;
                            _wordsController.score.value = 0;
                            //Code to open screen MyApp
                            Get.off(() => const MyApp());
                            showGeneralDialog(
                              context: context,
                              pageBuilder: (ctx, a1, a2) {
                                return Menu(/*context*/);
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
                ],
              );
            },
          );
          log("show end Alert Dialog");
        }
      }
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // USING OBX WIDGET
        // Which gets the runtime changes of the GetX controllers
        // In this case,OBX widget will get _wordController changes
        // USING VISIBILITY WIDGET
        // Which shows and hides some widget in particular
        // In this case, the input text field and other element of row when all answers are given

        Obx(() => SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Wrap(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: TextField(
                          onChanged: (text) {
                            if (text != "") {
                              //when space is pressed
                              if (text[text.length - 1] == " ") {
                                Data.inputTyped = text;
                                widget.checkFullWord();

                                textFieldController.clear();
                                widget.checkIndex();
                                Data.currentIndex++;
                                _wordsController.index.value++;
                              }

                              //if anything other than space is inputed, check spelling so far
                              else {
                                Data.inputTyped = text;
                                widget.checkWord();
                              }
                            }

                            //start timer whenever the user begins to type
                            if (Data.timerActive) {
                            } else {
                              widget.startTimer();
                              Data.timerActive = true;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              disabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              hintStyle: const TextStyle(color: Colors.grey),
                              hintText:
                                  _wordsController.testBegin.value == false
                                      ? "Type to begin test"
                                      : "Type next word"),
                          controller: textFieldController),
                    ),
                    IconButton(
                        iconSize: 40,
                        icon: const Icon(Icons.refresh, color: Colors.grey),
                        onPressed: () {
                          // reseting state and call the Home page again
                          //_wordsController.index.value = 0;
                          //_wordsController.score.value = 0;
                          widget.refreshTest();
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
                    _userController.isGuest.value == true
                        ? IconButton(
                            iconSize: 40,
                            icon: const Icon(
                              Icons.login,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              // reseting state and call the Home page again
                              _wordsController.index.value = 0;
                              _wordsController.score.value = 0;
                              Get.offAll(() => const LoginScreen());
                            },
                            style: IconButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.transparent,
                              disabledBackgroundColor: Colors.white,
                              hoverColor: Colors.white,
                              focusColor: Colors.white,
                              highlightColor: Colors.white,
                            ))
                        : const SizedBox(),
                    _userController.isGuest.value == false
                        ? IconButton(
                            iconSize: 40,
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              showGeneralDialog(
                                context: context,
                                pageBuilder: (ctx, a1, a2) {
                                  return Menu(/*context*/);
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
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }
}
