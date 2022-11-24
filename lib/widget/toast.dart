import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

Widget buildTextField(
    {required String hint,
    required TextEditingController controller,
    required Icon icon}) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.20),
        borderRadius: BorderRadius.circular(10.r)),
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
    margin: EdgeInsets.symmetric(horizontal: 2.w),
    child: TextField(
      style: TextStyle(color: Colors.black54),
      controller: controller,
      decoration: InputDecoration(
          prefixIcon: icon,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xff737373),
              fontWeight: FontWeight.normal)),
    ),
  );
}

Widget buildLogo() {
  return SizedBox(
    height: 120.h,
    child: Image.asset('assets/images/new.PNG'),
  );
}
