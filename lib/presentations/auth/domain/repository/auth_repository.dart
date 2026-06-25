import '../../data/model/user_model.dart';

abstract class AuthRepository {

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  });

}