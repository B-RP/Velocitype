import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tempo_application/model/result_record.dart';
import 'package:tempo_application/model/user_model.dart';

class UserController extends GetxController {
  RxBool isGuest = false.obs;
  Rx<FUser> loginUser =
      FUser(name: "", uid: "", email: "", profileImage: "").obs;
  RxList<ResultRecord> records =
      <ResultRecord>[].obs; // Contain all the list of results
// use to set new user
  setUser(User user) {
    loginUser.value = FUser(
        name: user.displayName ?? "",
        uid: user.uid ?? "",
        email: user.email ?? "",
        profileImage: user.photoURL ?? "");
  }
}
