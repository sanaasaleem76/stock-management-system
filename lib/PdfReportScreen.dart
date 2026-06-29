import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfReportScreen extends StatefulWidget {
  @override
  _PdfReportScreenState createState() => _PdfReportScreenState();
}

class _PdfReportScreenState extends State<PdfReportScreen> {
  // Function to generate the PDF report
  Future<void> _generatePdf() async {
    try {
      final pdf = pw.Document();
      final stockInData = await _fetchStockInData();
      final stockOutData = await _fetchStockOutData();

      if (stockInData.isEmpty && stockOutData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No data found.")),
        );
        return;
      }

      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Stock Report",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text("Stock In Data", style: pw.TextStyle(fontSize: 20)),
              pw.Table.fromTextArray(
                headers: ["Date", "Vendor", "Quantity"],
                data: stockInData.map((data) => [
                  formatDate(data['date']),
                  data['vendor'] ?? '',
                  data['quantity'].toString(),
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Stock Out Data", style: pw.TextStyle(fontSize: 20)),
              pw.Table.fromTextArray(
                headers: ["Date", "Vendor", "Quantity"],
                data: stockOutData.map((data) => [
                  formatDate(data['date']),
                  data['vendor'] ?? '',
                  data['quantity'].toString(),
                ]).toList(),
              ),
            ],
          ),
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      print("Error generating report: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating report: $e")),
      );
    }
  }

  // Function to fetch stock-in data without filtering by date
  Future<List<Map<String, dynamic>>> _fetchStockInData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('stock_in')
          .get();

      return snapshot.docs.map((doc) {
        return {
          'date': doc['date'],
          'vendor': doc['vendor'] ?? '',
          'quantity': doc['quantity'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print("Error fetching stock-in data: $e");
      return [];
    }
  }

  // Function to fetch stock-out data without filtering by date
  Future<List<Map<String, dynamic>>> _fetchStockOutData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('stock_in_out')
          .get();

      return snapshot.docs.map((doc) {
        return {
          'date': doc['date'],
          'vendor': doc['vendor'] ?? '',
          'quantity': doc['quantity'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print("Error fetching stock-out data: $e");
      return [];
    }
  }

  // Function to format the date string
  String formatDate(String dateStr) {
    try {
      final dateParts = dateStr.split('-');
      if (dateParts.length == 3) {
        return '${dateParts[0]}-${dateParts[1]}-${dateParts[2]}';
      }
      return dateStr;
    } catch (e) {
      print("Error formatting date: $e");
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Generate Stock Report",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.teal[700],
        iconTheme: IconThemeData(color: Colors.white), // Arrow color white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _generatePdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700], // Teal[700] for button
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text(
                  "Generate PDF Report",
                  style: TextStyle(color: Colors.white), // Button text color white
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
