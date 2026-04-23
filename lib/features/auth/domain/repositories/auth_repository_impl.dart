import 'package:shopping_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopping_app/core/service/dio_client.dart';
import 'package:shopping_app/core/constants/api_constants.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<String> verifyFirebaseToken(String firebaseToken) async {
    final response = await DioClient.instance.post(
      ApiConstants.verifyToken,
      data: {'firebase_token': firebaseToken},
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return data['access_token'] as String;
  }
}
