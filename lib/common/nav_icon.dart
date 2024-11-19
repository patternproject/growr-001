import 'package:flutter/material.dart';

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