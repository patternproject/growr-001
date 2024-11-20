import 'package:firebase_core/firebase_core.dart';
import 'package:growr/common/app_header.dart';
import 'package:growr/settings.dart';
import 'package:growr/signin.dart';
import 'auth_service.dart';
import 'common/main_scaffold.dart';
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
        '/home': (context) => const MyHomePage(title: 'GROWR - Home'),
        '/signin': (context) => MainScaffold(
              title: 'Sign In',
              body: SignInPage(title: 'Sign In'),
              header: getSignInHeader(),
            ),
        // Default route
        '/profile': (context) => const MainScaffold(
              title: 'Profile',
              body: ProfilePage(
                title: 'GROWR - Profile',
              ),
            ),
        '/services': (context) => const MainScaffold(
              title: 'Services',
              body: ServicesPage(
                title: 'GROWR - Services',
              ),
            ),
        '/loan-application': (context) => const MainScaffold(
              title: 'Loan Application',
              body: LoanApplicationPage(
                title: 'GROWR - Loan Application',
              ),
            ),
        '/loan-accept': (context) => const MainScaffold(
              title: 'Loan Accept',
              body: LoanAcceptPage(
                title: 'GROWR - Loan Accept',
              ),
            ),
        '/account': (context) => const MainScaffold(
              title: 'Account',
              body: AccountPage(
                title: 'GROWR - Account',
              ),
            ),
        '/account-home': (context) => const MainScaffold(
              title: 'Account',
              body: AccountHomePage(
                title: 'GROWR - Account Home',
              ),
            ),
        '/settings': (context) => const MainScaffold(
              title: 'Settings',
              body: SettingsScreen(),
            ),
      },
      initialRoute: '/home', // Specify the initial route
    );
  }

  getSignInHeader() {
    return Column(
        children: [AppHeader()]
    );
  }
}
