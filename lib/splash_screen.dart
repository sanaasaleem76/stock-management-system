import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'owner_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..forward();

    // Define the scaling animation
    _animation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Navigate to the appropriate screen based on the authentication state
    Future.delayed(Duration(seconds: 3), () async {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User is logged in, navigate to OwnerScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OwnerScreen()),
        );
      } else {
        // User is not logged in, navigate to LoginScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Container(
            width: 300,
            height: 300,
            child: Image.asset(
              'assets/slogo.png', // Your logo asset
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  'Error loading slogo.png',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
