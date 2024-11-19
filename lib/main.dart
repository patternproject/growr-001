import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_service.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:growr/screens/account.dart';
import 'package:growr/screens/account_home.dart';
import 'package:growr/screens/loan_accept.dart';
import 'package:growr/screens/loan_application.dart';
import 'package:growr/screens/profile.dart';
import 'package:growr/screens/services.dart';

import 'home.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // await Firebase.initializeApp();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//   try {
//     await firestore.collection('profiles').add({
//       'email': 'muasif80@gmail.com',
//       'message': 'Hello from standalone test',
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//     print('Data added successfully!');
//   } catch (e) {
//     print('Error adding data: $e');
//   }
// }

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();  // Initialize Firebase
  // runApp(MyApp());

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/home': (context) =>
            const MainScaffold(body: MyHomePage(title: 'GROWR - Home')),
        // Default route
        '/profile': (context) => const MainScaffold(
              body: ProfilePage(
                title: 'GROWR - Profile',
              ),
            ),
        '/services': (context) => const MainScaffold(
              body: ServicesPage(
                title: 'GROWR - Services',
              ),
            ),
        '/loan-application': (context) => const MainScaffold(
              body: LoanApplicationPage(
                title: 'GROWR - Loan Application',
              ),
            ),
        '/loan-accept': (context) => const MainScaffold(
              body: LoanAcceptPage(
                title: 'GROWR - Loan Accept',
              ),
            ),
        '/account': (context) => const MainScaffold(
              body: AccountPage(
                title: 'GROWR - Account',
              ),
            ),
        '/account-home': (context) => const MainScaffold(
              body: AccountHomePage(
                title: 'GROWR - Account Home',
              ),
            ),
      },
      initialRoute: '/home', // Specify the initial route
    );
  }
}

class MainScaffold extends StatefulWidget {
  final Widget body;

  const MainScaffold({super.key, required this.body});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final AuthService _authService = AuthService();
  // bool isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('GROWR'),
      //   centerTitle: true, // Center the title
      // ),
      body: widget.body, // Dynamic body content based on route
      bottomNavigationBar: BottomFooterBar(),
    );
  }
}

class BottomFooterBar extends StatelessWidget {
  const BottomFooterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavIconButton(
            icon: Icons.home,
            label: 'Home',
            targetRoute: '/home',
          ),
          NavIconButton(
            icon: Icons.account_balance,
            label: 'Accounts',
            targetRoute: '/account-home',
          ),
          NavIconButton(
            icon: Icons.person,
            label: 'Profile',
            targetRoute: '/profile',
          ),
          NavIconButton(
            icon: Icons.accessibility,
            label: 'Services',
            targetRoute: '/services',
          ),
          NavIconButton(
            icon: Icons.settings,
            label: 'Settings',
            targetRoute: '/profile',
          ),
        ],
      ),
    );
  }
}

class NavIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String targetRoute;

  const NavIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.targetRoute,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, targetRoute);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // Center content vertically
        crossAxisAlignment: CrossAxisAlignment.center,
        // Center content horizontally
        children: [
          Icon(
            icon,
            size: 32, // 4 times the default icon size (default is 24)
            color: Colors.blue,
            // You can change the icon color
          ),
          const SizedBox(height: 4), // Space between the icon and the label
          Text(
            label,
            style: const TextStyle(
              fontSize: 14, // Adjust the label font size
              fontWeight: FontWeight.bold, // Bold the label
            ),
            textAlign: TextAlign.center, // Center-align the text
          ),
        ],
      ),
    );
  }
}
