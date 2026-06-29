import 'package:flutter/material.dart'; // Required for UI components
import 'package:firebase_auth/firebase_auth.dart'; // Required for Firebase Authentication
import 'owner_screen.dart'; // Import your OwnerScreen
import 'login_screen.dart'; // Import your LoginScreen

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(); // Show loading while Firebase state loads
        }

        if (snapshot.hasData) {
          return OwnerScreen(); // Navigate to OwnerScreen if user is logged in
        }

        return LoginScreen(); // Navigate to LoginScreen if user is not logged in
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()), // Show a loading spinner
    );
  }
}
