//import 'dart:html';

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'data.dart';
import 'menu.dart';

import 'dart:async';

void main() {
  //print("Testing back end");
  //print(Data.testInt);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
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

  @override
  Widget build(BuildContext context) {
    //double appWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
                padding: const EdgeInsets.all(100),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: CountdownTimer(),
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
                            checkIndex: () {
                              _wordKey.currentState?.moveToNextWord();
                            },
                          ))
                    ]))));
  }
}

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({super.key});
  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? countdownTimer;
  Duration testDuration = Duration(minutes: 1);

  @override
  void initState() {
    super.initState();
  }

  void startTimer() {
    Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  void resetTimer() {
    stopTimer();
    setState(() => testDuration = Duration(days: 5));
  }

  void setCountDown() {
    final reduceSecondsBy = 1;

    setState(() {
      final seconds = testDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
      } else {
        testDuration = Duration(seconds: seconds);
      }
    });
  }

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
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _WordState(s: s);
}

class _WordState extends State<Word> {
  _WordState({
    required this.s,
  });

  void changeWord(String s) {
    setState(() {
      this.s = s;
    });
  }

  void underLine() {
    setState(() {
      wordStyle = TextStyle(
          fontSize: 25,
          color: Colors.white,
          decoration: TextDecoration.underline);
    });
  }

  void removeUnderline() {
    setState(() {
      wordStyle = TextStyle(
        fontSize: 25,
        color: Colors.white,
      );
    });
  }

  String s = "";

  TextStyle wordStyle = TextStyle(
    fontSize: 25,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Text(s, style: wordStyle);
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

  void moveToNextWord() {
    print("activated in word bank");
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
  }

  void selectFirst() {
    _wordKeys[0].currentState?.underLine();
    _wordKeys[11].currentState?.removeUnderline();
  }

  var wordLine1 = Data.fillList();
  var wordLine2 = Data.fillList();

  void refresh() {
    wordLine1 = wordLine2;
    wordLine2 = Data.fillList();

    for (int i = 0; i < _wordKeys.length; i++) {
      _wordKeys[i].currentState?.changeWord(wordLine1[i]);
      _wordKeys2[i].currentState?.changeWord(wordLine2[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    selectFirst();
    return (Column(children: [
      Row(
        children: [
          //Expanded(child: Word(s: wordLine1[0], key: _wordKeys[0])),
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
      Row(
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

class InteractionRow extends StatelessWidget {
  final textFieldController = TextEditingController();

  final VoidCallback checkIndex;

  InteractionRow({super.key, required this.checkIndex});
  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
          child: TextField(
              onChanged: (text) {
                if (text[text.length - 1] == " ") {
                  textFieldController.clear();
                  checkIndex();
                  Data.currentIndex++;
                }
              },
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: "Type to begin test"),
              controller: textFieldController)),
      IconButton(
          iconSize: 40,
          icon: const Icon(Icons.refresh),
          onPressed: () {},
          style: IconButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.white,
            hoverColor: Colors.white,
            focusColor: Colors.white,
            highlightColor: Colors.white,
          )),
      IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          showGeneralDialog(
            context: context,
            pageBuilder: (ctx, a1, a2) {
              return Menu(context);
            },
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
    ]);
  }
}
