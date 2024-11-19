import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class LoanApplicationPage extends StatefulWidget {
  const LoanApplicationPage({super.key, required this.title});

  final String title;

  @override
  State<LoanApplicationPage> createState() => _LoanApplicationPageState();
}

class _LoanApplicationPageState extends State<LoanApplicationPage> {
  double _loanAmount = 1000;
  String? _bankStatementPath;
  String? _commercialRegistrationPath;
  String? _gosiRegistrationPath;
  List<DocumentSnapshot> loanApplications = []; // To hold the fetched loan applications

  // Function to generate the next sequence number
  Future<String> _getNextLoanApplicationId() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot snapshot = await firestore.collection('sequence_numbers').doc('loan_application').get();

    int nextSequenceNumber = 1; // Default to 1 if no sequence is found
    if (snapshot.exists) {
      nextSequenceNumber = snapshot['last_sequence_number'] + 1;
    }

    // Format as a 6-digit string (e.g., '000001')
    String formattedId = nextSequenceNumber.toString().padLeft(6, '0');

    // Update the sequence number in Firestore for the next application
    await firestore.collection('sequence_numbers').doc('loan_application').set({
      'last_sequence_number': nextSequenceNumber,
    });

    return formattedId;
  }

  // Function to handle loan application submission
  Future<void> _submitLoanApplication() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No user signed in')));
      return;
    }

    // Get the next loan application ID
    String loanApplicationId = await _getNextLoanApplicationId();

    // Prepare the data to upload
    Map<String, dynamic> loanApplicationData = {
      'email': userEmail,  // Change field name to 'email'
      'loan_amount': _loanAmount,
      'bank_statement': _bankStatementPath,
      'commercial_registration': _commercialRegistrationPath,
      'gosi_registration': _gosiRegistrationPath,
      'application_id': loanApplicationId,
      'status': 'pending', // Default status is 'pending'
      'created_at': FieldValue.serverTimestamp(),
    };

    try {
      // Save the loan application in Firestore under the 'loan_applications' collection
      await FirebaseFirestore.instance.collection('loan_applications').doc(loanApplicationId).set(loanApplicationData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loan application submitted successfully!')));

      // Clear the form fields
      setState(() {
        _loanAmount = 1000;
        _bankStatementPath = null;
        _commercialRegistrationPath = null;
        _gosiRegistrationPath = null;
      });

      // Refresh the loan applications list
      _fetchLoanApplications();
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting loan application')));
      print('Error submitting loan application: $e');
    }
  }

  // Function to fetch all loan applications for the current user
  Future<void> _fetchLoanApplications() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      return;
    }

    try {
      // Fetch loan applications from Firestore using the new 'email' field
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('loan_applications')
          .where('email', isEqualTo: userEmail)  // Change to 'email'
          .orderBy('created_at', descending: true) // Fetch in reverse chronological order
          .get();

      setState(() {
        loanApplications = querySnapshot.docs;
      });
    } catch (e) {
      print('Error fetching loan applications: $e');
    }
  }

  // Function to revoke a loan application
  Future<void> _revokeLoanApplication(String applicationId) async {
    try {
      // Revoke the loan application (set status to 'revoked')
      await FirebaseFirestore.instance.collection('loan_applications').doc(applicationId).update({
        'status': 'revoked',
      });

      // Refresh the loan applications list
      _fetchLoanApplications();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loan application revoked successfully!')));
    } catch (e) {
      print('Error revoking loan application: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error revoking loan application')));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLoanApplications(); // Fetch loan applications when the page is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      //   actions: <Widget>[
      //     IconButton(
      //       onPressed: () {
      //         Navigator.pushNamed(context, '/home');
      //       },
      //       icon: const Icon(
      //         Icons.home,
      //       ),
      //     ),
      //   ],
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loan Amount Slider
              const Text('Loan Amount'),
              Slider(
                value: _loanAmount,
                min: 100,
                max: 1000,
                divisions: 100,
                label: _loanAmount.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _loanAmount = value;
                  });
                },
              ),
              Text('Selected Amount: $_loanAmount SAR'),

              const SizedBox(height: 20),

              // Bank Statement Upload
              ListTile(
                title: const Text('Bank Statement'),
                subtitle: _bankStatementPath == null
                    ? const Text('No document selected')
                    : Text(_bankStatementPath!),
                trailing: IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      setState(() {
                        _bankStatementPath = result.files.single.path;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Commercial Registration Upload
              ListTile(
                title: const Text('Commercial Registration'),
                subtitle: _commercialRegistrationPath == null
                    ? const Text('No document selected')
                    : Text(_commercialRegistrationPath!),
                trailing: IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      setState(() {
                        _commercialRegistrationPath = result.files.single.path;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),

              // GOSI Registration Upload
              ListTile(
                title: const Text('GOSI Registration'),
                subtitle: _gosiRegistrationPath == null
                    ? const Text('No document selected')
                    : Text(_gosiRegistrationPath!),
                trailing: IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      setState(() {
                        _gosiRegistrationPath = result.files.single.path;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Apply Button
              ElevatedButton(
                onPressed: _submitLoanApplication,
                child: const Text('Apply'),
              ),

              const SizedBox(height: 20),

              // Loan Applications List
              const Text('Previous Loan Applications'),
              SizedBox(
                height: 300, // Fixed height for the scrollable list
                child: loanApplications.isEmpty
                    ? const Center(child: Text('No applications found'))
                    : ListView.builder(
                  itemCount: loanApplications.length,
                  itemBuilder: (context, index) {
                    var application = loanApplications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text('Amount: ${application['loan_amount']} SAR'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${application['created_at'].toDate()}'),
                            Text('Application ID: ${application['application_id']}'),
                            Text('Status: ${application['status']}'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (application['status'] != 'revoked')
                                  TextButton(
                                    onPressed: () {
                                      _revokeLoanApplication(application.id);
                                    },
                                    child: const Text('Revoke'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
