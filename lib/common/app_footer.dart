import 'package:flutter/material.dart';

import 'nav_icon.dart';

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
            label: 'Account',
            targetRoute: '/account-home',
          ),
          NavIconButton(
            icon: Icons.person,
            label: 'Profile',
            targetRoute: '/profile',
          ),
          NavIconButton(
            icon: Icons.settings,
            label: 'Settings',
            targetRoute: '/settings',
          ),
        ],
      ),
    );
  }
}
