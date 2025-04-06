import 'package:civic/Login.dart';
import 'package:flutter/material.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  void initState() {
    super.initState();
    // Wait for 3 seconds before navigating to the Login page
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 101, 175),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logo.png",
                width: 500,
                height: 500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
