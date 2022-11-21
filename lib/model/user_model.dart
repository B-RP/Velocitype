import 'dart:convert';

FUser fUserFromJson(String str) => FUser.fromJson(json.decode(str));

String fUserToJson(FUser data) => json.encode(data.toJson());

class FUser {
  FUser({
    required this.name,
    required this.uid,
    required this.email,
    required this.profileImage,
  });

  String name;
  String uid;
  String email;
  String profileImage;

  factory FUser.fromJson(Map<String, dynamic> json) => FUser(
        name: json["name"] ?? "",
        uid: json["uid"] ?? "",
        email: json["email"] ?? "",
        profileImage: json["photo"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "photo": profileImage,
        "uid": uid,
      };
}
