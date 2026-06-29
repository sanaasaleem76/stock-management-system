import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> _vendors = [];
  String? _selectedVendor;
  String? _searchTerm;
  double _totalStock = 0.0;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
    fetchVendors();
  }

  Future<void> fetchUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        setState(() {
          _userRole = userDoc['role'] ?? '';
        });
      } catch (e) {
        print('Error fetching user role: $e');
        setState(() {
          _userRole = '';
        });
      }
    }
  }

  Future<void> fetchVendors() async {
    QuerySnapshot snapshot = await _firestore.collection('stock_in').get();
    setState(() {
      _vendors = snapshot.docs
          .map((doc) => doc['vendor']?.toString() ?? '')
          .where((vendor) => vendor.isNotEmpty)
          .toSet()
          .toList();
    });
  }

  Future<List<Map<String, dynamic>>> fetchStockData() async {
    List<Map<String, dynamic>> data = [];

    if (_selectedVendor != null && _selectedVendor!.isNotEmpty) {
      QuerySnapshot snapshot = await _firestore
          .collection('stock_in')
          .where('vendor', isEqualTo: _selectedVendor)
          .get();

      data = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      // Calculate total stock for selected vendor
      _totalStock = data.fold(0.0, (sum, item) => sum + (item['quantity']?.toDouble() ?? 0.0));
    }

    return data;
  }

  Future<void> deleteVendor(String vendor) async {
    try {
      // Remove vendor from the stock_in collection
      QuerySnapshot snapshot = await _firestore.collection('stock_in').where('vendor', isEqualTo: vendor).get();
      for (var doc in snapshot.docs) {
        await _firestore.collection('stock_in').doc(doc.id).delete();
      }

      // Refresh the vendors list after deletion
      await fetchVendors();

      // Reset the selected vendor if it's the one being deleted
      if (_selectedVendor == vendor) {
        setState(() {
          _selectedVendor = null;
          _totalStock = 0.0;  // Reset total stock
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vendor "$vendor" deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting vendor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting vendor.')),
      );
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Redirect to the login screen
  }

  @override
  Widget build(BuildContext context) {
    if (_userRole == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Inventory', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout, // Call logout function
          ),
        ],
      ),
      body: Column(
        children: [
          if (_userRole == 'Owner' || _userRole == 'Inventory Handler') ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Vendor selection dropdown
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: Text('Select Vendor'),
                    value: _selectedVendor,
                    items: _vendors.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(value),
                            _userRole == 'Owner'
                                ? IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteVendor(value);
                              },
                            )
                                : SizedBox.shrink(), // Only show delete button for Owner
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedVendor = newValue;
                        _totalStock = 0.0; // Reset total stock before calculating
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  // Search field for Unique ID
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search by Unique ID',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchTerm = value.trim();
                      });
                    },
                  ),
                ],
              ),
            ),
          ],

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchStockData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No data found!',
                      style: TextStyle(color: Colors.teal[700]),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    return ListTile(
                      title: Text(item['product_name'] ?? ''),
                      subtitle: Text(
                        'Vendor: ${item['vendor'] ?? ''} | ID: ${item['unique_id'] ?? ''}',
                      ),
                      trailing: Text('Quantity: ${item['quantity']?.toString() ?? '0'}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
