import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/user_model.dart';
class AuthRemoteDataSource {

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {

    final credential =
    await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    final snapshot = await firestore
        .collection("users")
        .doc(uid)
        .get();

    return UserModel.fromMap(snapshot.data()!);
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {

    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;

    final userModel = UserModel(
      uid: user.uid,
      name: name,
      email: email,
      role: "student",
    );

    await firestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());

    return userModel;
  }
}