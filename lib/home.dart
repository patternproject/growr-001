import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  bool isSignedIn = false;

  @override
  void initState() {
    super.initState();
    // Check sign-in status when the app starts
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the login screen on tap
        Navigator.pushNamed(
          context,
          '/signin',
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFD3CAF9), // Set the background color here
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                'to',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                'G R OW R',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 48,
                  color: Color(0xFF7E64ED),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/logo.png', // Ensure your app logo is in the assets folder
                width: 100,
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
