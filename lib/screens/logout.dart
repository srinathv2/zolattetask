import 'package:flutter/material.dart';
import 'package:zolattetask/FirebaseServices.dart';
import 'package:zolattetask/main.dart';

class Logout extends StatefulWidget {
  const Logout({super.key});

  @override
  State<Logout> createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
          child: Text('Logout'),
          onPressed: () {
            FireBaseServices().signout();
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
    );
  }
}
