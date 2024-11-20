import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.title});
  final String title;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _counter = 0;

  // Sample Data for the table
  final List<Map<String, String>> _data = [
    {'name': 'John Doe', 'date': '2024-11-21', 'credit': '500', 'customer': 'Layla'},
    {'name': 'Jane Smith', 'date': '2024-11-19', 'credit': '200', 'customer': 'Amy'},
    {'name': 'Sam Green', 'date': '2024-11-18', 'credit': '300', 'customer': 'Mena'},
  ];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3CAF9),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Top Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              children: [
                // Circle with Percentage
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Circle
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: 0.8, // 80% completion
                        strokeWidth: 8, // Thickness of the circle
                        valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF7F65ED)),
                        backgroundColor: Colors.white,
                      ),
                    ),
                    // Percentage in the Center
                    Text(
                      '80%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // GROWR - Credits
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'GROWR - Credits',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Total: 6000',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'DUE: 1200',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bottom Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Select')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('G. Credit')),
                    DataColumn(label: Text('Customer Name')),
                  ],
                  rows: _data.map((data) {
                    return DataRow(cells: [
                      DataCell(Checkbox(value: false, onChanged: (value) {})), // Checkbox
                      DataCell(Text(data['name']!)),
                      DataCell(Text(data['date']!)),
                      DataCell(Text(data['credit']!)),
                      DataCell(Text(data['customer']!)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
