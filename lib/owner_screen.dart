import 'package:flutter/material.dart';
import 'stock_manage.dart'; // Stock Management Screen
import 'inventory.dart'; // Inventory Overview Screen
import 'consumption_screen.dart'; // Cloth Consumption Screen
import 'setting.dart'; // Settings Screen

class OwnerScreen extends StatefulWidget {
  @override
  _OwnerScreenState createState() => _OwnerScreenState();
}

class _OwnerScreenState extends State<OwnerScreen> {
  bool isDarkMode = false;

  final List<Map<String, dynamic>> features = [
    {
      'icon': Icons.inventory_2,
      'title': "Manage Stock",
      'description': "Track and update stock levels",
      'route': StockManagementScreen(userRole: 'Owner'), // Pass userRole to StockManagementScreen
    },
    {
      'icon': Icons.bar_chart,
      'title': "Inventory Overview",
      'description': "Analyze inventory",
      'route': InventoryScreen(),
    },
    {
      'icon': Icons.calculate_outlined,
      'title': "Consumption",
      'description': "Use the calculator for cloth consumption",
      'route': ClothConsumptionScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/wlogo.png',
            height: 60,
            width: 60,
          ),
        ),
        title: Text(
          'TEXMATE',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [


          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 16,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                if (features[index]['route'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => features[index]['route'],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Feature not available')),
                  );
                }
              },
              child: _buildFeatureTile(
                features[index]['icon'],
                features[index]['title'],
                features[index]['description'],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String description) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.teal.shade100,
            radius: 32,
            child: Icon(icon, color: Colors.teal.shade700, size: 32),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}