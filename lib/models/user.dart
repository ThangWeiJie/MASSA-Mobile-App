class UserModel {
  final String uuid;
  final String email;
  final String phone;

  String get getUUID => uuid;

  UserModel({required this.uuid, required this.email, required this.phone});
}