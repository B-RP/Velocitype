import 'package:flutter/material.dart';
import 'data.dart';
import 'menu.dart';

void main() {
  print("Testing back end");
  print(Data.testInt);
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

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //backend code here
  //add responsive padding?

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
                      const Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: Row(children: <Widget>[
                          Expanded(
                              child: TextField(
                                  onChanged: (text) {
                                    if (text[text.length - 1] == " ") {
                                      textFieldController.clear();
                                    }
                                    //print(text);
                                  },
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "Type to begin test"),
                                  controller: textFieldController)),
                          IconButton(
                              iconSize: 40,
                              icon: const Icon(Icons.refresh),
                              onPressed: () {
                                //print("refresh pressed");
                              },
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
                        ]),
                      )
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
