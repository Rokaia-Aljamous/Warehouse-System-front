import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/user_model.dart';
import '../models/profile_model.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance;

  // ── تسجيل حساب جديد (JSON) ──────────────────────────────
  Future<UserModel> register({
    required String fullName,
    required String birthday,
    required String phoneNumber,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dio.post(
      '/api/customers/register',
      data: {
        'full_name': fullName,
        'birthday': birthday,
        'phone_number': phoneNumber,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return UserModel.fromJson(response.data['data'] ?? response.data);
  }

  // ── تسجيل الدخول (form-data) ─────────────────────────────
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/api/customers/login',
      data: FormData.fromMap({'email': email, 'password': password}),
    );
    return UserModel.fromJson(response.data['data'] ?? response.data);
  }

  // ── نسيت كلمة السر ────────────────────────────────────────
  Future<void> forgotPassword({required String email}) async {
    await _dio.post('/api/customers/forgot-password', data: {'email': email});
  }

  // ── إعادة تعيين كلمة السر ────────────────────────────────
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _dio.post(
      '/api/customers/reset-password',
      data: {
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  // ── تسجيل خروج ────────────────────────────────────────────
  Future<void> logout({required String token}) async {
    await _dio.get(
      '/api/customers/logout',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  // ── جلب بيانات البروفايل ─────────────────────────────────
  Future<ProfileModel> getProfile({required String token}) async {
    final response = await _dio.get(
      '/api/customers/profile',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return ProfileModel.fromJson(response.data);
  }

  // ── تعديل بيانات البروفايل ───────────────────────────────
  // profileImagePath: مسار الصورة على الجهاز (اختياري)، بيتبعت كملف (multipart).
  Future<ProfileModel> updateProfile({
    required String token,
    String? fullName,
    String? birthday, // بصيغة YYYY-MM-DD
    String? phoneNumber,
    String? profileImagePath,
  }) async {
    final formMap = <String, dynamic>{};
    if (fullName != null) formMap['full_name'] = fullName;
    if (birthday != null) formMap['birthday'] = birthday;
    if (phoneNumber != null) formMap['phone_number'] = phoneNumber;
    if (profileImagePath != null) {
      formMap['profile_image'] =
          await MultipartFile.fromFile(profileImagePath);
    }

    final response = await _dio.patch(
      '/api/customers/profile',
      data: FormData.fromMap(formMap),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return ProfileModel.fromJson(response.data['profile'] ?? response.data);
  }
}
