import 'package:english_words/english_words.dart';
import 'dart:math';

class Data {
  static int testInt = 0;
  int totalWords = 0;
  int totalIncWords = 0;
  int totalKeys = 0;
  int totalIncKeys = 0;

  Data.fillList() {
    var rng = Random();
    var nounList = nouns.toList(growable: false);
    var wordList = new List.filled(12, "");
    for (int i = 0; i <= 11; i++) {
      wordList[i] = nouns.elementAt(rng.nextInt(nounList.length));
      print(wordList[i]);
    }
  }
}
