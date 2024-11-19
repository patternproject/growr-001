import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.title});
  final String title;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controllers for the form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController hoursController = TextEditingController();

  // Flags for handling success/failure messages
  String? successMessage;
  String? errorMessage;

  // Flag to show loading indicator
  bool isLoading = true;

  // Method to retrieve user data from Firestore and populate the form
  Future<void> fetchUserData() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      print("No user signed in.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Fetch the user document from Firestore based on the email
      QuerySnapshot querySnapshot = await firestore
          .collection('profiles')  // Your Firestore collection
          .where('email', isEqualTo: userEmail)  // Filter by email
          .get();

      // Check if user record is found
      if (querySnapshot.docs.isEmpty) {
        print('No user record found.');
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Retrieve the user document
      DocumentSnapshot userDoc = querySnapshot.docs[0];

      // Populate the form fields with the retrieved data
      nameController.text = userDoc['name'] ?? '';
      addressController.text = userDoc['address'] ?? '';
      phoneController.text = userDoc['phone'] ?? '';
      hoursController.text = userDoc['hours_of_operation'] ?? '';

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to update the user data in Firestore
  Future<void> updateUserData() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      setState(() {
        errorMessage = "No user signed in.";
      });
      return;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Fetch the user document based on the email
      QuerySnapshot querySnapshot = await firestore
          .collection('profiles')  // Your Firestore collection
          .where('email', isEqualTo: userEmail)  // Filter by email
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          errorMessage = 'No user record found.';
        });
        return;
      }

      // Get the document reference
      DocumentSnapshot userDoc = querySnapshot.docs[0];

      // Update the fields in Firestore
      await firestore.collection('profiles').doc(userDoc.id).update({
        'name': nameController.text,
        'address': addressController.text,
        'phone': phoneController.text,
        'hours_of_operation': hoursController.text,
      });

      // Show success message
      setState(() {
        successMessage = 'Profile updated successfully!';
        errorMessage = null;  // Clear previous error messages
      });

    } catch (e) {
      print('Error updating user data: $e');
      setState(() {
        errorMessage = 'Error updating profile. Please try again later.';
        successMessage = null;  // Clear previous success messages
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch the user data when the screen is initialized
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show success or error message
            if (successMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  successMessage!,
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

            // Name field
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: hoursController,
              decoration: InputDecoration(labelText: 'Hours of Operation'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateUserData,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose the controllers to avoid memory leaks
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    hoursController.dispose();
    super.dispose();
  }
}
