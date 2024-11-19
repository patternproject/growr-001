import 'package:flutter/material.dart';
import 'package:growr/signin.dart';

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
          '/signin'
        );
      },
      child: Scaffold(
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
              Text(
                'Welcome',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'to',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'G R OW R',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 48,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/logo.png', // Ensure your app logo is in the assets folder
                width: 150,
                height: 150,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
