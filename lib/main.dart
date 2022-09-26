import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zolattetask/screens/delete.dart';
import 'package:zolattetask/screens/logout.dart';
import 'FirebaseServices.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zolattetask/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: Scaffold(
      body: MyApp(),
      backgroundColor: Colors.black,
    ),
    routes: {
      '/home': (context) => Home(),
      '/logout': (context) => Logout(),
      '/delete': (context) => DeleteAccount()
    },
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 50,
        child: ElevatedButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FaIcon(FontAwesomeIcons.google),
              Text('Login with google')
            ],
          ),
          onPressed: (() async {
            try {
              await FireBaseServices().siginWithGoogle();
              Navigator.pushNamed(context, '/home');
            } catch (e) {
              throw e;
            }
          }),
        ),
      ),
    );
  }
}
