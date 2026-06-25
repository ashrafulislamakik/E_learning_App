import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ১. সাইন আপ ফাংশন (নতুন একাউন্ট তৈরির জন্য)
  Future<String?> signUp(String name, String email, String password) async {
    try {
      // ইউজার তৈরি করা
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ইউজারের নাম এবং রোল Firestore-এ সেভ করা
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'name': name,
        'email': email,
        'role': 'user', // ডিফল্ট রোল 'user'
        'createdAt': DateTime.now(),
      });

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // ২. লগইন ফাংশন (লগইন পেজে এটি প্রয়োজন)
  Future<String?> signIn(String email, String password) async {
    try {
      // ফায়ারবেস চেক করবে ইমেল ও পাসওয়ার্ড ঠিক আছে কি না
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "success";
    } catch (e) {
      // ভুল হলে এরর মেসেজ পাঠাবে
      return e.toString();
    }
  }

  // ৩. লগআউট ফাংশন
  Future<void> signOut() async {
    await _auth.signOut();
  }
}