import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Function to get app info like version and build number
  Future<String> _getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version + " (" + packageInfo.buildNumber + ")";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(  // Center everything in the screen
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  // Center content vertically
            crossAxisAlignment: CrossAxisAlignment.center,  // Center content horizontally
            children: [
              // Application logo
              Image.asset(
                'assets/images/logo.png', // Ensure your app logo is in the assets folder
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),

              // Application name
              const Text(
                "GROWR",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Build number and version
              FutureBuilder<String>(
                future: _getAppInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text("Error fetching app info");
                  } else {
                    return Text(
                      "Version: ${snapshot.data}",
                      style: const TextStyle(fontSize: 16),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              // Copyright message with current year
              Text(
                "© ${DateTime.now().year} GROWR. All rights reserved.",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


