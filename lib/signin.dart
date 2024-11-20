import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.title});

  final String title;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;
  bool isSignedIn = false;
  String? emailError;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }

  void _checkSignInStatus() async {
    var user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        isSignedIn = user != null;
      });
      if (user != null) {
        await _createProfileIfNotExists(user.email ?? '');
        Navigator.pushReplacementNamed(context, '/profile');
      }
    }
  }

  bool _validateInputs() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    setState(() {
      emailError = null;
      passwordError = null;
    });

    if (email.isEmpty || !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      setState(() {
        emailError = "Enter a valid email address";
      });
      _showToast("Invalid email address");
      return false;
    }

    if (password.isEmpty || password.length < 6) {
      setState(() {
        passwordError = "Password must be at least 6 characters";
      });
      _showToast("Invalid password");
      return false;
    }

    return true;
  }

  Future<void> _signInWithEmailPassword() async {
    if (!_validateInputs()) return;

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      setState(() {
        isLoading = false;
        isSignedIn = true;
      });
      await _createProfileIfNotExists(email);
      Navigator.pushReplacementNamed(context, '/profile');
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });

      log(e.code);

      if (e.code == 'user-not-found') {
        // Create a new user if email does not exist
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
          setState(() {
            isLoading = false;
            isSignedIn = true;
          });
          await _createProfileIfNotExists(email);
          Navigator.pushReplacementNamed(context, '/profile');
        } catch (createError) {
          _showToast("Error creating new user: ${createError.toString()}");
        }
      } else if (e.code == 'wrong-password') {
        // Incorrect password
        _showToast("Password is incorrect");
      } else {
        // Other errors
        _showToast("Sign-in error: ${e.message}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showToast("Unexpected error: ${e.toString()}");
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createProfileIfNotExists(String email) async {
    var querySnapshot = await FirebaseFirestore.instance.collection('profiles').where('email', isEqualTo: email).get();

    if (querySnapshot.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('profiles').add({'email': email});
      print("Profile created for $email");
    } else {
      print("Profile already exists for $email");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (!isSignedIn)
                Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: const OutlineInputBorder(),
                        errorText: emailError,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        errorText: passwordError,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _signInWithEmailPassword,
                      child: const Text("Sign In"),
                    ),
                  ],
                ),
              if (isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
