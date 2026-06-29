// auth_helper.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthHelper {
  // Check if user is logged in
  static bool isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  // Get current user (if logged in)
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  // Login user with email and password
  static Future<UserCredential> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  // Sign up user with email and password
  static Future<UserCredential> signUpUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      throw Exception("Sign up failed: $e");
    }
  }

  // Logout the current user
  static Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
  }
}
