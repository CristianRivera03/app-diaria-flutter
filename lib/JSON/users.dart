
import 'dart:convert';

Users welcomeFromMap(String str) => Users.fromMap(json.decode(str));

String welcomeToMap(Users data) => json.encode(data.toMap());

class Users {
  final int? usrId;
  final String? fullName;
  final String? email;
  final String usrName;
  final String usrPassword;

  Users({
    this.usrId,
    this.fullName,
    this.email,
    required this.usrName,
    required this.usrPassword,
  });

  // factory constructor
  factory Users.fromMap(Map<String, dynamic> json) => Users(
    usrId: json["usrID"],
    fullName: json["fullName"],
    email: json["email"],
    usrName: json["usrName"],
    usrPassword: json["usrPassword"],
  );

  Map<String, dynamic> toMap() => {
    "usrID": usrId,
    "fullName": fullName,
    "email": email,
    "usrName": usrName,
    "usrPassword": usrPassword,
  };
}
