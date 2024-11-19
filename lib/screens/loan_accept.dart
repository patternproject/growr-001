import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoanAcceptPage extends StatefulWidget {
  const LoanAcceptPage({super.key, required this.title});
  final String title;

  @override
  State<LoanAcceptPage> createState() => _LoanAcceptPageState();
}

class _LoanAcceptPageState extends State<LoanAcceptPage> {
  late String userEmail;
  late Stream<QuerySnapshot> approvedLoansStream;

  @override
  void initState() {
    super.initState();
    // Fetch the logged-in user's email
    userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    // Fetch approved loans for the logged-in user
    approvedLoansStream = FirebaseFirestore.instance
        .collection('loan_application')
        .where('email', isEqualTo: userEmail) // Filter by user email
        .where('status', isEqualTo: 'approved') // Only fetch approved loans
        .snapshots();
  }

  // Accept the loan and move it to loan_accepted collection
  Future<void> _acceptLoan(String loanId, Map<String, dynamic> loanDetails) async {
    try {
      // Move loan to loan_accepted collection
      await FirebaseFirestore.instance.collection('loan_accepted').doc(loanId).set(loanDetails);

      // Remove from loan_application collection
      await FirebaseFirestore.instance.collection('loan_application').doc(loanId).delete();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loan accepted successfully!')));
    } catch (e) {
      print('Error accepting loan: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error accepting loan')));
    }
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
      //       icon: const Icon(Icons.home),
      //     ),
      //   ],
      // ),
      body: StreamBuilder<QuerySnapshot>(
        stream: approvedLoansStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No approved loans found.'));
          }

          final loanDocuments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: loanDocuments.length,
            itemBuilder: (context, index) {
              final loanDoc = loanDocuments[index];
              final loanDetails = loanDoc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: ListTile(
                  title: Text('Loan Application - ${loanDetails['loan_amount']} SAR'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Loan Duration: ${loanDetails['loan_duration']} months'),
                      Text('Installment Amount: ${loanDetails['installment_amount']} SAR'),
                      Text('Installment Frequency: ${loanDetails['installment_frequency']}'),
                      Text('Date of Application: ${loanDetails['created_at'].toDate()}'),
                      Text('Date of Approval: ${loanDetails['approval_date'].toDate()}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _acceptLoan(loanDoc.id, loanDetails),
                    child: const Text('Accept'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
