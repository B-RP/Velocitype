import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tempo_application/model/resultRecord.dart';
import 'package:tempo_application/model/userModel.dart';

// CONTROLLING USER INFO
class UserController extends GetxController {
  // To make these variables reactive we are using these data types
  // by using OBX widget we can easily detect the change in these variables
  RxBool isGuest = false
      .obs; // Checking if its a guest user or not // by default it is not of these values will be
  Rx<FUser> loginUser = // If user is logged in, information of user
      FUser(name: "", uid: "", email: "", profileImage: "")
          .obs; // Calling FUser function in userModel
  RxList<ResultRecord> records = // Holds all the records - past results
      <ResultRecord>[].obs; // Contain all the list of results
// use to set new user
  setUser(User user) {
    // Setting the user in the program
    loginUser.value = FUser(
        // Passing to FUser in user model
        name: user.displayName ?? "",
        uid: user.uid ?? "",
        email: user.email ?? "",
        profileImage: user.photoURL ?? "");
  }
}
