import 'package:complete_app/PdfReportScreen.dart'; // Only this import
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login_screen.dart'; // Import the login screen to navigate back
import 'user_managemnt.dart'; // Import the User Management screen

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _performLogout(context);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    Fluttertoast.showToast(
      msg: "Logged out successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.teal,
      textColor: Colors.white,
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to login screen
          (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal[700],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.white, // Set background color to white
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // User Management section
            Card(
              elevation: 0,
              color: Colors.grey[100],
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.account_circle, color: Colors.teal[400]),
                title: Text(
                  'User Management',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                subtitle: Text(
                  'Manage application users',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserManagementScreen()),
                  );
                },
              ),
            ),

            // Monthly Report section
            Card(
              elevation: 0,
              color: Colors.grey[100],
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.insert_chart, color: Colors.teal[400]),
                title: Text(
                  'Monthly Report',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                subtitle: Text(
                  'View monthly performance reports',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PdfReportScreen()), // Navigate to PdfReportScreen
                  );
                },
              ),
            ),

            // Logout section
            Card(
              elevation: 0,
              color: Colors.grey[100],
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.teal[400]),
                title: Text(
                  'Logout',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                subtitle: Text(
                  'Sign out of your account',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
                onTap: () => _confirmLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
