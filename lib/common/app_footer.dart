import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'nav_icon.dart';

class BottomFooterBar extends StatefulWidget {
  const BottomFooterBar({Key? key}) : super(key: key);

  @override
  State<BottomFooterBar> createState() => _BottomFooterBarState();
}

class _BottomFooterBarState extends State<BottomFooterBar> {
  bool isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSignInStatus(); // Check the user's sign-in status
  }

  // Check the sign-in status using FirebaseAuth
  void _checkSignInStatus() async {
    var user = FirebaseAuth.instance.currentUser;
    if (mounted) {
      setState(() {
        isSignedIn = user != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          // Other buttons are displayed only if the user is signed in
          if (isSignedIn) ...[
            // "Home" button is always displayed
            const NavIconButton(
              icon: Icons.home,
              label: 'Home',
              targetRoute: '/account',
            ),
            const NavIconButton(
              icon: Icons.account_balance,
              label: 'Account',
              targetRoute: '/loan-application',
            ),
            const NavIconButton(
              icon: Icons.person,
              label: 'Profile',
              targetRoute: '/profile',
            ),
            const NavIconButton(
              icon: Icons.man,
              label: 'services',
              targetRoute: '/services',
            ),
            const NavIconButton(
              icon: Icons.settings,
              label: 'Settings',
              targetRoute: '/settings',
            ),
          ],
        ],
      ),
    );
  }
}
