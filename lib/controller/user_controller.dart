import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tempo_application/model/result_record.dart';
import 'package:tempo_application/model/user_model.dart';

class UserController extends GetxController {
  RxBool isGuest = false.obs;
  Rx<FUser> loginUser =
      FUser(name: "", uid: "", email: "", profileImage: "", backgroundImage: "")
          .obs;
  RxList<ResultRecord> records =
      <ResultRecord>[].obs; // Contains all the list of results

// Set new user
  setUser(User user) {
    loginUser.value = FUser(
      name: user.displayName ?? "",
      uid: user.uid ?? "",
      email: user.email ?? "",
      profileImage: user.photoURL ?? "", backgroundImage: '',
      //     backgroundImage: user.backgroundImage ?? "",
    );
  }
}
