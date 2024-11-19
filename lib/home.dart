import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AuthService _authService = AuthService();
  bool isLoading = false;
  bool isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSignInStatus(); // Check sign-in status when the app starts
  }

  // Check if the user is signed in
  void _checkSignInStatus() async {
    var user = await _authService.getCurrentUser();
    setState(() {
      isSignedIn = user != null;
    });
  }

  // Handle Sign-out
  void _signOut() async {
    await _authService.signOut();
    setState(() {
      isSignedIn = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Signed out")));
  }

  // Handle Google Sign-In
  void _signIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      var user = await _authService.signInWithGoogle();
      print(user);
      if (user != null) {
        setState(() {
          isLoading = false;
          isSignedIn = true;
        });
        await createProfileInCaseNoUser(user.email ?? 'muasif80+test1@gmail.com');
        // Navigate to another screen after successful login
        Navigator.pushNamed(context, '/home');
      } else {
        setState(() {

          isLoading = false;
        });
        await createProfileInCaseNoUser('muasif80+test@gmail.com');
        await
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Sign-in failed")));
      }
    } catch (e, stackTrace) {
      print("Error during Google sign-in: $e");
      print("Stack trace: $stackTrace");

      // If it's a PlatformException, print more details
      if (e is PlatformException) {
        print("PlatformException details:");
        print("Code: ${e.code}");
        print("Message: ${e.message}");
        print("Details: ${e.details}");
      }

      // Additional specific handling for ApiException error
      // if (e is ApiException) {
      //   print("API Exception details:");
      //   print("Error code: ${e.statusCode}");
      //   print("Message: ${e.message}");
      // }

      return null;
    }

  }

  Future createProfileInCaseNoUser(email) async {
    FirebaseFirestore.instance.collection('profiles').add({

      'email': email
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Center(
              child: Text(
                'Welcome to\n GROWR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            if (!isSignedIn) // Show this button if the user is not signed in
              ElevatedButton(
                onPressed: _signIn,
                child: const Text("Sign in with Google"),
              ),
            if (isSignedIn) // Show this button if the user is signed in
              ElevatedButton(
                onPressed: _signOut,
                child: const Text("Sign out"),
              ),
            if (isLoading) // Show loading indicator while signing in
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final String route;
  final String title;

  const MyButton({
    super.key,
    required this.route,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        child: Text(
          title,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
