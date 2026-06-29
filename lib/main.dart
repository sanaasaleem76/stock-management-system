import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'owner_screen.dart';
import 'consumption_screen.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = _initializeFirebase();

  static Future<FirebaseApp> _initializeFirebase() async {
    try {
      if (kIsWeb) {
        return await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyBpYucaq-969OqFpC_5H_AXuLI7XAUnrtM",
            authDomain: "simple-c0e89.firebaseapp.com",
            projectId: "simple-c0e89",
            storageBucket: "simple-c0e89.appspot.com",
            messagingSenderId: "367973413886",
            appId: "1:367973413886:web:7aa478434952b78ccd06af",
            measurementId: "G-Q6M02HH9JM",
          ),
        );
      } else {
        return await Firebase.initializeApp();
      }
    } catch (e) {
      // Only log in debug mode
      if (kDebugMode) {
        debugPrint('Firebase initialization error: $e');
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error);
        }

        return MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.teal,
            textTheme: TextTheme(
              bodyMedium: TextStyle(fontSize: 16, color: Colors.teal[700]),
            ),
          ),
          home: SplashScreen(), // Set SplashScreen as the home screen
          routes: {
            '/splash': (context) => SplashScreen(),
            '/owner': (context) => OwnerScreen(),
            '/consumption_calculator': (context) => ClothConsumptionScreen(),
            '/login': (context) => LoginScreen(),
            '/signup': (context) => SignUpScreen(),
          },
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildErrorScreen(Object? error) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Failed to initialize Firebase: $error',
            style: TextStyle(color: Colors.red, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        if (snapshot.hasData) {
          return OwnerScreen(); // Navigate to OwnerScreen after login
        }

        return LoginScreen(); // Show LoginScreen if no user is logged in
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
