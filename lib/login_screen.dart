import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'owner_screen.dart';
import 'inventory.dart';
import 'stock_manage.dart';
import 'consumption_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String _errorMessage = '';

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _signInWithEmailPassword(String email, String password) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user?.uid ?? '';
      if (uid.isEmpty) throw 'User UID not found.';

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) throw 'User data not found in Firestore.';

      String role = userDoc['role']?.toString()?.toLowerCase() ?? '';
      Widget nextScreen;

      switch (role) {
        case 'owner':
          nextScreen = OwnerScreen();
          break;
        case 'inventory handler':
          nextScreen = InventoryScreen();
          break;
        case 'stock handler':
          nextScreen = StockManagementScreen(userRole: 'Stock Handler');
          break;
        case 'cloth handler':
          nextScreen = ClothConsumptionScreen();
          break;
        default:
          throw 'Unauthorized role: $role';
      }

      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Login failed. Please check your credentials or contact admin.';
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login', style: TextStyle(color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.teal[700],
        centerTitle: true,
        elevation: 4.0,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Section with increased size
              Container(
                width: 200,  // Increased width
                height: 200, // Increased height
                child: Image.asset(
                  'assets/slogo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      'Logo Missing',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    );
                  },
                ),
              ),
              SizedBox(height: 40),  // Space between logo and card box
              // Login Form Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(Icons.email, color: Colors.teal),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(Icons.lock, color: Colors.teal),
                          ),
                          obscureText: true,
                        ),
                        if (_isLoading) ...[
                          SizedBox(height: 20),
                          CircularProgressIndicator(),
                        ],
                        if (_errorMessage.isNotEmpty) ...[
                          SizedBox(height: 10),
                          Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            String email = emailController.text.trim();
                            String password = passwordController.text.trim();

                            if (email.isEmpty || password.isEmpty) {
                              setState(() => _errorMessage = 'Please enter both email and password.');
                              return;
                            }
                            await _signInWithEmailPassword(email, password);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[500],
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                child: Text(
                  'Don\'t have an account? Sign up',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
