import 'package:flutter/material.dart';

import '../data/datasource/auth_remote_datasource.dart';
import '../domain/repository/auth_repo_iml.dart';
import '../domain/usecases/signup_usecase.dart';


class AuthProvider extends ChangeNotifier {

  bool isLoading = false;

  final SignUpUseCase signUpUseCase = SignUpUseCase(
    AuthRepositoryImpl(
      AuthRemoteDataSource(),
    ),
  );

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {

    try {

      isLoading = true;

      notifyListeners();

      await signUpUseCase(
        name: name,
        email: email,
        password: password,
      );

    } finally {

      isLoading = false;

      notifyListeners();

    }

  }

}