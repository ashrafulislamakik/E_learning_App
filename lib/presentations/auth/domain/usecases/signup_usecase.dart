
import '../../data/model/user_model.dart';
import '../repository/auth_repository.dart';

class SignUpUseCase {

  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<UserModel> call({
    required String name,
    required String email,
    required String password,
  }) {

    return repository.signUp(
      name: name,
      email: email,
      password: password,
    );

  }

}