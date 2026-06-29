import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class StockManagementScreen extends StatefulWidget {
  final String userRole;
  const StockManagementScreen({required this.userRole});

  @override
  _StockManagementScreenState createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  final _vendorController = TextEditingController();
  final _uniqueIdController = TextEditingController();
  final _stockInQuantityController = TextEditingController();
  final _stockOutQuantityController = TextEditingController();
  final _dateController = TextEditingController();
  String? _selectedStockInId;
  List<Map<String, dynamic>> _stockInList = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchStockInData();
  }

  Future<void> _fetchStockInData() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('stock_in').get();
      setState(() {
        _stockInList = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'vendor': doc['vendor'],
            'quantity': doc['quantity'],
            'date': doc['date'],
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching stock data: $e")),
      );
    }
  }

  Future<void> _saveStockIn() async {
    if (_validateInputs([_vendorController, _uniqueIdController, _stockInQuantityController, _dateController])) {
      try {
        await _firestore.collection('stock_in').add({
          'vendor': _vendorController.text,
          'unique_id': _uniqueIdController.text,
          'quantity': int.parse(_stockInQuantityController.text),
          'date': _dateController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Stock In saved successfully!")));
        _clearInputs();  // Clear the inputs after saving
        _fetchStockInData();  // Refresh the stock list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving stock: $e")));
      }
    }
  }

  Future<void> _saveStockOut() async {
    if (_validateInputs([_stockOutQuantityController])) {
      try {
        DocumentSnapshot stockEntry = await _firestore.collection('stock_in').doc(_selectedStockInId).get();
        int currentStock = stockEntry['quantity'];

        int stockOutQuantity = int.parse(_stockOutQuantityController.text);
        if (stockOutQuantity > currentStock) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Stock Out quantity cannot exceed available stock")));
          return;
        }

        // Update the stock quantity in Firestore
        await _firestore.collection('stock_in').doc(_selectedStockInId).update({
          'quantity': currentStock - stockOutQuantity,
        });

        // Optionally, record the stock out transaction
        await _firestore.collection('stock_out').add({
          'stock_in_id': _selectedStockInId,
          'quantity': stockOutQuantity,
          'date': _dateController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Stock Out saved successfully!")));
        _clearInputs();
        _fetchStockInData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving stock out: $e")));
      }
    }
  }

  bool _validateInputs(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      if (controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill all required fields.")),
        );
        return false;
      }
    }
    return true;
  }

  void _clearInputs() {
    _vendorController.clear();
    _uniqueIdController.clear();
    _stockInQuantityController.clear();
    _stockOutQuantityController.clear();
    _dateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stock Management',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (widget.userRole == 'Owner' || widget.userRole == 'Stock Handler') ...[
                _buildInputField('Vendor', _vendorController),
                _buildInputField('Unique ID', _uniqueIdController),
                _buildInputField('Quantity In', _stockInQuantityController, isNumber: true),
                _buildDatePickerField('Date', _dateController),
                _buildActionButton('Save Stock In', _saveStockIn, Colors.teal),
              ],
              SizedBox(height: 20),
              if (widget.userRole == 'Owner' || widget.userRole == 'Stock Handler') ...[
                _buildDropdownField(),
                _buildInputField('Quantity Out', _stockOutQuantityController, isNumber: true),
                _buildActionButton('Save Stock Out', _saveStockOut, Colors.red),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  primaryColor: Colors.teal[700]!,
                  colorScheme: ColorScheme.light(
                    primary: Colors.teal[700]!,
                  ),
                  dialogBackgroundColor: Colors.white,
                ),
                child: child!,
              );
            },
          );
          if (pickedDate != null) {
            controller.text = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
          }
        },
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedStockInId,
      items: _stockInList.map((stock) {
        return DropdownMenuItem<String>(
          value: stock['id'],
          child: Text("${stock['vendor']} | Qty: ${stock['quantity']} | Date: ${stock['date']}"),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedStockInId = value;
        });
      },
      decoration: InputDecoration(labelText: 'Select Stock Entry', border: OutlineInputBorder()),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(label, style: TextStyle(color: Colors.white)),
    );
  }
}
