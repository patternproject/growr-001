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
  double _loanAmount = 100000;
  String? _bankStatementPath;
  String? _commercialRegistrationPath;
  String? _gosiRegistrationPath;
  List<DocumentSnapshot> loanApplications = [];
  bool isSubmitting = false;  // Flag for loading state during submission

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

  // Function to get the next loan application ID (formatted)
  Future<String> _getNextLoanApplicationId() async {
    try {
      DocumentSnapshot sequenceDoc = await FirebaseFirestore.instance
          .collection('sequence_numbers')
          .doc('loan_application')
          .get();

      int lastSequenceNumber = (sequenceDoc['last_sequence_number'] ?? 0);
      String nextId = (lastSequenceNumber + 1).toString().padLeft(6, '0');

      await FirebaseFirestore.instance.collection('sequence_numbers')
          .doc('loan_application')
          .update({'last_sequence_number': lastSequenceNumber + 1});

      return nextId;
    } catch (e) {
      print('Error getting next application ID: $e');
      return '000001';  // Default to ID 000001 in case of error
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

      // Navigator.pushNamed(context, '/account-home');
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
    setState(() {
      isSubmitting = true;  // Start the loading spinner
    });

    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      setState(() {
        isSubmitting = false;  // Stop loading spinner
      });
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
      'status': 'approved',
      'created_at': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('loan_applications').doc(loanApplicationId).set(loanApplicationData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loan application submitted successfully!')));

      setState(() {
        _loanAmount = 1000;
        _bankStatementPath = null;
        _commercialRegistrationPath = null;
        _gosiRegistrationPath = null;
      });

      // Refresh the loan applications list after submission
      _fetchLoanApplications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting loan application')));
      print('Error submitting loan application: $e');
    } finally {
      setState(() {
        isSubmitting = false;  // Stop the loading spinner
      });
    }
  }

  // Function to fetch loan applications for the current user
  void _fetchLoanApplications() {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) return;

    FirebaseFirestore.instance
        .collection('loan_applications')
        .where('email', isEqualTo: userEmail)
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        loanApplications = querySnapshot.docs;
      });
    });
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
                max: 100000,
                divisions: 1000,
                label: _loanAmount.toStringAsFixed(2),
                onChanged: (value) {
                  setState(() {
                    _loanAmount = double.parse(value.toStringAsFixed(2));
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
                child: isSubmitting
                    ? const CircularProgressIndicator()  // Show spinner while submitting
                    : const Text('Apply for Loan'),
              ),

              const SizedBox(height: 20),

              // Loan Applications List
              loanApplications.isEmpty
                  ? const Center(child: Text('No loan applications found.'))
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: loanApplications.length,
                itemBuilder: (context, index) {
                  var application = loanApplications[index];
                  return Card(
                    child: ListTile(
                      title: Text('Application ID: ${application['application_id']}'),
                      subtitle: Text('Status: ${application['status']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _revokeLoanApplication(application.id),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
