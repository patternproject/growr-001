import 'dart:convert';
import 'dart:io';
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
  List<DocumentSnapshot> loanApplications = [];

  // Function to convert a file to Base64
  Future<String?> _convertFileToBase64(File file) async {
    try {
      List<int> fileBytes = await file.readAsBytes();
      String base64String = base64Encode(fileBytes);
      return base64String;
    } catch (e) {
      print('Error converting file to Base64: $e');
      return null;
    }
  }

  // Function to validate file size (must be within 50KB)
  Future<bool> _validateFileSize(File file) async {
    int fileSize = await file.length();
    return fileSize <= 50 * 1024; // 50KB limit
  }

  // Function to handle file upload
  Future<void> _pickAndUploadFile(String fileType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);

      // Check the file size
      bool isValidSize = await _validateFileSize(file);
      if (!isValidSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File size exceeds 50KB limit')),
        );
        return;
      }

      // Convert file to Base64
      String? base64File = await _convertFileToBase64(file);
      if (base64File != null) {
        setState(() {
          if (fileType == 'bank_statement') {
            _bankStatementPath = base64File;
          } else if (fileType == 'commercial_registration') {
            _commercialRegistrationPath = base64File;
          } else if (fileType == 'gosi_registration') {
            _gosiRegistrationPath = base64File;
          }
        });
      }
    }
  }

  // Function to get the next loan application ID
  Future<String> _getNextLoanApplicationId() async {
    // Here, we get the next ID based on Firestore document count
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('loan_applications')
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return '1';  // If no applications exist, start with ID 1
      } else {
        DocumentSnapshot lastDocument = querySnapshot.docs.first;
        int lastId = int.tryParse(lastDocument['application_id'] ?? '0') ?? 0;
        return (lastId + 1).toString();  // Increment the last ID
      }
    } catch (e) {
      print('Error getting next application ID: $e');
      return '1';  // Default to ID 1 in case of error
    }
  }

  // Function to revoke a loan application
  Future<void> _revokeLoanApplication(String applicationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('loan_applications')
          .doc(applicationId)
          .update({'status': 'revoked'});

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Loan application revoked successfully!'),
      ));

      // Re-fetch loan applications to update UI
      _fetchLoanApplications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error revoking loan application'),
      ));
      print('Error revoking loan application: $e');
    }
  }

  // Function to submit loan application
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
      'email': userEmail,
      'loan_amount': _loanAmount,
      'bank_statement': _bankStatementPath,
      'commercial_registration': _commercialRegistrationPath,
      'gosi_registration': _gosiRegistrationPath,
      'application_id': loanApplicationId,
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
    };

    try {
      // Save the loan application in Firestore under the 'loan_applications' collection
      await FirebaseFirestore.instance.collection('loan_applications').doc(loanApplicationId).set(loanApplicationData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loan application submitted successfully!')));

      setState(() {
        _loanAmount = 1000;
        _bankStatementPath = null;
        _commercialRegistrationPath = null;
        _gosiRegistrationPath = null;
      });

      _fetchLoanApplications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting loan application')));
      print('Error submitting loan application: $e');
    }
  }

  // Function to fetch loan applications for the current user
  Future<void> _fetchLoanApplications() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) return;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('loan_applications')
          .where('email', isEqualTo: userEmail)
          .orderBy('created_at', descending: true)
          .get();

      setState(() {
        loanApplications = querySnapshot.docs;
      });
    } catch (e) {
      print('Error fetching loan applications: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLoanApplications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    : const Text('Document selected'),
                trailing: IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: () => _pickAndUploadFile('bank_statement'),
                ),
              ),

              const SizedBox(height: 10),

              // Commercial Registration Upload
              ListTile(
                title: const Text('Commercial Registration'),
                subtitle: _commercialRegistrationPath == null
                    ? const Text('No document selected')
                    : const Text('Document selected'),
                trailing: IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: () => _pickAndUploadFile('commercial_registration'),
                ),
              ),

              const SizedBox(height: 10),

              // GOSI Registration Upload
              ListTile(
                title: const Text('GOSI Registration'),
                subtitle: _gosiRegistrationPath == null
                    ? const Text('No document selected')
                    : const Text('Document selected'),
                trailing: IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: () => _pickAndUploadFile('gosi_registration'),
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
                        subtitle: Text('Status: ${application['status']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _revokeLoanApplication(application.id),
                        ),
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
