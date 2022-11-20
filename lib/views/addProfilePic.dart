import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tempo_application/controller/userControl.dart';
import 'package:tempo_application/model/userModel.dart';
import 'package:tempo_application/main.dart';
import '../widget/toast.dart';

// USER TO ADD A PROFILE PICTURE
class AddProfilePic extends StatefulWidget {
  const AddProfilePic({Key? key}) : super(key: key);

  @override
  _AddProfilePicState createState() => _AddProfilePicState();
}

class _AddProfilePicState extends State<AddProfilePic> {
  final UserController _userController = Get.put(UserController());
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) => SafeArea(
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).padding.top,
                    ),
                    SizedBox(
                      height: 72.h,
                    ),
                    Text(
                      'You\'re all set!',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 22.h,
                    ),
                    SizedBox(
                      height: 149.h,
                      child: photo != ""
                          ? Container(
                              // height: 70,width: 70,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      photo,
                                    ),
                                    fit: BoxFit.fill,
                                  )),
                            )
                          : Container(
                              //  height: 70,width: 70,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/images/profileimg.png',
                                    ),
                                    fit: BoxFit.fitHeight,
                                  )),
                            ),
                    ),
                    SizedBox(
                      height: 46.h,
                    ),
                    Text(
                      // CUSTOMIZED WELCOME MESSAGES FOR USER
                      'Welcome ${_userController.loginUser.value.name}!',
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      // ADD PROFILE PICTURE
                      'Take a minute to add a profile picture',
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w200),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    InkWell(
                      // UPLOAD THEIR OWN IMAGE OR TAKE A PICTURE
                      onTap: () {
                        //  CapturePhoto.pickImg(context);
                        if (photo == '') {
                          selectImage();
                        } else {
                          _userController.isGuest.value = false;
                          Get.offAll(
                              () => const MyApp()); // GOES BACK TO HOMESCREEN
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 40.h,
                        width: 180.w,
                        decoration: BoxDecoration(
                            color: Color(0xff00B3BB),
                            borderRadius: BorderRadius.circular(50)),
                        child: Text(
                          photo == "" ? 'Add a photo' : 'Next',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp),
                        ),
                      ),
                    )
                  ],
                ),
                if (uploadingImage) CircularProgressIndicator()
              ],
            ),
          ),
        ),
      ),
    );
  }

  selectImage() {
    return showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20), topLeft: Radius.circular(20))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Select an option',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                onTap: () {
                  getImage(ImageSource.camera);
                },
                leading: const Icon(
                  Icons.camera_alt,
                  color: Color(0xffE98445),
                ),
                title: const Text('Capture a photo from camera'),
              ),
              ListTile(
                onTap: () {
                  getImage(ImageSource.gallery);
                },
                leading: const Icon(
                  Icons.collections,
                  color: Color(0xffE98445),
                ),
                title: const Text('Choose a photo from gallery'),
              )
            ],
          ),
        );
      },
    );
  }

// Open image picker
// GETTING IMAGE FROM CAMERA
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool uploadingImage = false;
  String photo = '';
  Future getImage(
    ImageSource imgSource,
  ) async {
    XFile? pickedFile = await _picker.pickImage(
      source: imgSource,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      uploadingImage = true;
      // Upload image to Firebase storage and get the online link and store that link to the cloud firestore
      Reference userStorageReference = FirebaseStorage.instance
          .ref()
          .child("users")
          .child(DateTime.now().millisecondsSinceEpoch.toString());
      UploadTask snap = userStorageReference.putFile(_image!);
      snap.whenComplete(() async {
        photo = await snap.snapshot.ref.getDownloadURL();
        FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          "photo": photo, // ASSIGNING PHOTO TO USER PHOTO
        }, SetOptions(merge: true)).whenComplete(() {
          FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get()
              .then((value) {
            FUser fUser = FUser.fromJson(value.data()!);
            _userController.loginUser.value = fUser;
          });
        });
        setState(() {
          uploadingImage = false;
        });
        showToast("Image Uploaded Successfully");
      });
    }
  }
}
