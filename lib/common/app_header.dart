import 'package:flutter/material.dart';


class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
              // fontWeight: FontWeight.w600,
              color: Color(0xFF7E64ED),
            ),
          ),
        )
      ],
    );
  }
}