import 'package:get/get.dart';
import 'package:tempo_application/data.dart';

class WordsController extends GetxController {
  // Controls the random words, inherits GetxControler class (built in class of Get library)
  RxList wordLine1 =
      Data.fillList().obs; // List of strings 24 words(12 each line)
  RxInt index = 0.obs; // index of word user is currently filling
  RxInt score = 0.obs; // score of correctly spelled words

  bool checkWord(String typedWord) {
    // checkWord() function with string argument for user entry
    bool answer = false;
    if (typedWord != " ") {
      // If the user enters space on accident it won't check word, they can go back
      if (typedWord == wordLine1.elementAt(index.value)) {
        // If the typed word equals the word given
        score.value++; // Score increases
        answer = true;
      } else {
        answer = false;
      }
      changeIndex();
    }

    print(answer);
    return answer;
  }

// Changing index function
  changeIndex() {
    if (index.value > 23) {
      index.value = 0;
    } else {
      index.value++;
    }
  }
}
