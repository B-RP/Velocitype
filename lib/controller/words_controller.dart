import 'package:get/get.dart';
import 'package:tempo_application/data.dart';

class WordsController extends GetxController {
  RxList wordLine1 = Data.fillList().obs;
  RxInt index = 0.obs;
  RxInt score = 0.obs;

  bool checkWord(String typedWord) {
    bool answer = false;
    if (typedWord != " ") {
      if (typedWord == wordLine1.elementAt(index.value)) {
        score.value++;
        answer = true;
      } else {
        answer = false;
      }
      changeIndex();
    }

    print(answer);
    return answer;
  }

  changeIndex() {
    if (index.value > 23) {
      index.value = 0;
    } else {
      index.value++;
    }
  }
}
