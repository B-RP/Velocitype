//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'checkWords.dart';
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
    return GetMaterialApp(
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
        resizeToAvoidBottomInset:
            false, // Added - When we open the keyboard for typing this line will help us to not distort the UI
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
  Color
      color; // This color handles the color of text showing on the screen, all text will show in blue color and the word which we have to spell will show in white color
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
        color: widget.color, // changed
        decoration: TextDecoration.underline,
      ),
    );
  }
}

class WordBank extends StatefulWidget {
  WordBank({super.key});

  int currentIndex =
      0; // This the the index of the word which we are currently answering

  // When we type the spelling and add space then the current index will increment one and then next word will select
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
      width: MediaQuery.of(context)
          .size
          .width, // I placed a container widget which occupies the width as the screen width, MediaQuery will give us total width of screen
      child:
          // We wrap the Column widget with Obx(), which means when value of _wordController changes this Obx widget receives that change and will show the change on the screen with calling setState function
          (Obx(() => Column(
                  // Column Widget arrange the widgets column wise
                  mainAxisAlignment: MainAxisAlignment
                      .start, // Main Axis Alignment.start means the column will start arranging the widget from start of column
                  mainAxisSize:
                      MainAxisSize.max, // Column will occupy the maximum space
                  children: [
                    // Wrap widget arranges the widgets row wise if number of widgets increases from line it will move the next widget to next line
                    Wrap(
                      children: [
                        // In the previous code, it was passing the words one by one seprately, to simplify, I used for loop it will call 24 times and show the 24 elements on screen in two lines indexs will start from 0 and end on 23
                        for (int index = 0; index <= 23; index++) ...[
                          // Widget that returns the words at index[x]
                          Word(
                            s: _wordsController.wordLine1[
                                index], // Thia means list of words with index will pass as a parameter

                            // if word of current index is the word which we have to answer then that color would be white and color of other words will be blue
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

class InteractionRow extends StatelessWidget {
  final textFieldController = TextEditingController();
  final WordsController _wordsController = Get.put(WordsController()); // added

  InteractionRow({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      // changed
      children: [
        Row(children: <Widget>[
          Expanded(
              child: TextField(
                  onChanged: (text) {
                    // When user enters space after typing the word then index will increment one and control will shift to next word
                    if (text[text.length - 1] == " ") {
                      _wordsController.checkWord(text);
                      // Text field will be empty then
                      textFieldController.clear();
                    }
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Type to begin test"),
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
                transitionBuilder:
                    (context, animation, secondaryAnimation, child) {
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
        ]), // Added for word score keeping
        const SizedBox(
          height: 20.0,
        ),
        Obx(() => Center(
                child: Text(
              "Score: ${_wordsController.score}/24", // Score total
              style: TextStyle(color: Colors.white, fontSize: 24),
            ))),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }
}
