import 'package:flutter/material.dart';

import '../auth_service.dart';
import 'app_footer.dart';

class MainScaffold extends StatefulWidget {
  final Widget body;
  final String title;

  const MainScaffold({super.key, required this.body, required this.title});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final AuthService _authService = AuthService();

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

  // Handle logout and navigate to the sign-in screen
  void _handleLogout() async {
    if (isSignedIn) {
      await _authService.signOut(); // Log out the user
      setState(() {
        isSignedIn = false; // Update sign-in status
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Signed out")));
    }
    Navigator.pushReplacementNamed(
        context, '/signin'); // Navigate to SignInPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text(widget.title),
        centerTitle: true, // Center the title
        actions: [
          IconButton(
            onPressed: _handleLogout, // Use the logout function
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Image.asset(
                  'assets/images/logo.png',
                  // Ensure your app logo is in the assets folder
                  width: 60,
                  height: 60,
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 60.0),
                child: Text(
                  'GROWR',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFBAACF6),
                  ),
                ),
              )
            ],
          ),
          Expanded(child: widget.body),
        ],
      ), // Dynamic body content based on route
      bottomNavigationBar: BottomFooterBar(),
    );
  }
}
