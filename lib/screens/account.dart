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
    {'name': 'Haircut', 'date': '2024-11-21', 'credit': '500', 'customer': 'Layla'},
    {'name': 'Manicure', 'date': '2024-11-19', 'credit': '200', 'customer': 'Amy'},
    {'name': 'Pedicure', 'date': '2024-11-18', 'credit': '300', 'customer': 'Mena'},
    {'name': 'Haircut', 'date': '2024-11-17', 'credit': '400', 'customer': 'Layla'},
    // More rows can be added for testing scrolling functionality
  ];

  bool _selectAll = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _onSelectAllChanged(bool? value) {
    setState(() {
      _selectAll = value!;
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
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: 0.8, // 80% completion
                        strokeWidth: 12, // Thickness of the circle
                        valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF7F65ED)),
                        backgroundColor: Colors.white,
                      ),
                    ),
                    // Loan Paid Text
                    Positioned(
                      top: 24, // Position above the percentage
                      child: Text(
                        'Loan Paid',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
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

                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F65ED), // Background color
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    border: Border.all(
                      color: Colors.white, // White border
                      width: 2, // Border thickness
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Center(
                            child: Text(
                              'GROWR - Credits',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '6000',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'DUE ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '1200',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: const [
                //     Text(
                //       'Total: 6000',
                //       style: TextStyle(fontSize: 16),
                //     ),
                //     Text(
                //       'DUE: 1200',
                //       style: TextStyle(fontSize: 16),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
          // Bottom Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Table with Scrollable Header and Content
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 50,
                          columns: [
                            // Checkbox in the header
                            const DataColumn(
                              label: Text(
                                'Customer Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const DataColumn(
                              label: Text(
                                'Date',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const DataColumn(
                              label: Text(
                                'G. Credit',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const DataColumn(
                              label: Text(
                                'Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                          ],
                          rows: _data.map((data) {
                            return DataRow(
                              cells: [
                                // Checkbox for each row
                                DataCell(Text(data['customer']!)),

                                DataCell(Text(data['date']!)),
                                DataCell(Text(data['credit']!)),
                                DataCell(Text(data['name']!)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
