import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tempo_application/controller/user_controller.dart';
import 'package:tempo_application/main.dart';
import 'package:tempo_application/views/add_background_image.dart';
import 'package:tempo_application/views/edit_background_picture.dart';

import '../model/user_model.dart';
import '../widget/toast.dart';
import 'edit_profile_picture.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final UserController _userController = Get.put(UserController());
  final TextEditingController _name = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) => SafeArea(
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    height: 300,
                    width: 300,
                    child: Image.asset(
                      'assets/images/new.PNG',
                    )),
                /*Text(
                  'Edit Profile Picture or Background Picture'.toUpperCase(),
                  style: GoogleFonts.poppins(fontSize: 24),
                ),*/
                SizedBox(
                  height: 40.h,
                ),
                InkWell(
                  onTap: () {
                    Get.to(() => const EditProfilePic());
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 40.h,
                    width: MediaQuery.of(context).size.width * .35,
                    decoration: BoxDecoration(
                        color: Color(0xff2F00F9),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      'Edit Profile Picture'.toUpperCase(),
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 4.sp),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                InkWell(
                  onTap: () {
                    Get.to(() => const EditBackgroundImage());
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 40.h,
                    width: MediaQuery.of(context).size.width * .35,
                    decoration: BoxDecoration(
                        color: Color(0xff2F00F9),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      'Edit Background Picture'.toUpperCase(),
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 4.sp),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
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
                  Get.back();
                },
                leading: const Icon(
                  Icons.camera_alt,
                  color: Color(0xffE98445),
                ),
                title: const Text('Capture a photo from camera'),
              ),
              ListTile(
                onTap: () {
                  getImage(ImageSource.camera);
                  Get.back();
                  //  getImage(ImageSource.gallery);
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
  //Open image picker

  final ImagePicker _picker = ImagePicker();
  Uint8List? _image;
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
      print(pickedFile.path);
      _image = await pickedFile.readAsBytes();
      setState(() {});

      uploadingImage = true;
      // Upload image to Firebase storage and get the online link and store that link to the Cloud Firestore
      Reference userStorageReference = FirebaseStorage.instance
          .ref()
          .child("users")
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      UploadTask snap = userStorageReference.putData(_image!);
      snap.whenComplete(() async {
        photo = await snap.snapshot.ref.getDownloadURL();
        FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          "photo": photo,
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
        showToast("Image uploaded successfully");
      });
    }
  }
}
