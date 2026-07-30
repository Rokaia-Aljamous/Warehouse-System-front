class UserModel {
  final int? id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? birthday;
  final String? token;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.birthday,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      birthday: json['birthday'],
      token: json['token'],
    );
  }
}