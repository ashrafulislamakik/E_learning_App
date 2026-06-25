import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/model/user_model.dart';
import '../../domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {

  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) {

    return remoteDataSource.signUp(
      name: name,
      email: email,
      password: password,
    );

  }
}