import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu(BuildContext context, {super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Center(
          //widthFactor: 1000,
          child: TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text(
          'Close menu',
        ),
      )),
    );
  }
}
