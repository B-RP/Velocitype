//import 'dart:html';

import 'package:flutter/material.dart';
import 'data.dart';
import 'menu.dart';

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
  @override
  Widget build(BuildContext context) {
    //double appWidth = MediaQuery.of(context).size.width;
    final textFieldController = TextEditingController();
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
  Word({super.key, required this.s});

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
        color: Colors.white,
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
  var wordLine1 = Data.fillList();
  var wordLine2 = Data.fillList();
  @override
  Widget build(BuildContext context) {
    return (Column(children: [
      Row(
        children: [
          Word(
            s: wordLine1[0],
          ),
          Word(
            s: wordLine1[1],
          ),
          Word(
            s: wordLine1[2],
          ),
          Word(
            s: wordLine1[3],
          ),
          Word(
            s: wordLine1[4],
          ),
          Word(
            s: wordLine1[5],
          ),
          Word(
            s: wordLine1[6],
          ),
          Word(
            s: wordLine1[7],
          ),
          Word(
            s: wordLine1[8],
          ),
          Word(
            s: wordLine1[9],
          ),
          Word(
            s: wordLine1[10],
          ),
          Word(
            s: wordLine1[11],
          )
        ],
      ),
      Row(
        children: [
          Word(
            s: wordLine2[0],
          ),
          Word(
            s: wordLine2[1],
          ),
          Word(
            s: wordLine2[2],
          ),
          Word(
            s: wordLine2[3],
          ),
          Word(
            s: wordLine2[4],
          ),
          Word(
            s: wordLine2[5],
          ),
          Word(
            s: wordLine2[6],
          ),
          Word(
            s: wordLine2[7],
          ),
          Word(
            s: wordLine2[8],
          ),
          Word(
            s: wordLine2[9],
          ),
          Word(
            s: wordLine2[10],
          ),
          Word(
            s: wordLine2[11],
          )
        ],
      )
    ]));
  }
}

class InteractionRow extends StatelessWidget {
  final textFieldController = TextEditingController();

  InteractionRow({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
          child: TextField(
              onChanged: (text) {
                if (text[text.length - 1] == " ") {
                  textFieldController.clear();
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
