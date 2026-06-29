import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class ClothConsumptionScreen extends StatefulWidget {
  @override
  _ClothConsumptionScreenState createState() => _ClothConsumptionScreenState();
}

class _ClothConsumptionScreenState extends State<ClothConsumptionScreen> {
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController rawClothWidthController = TextEditingController();

  String cutSize = "";
  String clothConsumption = "";

  bool showResults = false;
  bool isDoubleSided = false;

  String lengthUnit = 'm';
  String widthUnit = 'm';
  String rawClothWidthUnit = 'm';
  String resultUnit = 'm';

  String userRole = '';
  bool isAuthorized = false;

  final Map<String, double> unitConversion = {
    'm': 1.0,
    'cm': 0.01,
    'in': 0.0254,
  };

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            userRole = userDoc['role'] ?? '';
            isAuthorized = (userRole == 'Cloth Handler' || userRole == 'Owner');
          });
        } else {
          setState(() {
            isAuthorized = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user role: $e");
      setState(() {
        isAuthorized = false;
      });
    }
  }

  void calculateConsumption() {
    double length = (double.tryParse(lengthController.text) ?? 0) *
        (unitConversion[lengthUnit] ?? 1.0);
    double width = (double.tryParse(widthController.text) ?? 0) *
        (unitConversion[widthUnit] ?? 1.0);
    int quantity = int.tryParse(quantityController.text) ?? 0;
    double rawClothWidth = (double.tryParse(rawClothWidthController.text) ?? 0) *
        (unitConversion[rawClothWidthUnit] ?? 1.0);

    setState(() {
      double cutSizeValue = length * width;
      double totalConsumption = 0;

      if (rawClothWidth > 0) {
        totalConsumption = (cutSizeValue * quantity) / rawClothWidth;
        if (isDoubleSided) {
          totalConsumption *= 2;
        }
        clothConsumption = "${convertToResultUnit(totalConsumption)} $resultUnit";
      } else {
        clothConsumption = "Raw cloth width must be greater than 0 to calculate.";
      }

      cutSize = "${convertToResultUnit(cutSizeValue)} square $resultUnit";
      showResults = true;
    });
  }

  double convertToResultUnit(double value) {
    return value / (unitConversion[resultUnit] ?? 1.0);
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to login screen
      );
    } catch (e) {
      print("Logout error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAuthorized) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Cloth Consumption Calculator"),
          centerTitle: true,
          backgroundColor: Colors.teal[700],
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              SizedBox(height: 16),
             
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Cloth Consumption Calculator"),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white), // Logout icon
            onPressed: _logout, // Call the logout function
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(lengthController, 'Length of the item', 'm',
                onUnitChanged: (String? newValue) {
                  setState(() {
                    lengthUnit = newValue ?? 'm';
                  });
                }),
            _buildInputField(widthController, 'Width of the item', 'm',
                onUnitChanged: (String? newValue) {
                  setState(() {
                    widthUnit = newValue ?? 'm';
                  });
                }),
            _buildInputField(quantityController, 'Quantity of items', null),
            _buildInputField(
                rawClothWidthController, 'Width of raw cloth', 'm',
                onUnitChanged: (String? newValue) {
                  setState(() {
                    rawClothWidthUnit = newValue ?? 'm';
                  });
                }),
            _buildResultUnitDropdown(),
            _buildDoubleSidedCheckbox(),
            _buildCalculateButton(),
            _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label,
      String? unit,
      {Function(String?)? onUnitChanged, bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: isNumeric
                  ? TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (unit != null) ...[
            SizedBox(width: 10),
            DropdownButton<String>(
              value: unit,
              onChanged: onUnitChanged,
              items: unitConversion.keys
                  .map<DropdownMenuItem<String>>((String key) {
                return DropdownMenuItem<String>(value: key, child: Text(key));
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultUnitDropdown() {
    return DropdownButtonFormField<String>(
      value: resultUnit,
      onChanged: (String? newValue) {
        setState(() {
          resultUnit = newValue ?? 'm';
        });
      },
      items: unitConversion.keys.map<DropdownMenuItem<String>>((String key) {
        return DropdownMenuItem<String>(value: key, child: Text(key));
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Result Unit',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDoubleSidedCheckbox() {
    return CheckboxListTile(
      title: Text("Double Sided"),
      value: isDoubleSided,
      onChanged: (bool? value) {
        setState(() {
          isDoubleSided = value ?? false;
        });
      },
      activeColor: Colors.teal[700],
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: calculateConsumption,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text('Calculate Consumption'),
    );
  }

  Widget _buildResultsSection() {
    return Visibility(
      visible: showResults,
      child: Column(
        children: [
          Text('Cut Size: $cutSize'),
          Text('Cloth Consumption: $clothConsumption'),
        ],
      ),
    );
  }
}
