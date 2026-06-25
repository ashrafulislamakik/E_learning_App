import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {

  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {

    return UserModel(
      uid: map["uid"] ?? "",
      name: map["name"] ?? "",
      email: map["email"] ?? "",
      role: map["role"] ?? "student",
    );
  }

  Map<String, dynamic> toMap() {

    return {
      "uid": uid,
      "name": name,
      "email": email,
      "role": role,
    };
  }
}