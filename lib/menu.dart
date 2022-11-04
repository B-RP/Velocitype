import 'package:flutter/material.dart';

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
