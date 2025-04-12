import 'dart:convert';

Users welcomeFromMap(String str) => Users.fromMap(json.decode(str));

String welcomeToMap(Users data) => json.encode(data.toMap());

class Users {
  final int? usrId;
  final String? fullName;
  final String? email;
  final String usrName;
  final String usrPassword;
  final bool isActive; // Estado de conexión
  final String? profileImage; // Ruta de la imagen de perfil

  Users({
    this.usrId,
    this.fullName,
    this.email,
    required this.usrName,
    required this.usrPassword,
    this.isActive = false, // Desconectado por defecto
    this.profileImage, // Inicialmente nulo
  });

  // Convertir desde el mapa de la base de datos
  factory Users.fromMap(Map<String, dynamic> json) => Users(
    usrId: json["usrID"],
    fullName: json["fullName"],
    email: json["email"],
    usrName: json["usrName"],
    usrPassword: json["usrPassword"],
    isActive: json["isActive"] == 1,
    profileImage: json["profileImage"], // Recupera la ruta de la imagen de perfil
  );

  // Convertir a un mapa para insertar en la base de datos
  Map<String, dynamic> toMap() => {
    "usrID": usrId,
    "fullName": fullName,
    "email": email,
    "usrName": usrName,
    "usrPassword": usrPassword,
    "isActive": isActive ? 1 : 0,
    "profileImage": profileImage, // Guarda la ruta de la imagen de perfil
  };
}