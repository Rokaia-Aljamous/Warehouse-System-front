/// يمثل شكل رد الـ backend لمسارات
/// GET /api/customers/profile و PATCH /api/customers/profile
class ProfileModel {
  final String fullName;
  final String? birthday; // بصيغة YYYY-MM-DD كما يرسلها Laravel
  final String phoneNumber;
  final String email;
  final String? profileImage; // رابط كامل (asset URL) أو null

  ProfileModel({
    required this.fullName,
    required this.birthday,
    required this.phoneNumber,
    required this.email,
    required this.profileImage,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      fullName: json['full_name'] ?? '',
      birthday: json['birthday'],
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profile_image'],
    );
  }
}
