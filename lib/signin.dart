import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _emailController = TextEditingController(text: 'asif.diginuance@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: 'growr2024');

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
    if (mounted) {  // Ensure that the widget is still mounted before calling setState
      setState(() {
        isSignedIn = user != null;
      });

      // If the user is already signed in, navigate to the profile page
      if (user != null) {
        await createProfileInCaseNoUser(user.email ?? '');  // Ensure profile exists or create it
        Navigator.pushReplacementNamed(context, '/profile');  // Navigate to the profile page
      }
    }
  }

  // Handle Sign-out
  void _signOut() async {
    await _authService.signOut();
    if (mounted) {
      setState(() {
        isSignedIn = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signed out")));
    }
  }

  // Handle Google Sign-In
  void _signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      var user = await _authService.signInWithGoogle();
      if (mounted) {
        if (user != null) {
          setState(() {
            isLoading = false;
            isSignedIn = true;
          });
          await createProfileInCaseNoUser(user.email ?? 'muasif80+test1@gmail.com');
          // Navigate to another screen after successful login
          Navigator.pushReplacementNamed(context, '/profile');
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sign-in failed")));
        }
      }
    } catch (e, stackTrace) {
      print("Error during Google sign-in: $e");
      if (e is PlatformException) {
        print("PlatformException details:");
        print("Code: ${e.code}");
        print("Message: ${e.message}");
        print("Details: ${e.details}");
      }
    }
  }

  // Handle Email/Password Sign-In
  void _signInWithEmailPassword() async {
    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        if (userCredential.user != null) {
          setState(() {
            isLoading = false;
            isSignedIn = true;
          });
          await createProfileInCaseNoUser(userCredential.user?.email ?? '');
          // Navigate to the profile screen after successful login
          Navigator.pushReplacementNamed(context, '/profile');
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sign-in failed")));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  // Create profile only if it doesn't already exist
  Future createProfileInCaseNoUser(String email) async {
    // Check if a profile with the given email already exists
    var querySnapshot = await FirebaseFirestore.instance
        .collection('profiles')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // If no profile is found, create a new one
      await FirebaseFirestore.instance.collection('profiles').add({
        'email': email,
      });
      print("Profile created for $email");
    } else {
      print("Profile already exists for $email");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (!isSignedIn) // Show if the user is not signed in
                Column(
                  children: [
                    // Email input field
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Password input field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Sign In button for email/password
                    ElevatedButton(
                      onPressed: _signInWithEmailPassword,
                      child: Text("Sign In"),
                    ),
                    SizedBox(height: 16),
                    // Sign in with Google button (kept as is)
                    ElevatedButton(
                      onPressed: _signInWithGoogle,
                      child: Text("Sign in with Google"),
                    ),
                  ],
                ),
              if (isLoading) // Show loading indicator while signing in
                const CircularProgressIndicator(),
            ],
          ),
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
