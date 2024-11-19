import 'package:flutter/material.dart';

class AccountHomePage extends StatefulWidget {
  const AccountHomePage({super.key, required this.title});
  final String title;

  @override
  State<AccountHomePage> createState() => _AccountHomePageState();
}

class _AccountHomePageState extends State<AccountHomePage> {

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[IconButton(onPressed: () {
          Navigator.pushNamed(context, '/home');
        }, icon: Icon(Icons.home)),]
      ),
      body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              MyButton(route: '/loan-application', title: 'Loan Application'),
              MyButton(route: '/loan-accept', title: 'Accept Loan'),
              MyButton(route: '/account', title: 'Account'),
            ],
          ),

      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final String route;
  final String title;

  const MyButton({
    super.key,
    required this.route,
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, route);
          },
          child: Text(title, style: const TextStyle(fontSize: 24),)
      ),
    );
  }
}


// class NavIconButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String targetRoute;
//
//   const NavIconButton({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.targetRoute,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       icon: Icon(icon),
//       onPressed: () {
//         Navigator.pushNamed(context, targetRoute);
//       },
//       tooltip: label,
//     );
//   }
// }