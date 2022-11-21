import 'package:flutter/material.dart';
import 'data.dart';

class Menu extends StatefulWidget {
  const Menu(BuildContext context, {super.key});

  @override
  State<StatefulWidget> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Builder(
        builder: (context) {
          //get available height and width of the build area of the widget
          var height = MediaQuery.of(context).size.height;
          var width = MediaQuery.of(context).size.width;

          return SizedBox(
              height: height - 150,
              width: width - 150,
              child: Column(children: [
                Row(children: [
                  const Spacer(),
                  IconButton(
                      icon: const Icon(
                        Icons.minimize_rounded,
                        color: Color.fromARGB(255, 99, 96, 96),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Data.newTest();
                      }),
                ]),
                Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      Text(
                        "${Data.totalWords} WPM",
                        style: const TextStyle(
                          fontSize: 80,
                          color: Color.fromARGB(255, 31, 38, 169),
                        ),
                      ),
                      //Text(
                      //  "Top 15%",
                      //  style: TextStyle(
                      //    fontSize: 30,
                      //    color: Color.fromARGB(255, 31, 38, 169),
                      //  ),
                      //),
                      Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(children: [
                            Text(
                              "Keystrokes    (${Data.totalKeys - Data.totalIncKeys} | ${Data.totalIncKeys}) ${Data.totalKeys}",
                              style: const TextStyle(
                                fontSize: 35,
                                color: Color.fromARGB(255, 58, 58, 61),
                              ),
                            ),
                            Text(
                              "Accuracy       ${Data.wordAccuracy.toStringAsFixed(2)}%",
                              style: const TextStyle(
                                fontSize: 35,
                                color: Color.fromARGB(255, 58, 58, 61),
                              ),
                            ),
                            Text(
                              "Correct words      ${Data.totalWords - Data.totalIncWords}",
                              style: const TextStyle(
                                fontSize: 35,
                                color: Color.fromARGB(255, 58, 58, 61),
                              ),
                            ),
                            Text(
                              "Wrong words        ${Data.totalIncWords}",
                              style: const TextStyle(
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
