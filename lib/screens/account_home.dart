import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountHomePage extends StatefulWidget {
  const AccountHomePage({super.key, required this.title});
  final String title;

  @override
  State<AccountHomePage> createState() => _AccountHomePageState();
}

class _AccountHomePageState extends State<AccountHomePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool hasLoan = false;

  @override
  void initState() {
    super.initState();
    _checkLoanStatus();
  }

  Future<void> _checkLoanStatus() async {
    final User? user = _firebaseAuth.currentUser;
    if (user != null) {
      // Check if there's a loan application associated with the user
      await _fetchLoanApplication(user.email!);
    } else {
      // If the user is not signed in, redirect to the sign-in page
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  Future<void> _fetchLoanApplication(String email) async {
    try {
      // Query the 'loan_applications' collection to check if the current user has a loan application
      final QuerySnapshot loanSnapshot = await _firestore
          .collection('loan_applications')
          .where('email', isEqualTo: email) // Match the current user's email
          .where('status', isEqualTo: 'approved') // Check for approved loans
          .limit(1)
          .get();

      if (loanSnapshot.docs.isNotEmpty) {
        setState(() {
          hasLoan = true;
        });
        // If there's an approved loan application, navigate to the Account page
        Navigator.pushReplacementNamed(context, '/account');
      } else {
        // If there's no loan or loan is not approved, navigate to Loan Application page
        Navigator.pushReplacementNamed(context, '/loan-application');
      }
    } catch (e) {
      print('Error fetching loan status: $e');
      // In case of an error, navigate to Loan Application page
      Navigator.pushReplacementNamed(context, '/loan-application');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return an empty Scaffold while checking for loan status
    return Scaffold(
      backgroundColor: const Color(0xFFD3CAF9),
      body: const Center(
        child: CircularProgressIndicator(), // Show a loading indicator while checking the loan status
      ),
    );
  }
}
