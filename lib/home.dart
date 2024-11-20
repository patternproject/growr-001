import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }

  void _checkSignInStatus() async {
    // Check if there's a currently signed-in user
    final User? user = _firebaseAuth.currentUser;
    // log(user!.email!);
    if (mounted) {
      setState(() {
        isSignedIn = user != null;
      });
    }
  }

  void _handleTap() {
    final User? user = _firebaseAuth.currentUser;

    if (user != null) {
      Navigator.pushNamed(context, '/profile');
    } else {
      Navigator.pushNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Scaffold(
        backgroundColor: const Color(0xFFD3CAF9),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'to',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'G R OW R',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 48,
                  color: Color(0xFF7E64ED),
                ),
              ),
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/logo.png',
                // Ensure your app logo is in the assets folder
                width: 60,
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
