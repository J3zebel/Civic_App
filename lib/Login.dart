import 'package:civic/Homepage.dart';
import 'package:civic/UserRegistration.dart';
import 'package:civic/form_validation.dart';
import 'package:civic/main.dart';
import 'package:civic/theam_provider.dart'; // Update to correct spelling
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> signIn() async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email.text,
        password: password.text,
      );
      final User? user = res.user;
      print(user);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    "assets/civic.png",
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Please sign in to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.blueGrey.withOpacity(0.3)
                                : const Color.fromARGB(255, 72, 182, 255),
                            spreadRadius: -10,
                            blurRadius: 6,
                            offset: const Offset(2, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) =>
                              FormValidation.validateEmail(value),
                          controller: email,
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDarkMode
                                ? const Color(0xFF2C2C2C)
                                : Colors.white,
                            labelText: "E-mail",
                            labelStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  style: BorderStyle.none, width: 0),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            contentPadding: const EdgeInsets.only(left: 60),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 1,
                      top: 4,
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkMode
                              ? const Color(0xFF2C2C2C)
                              : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.blueGrey.withOpacity(0.3)
                                  : const Color.fromARGB(255, 72, 182, 255),
                              spreadRadius: -3,
                              blurRadius: 8,
                              offset: const Offset(2, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.email_outlined,
                          color: isDarkMode
                              ? Colors.blueGrey
                              : const Color.fromARGB(255, 72, 182, 255),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.blueGrey.withOpacity(0.3)
                                : const Color.fromARGB(255, 72, 182, 255),
                            spreadRadius: -10,
                            blurRadius: 6,
                            offset: const Offset(2, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) =>
                              FormValidation.validatePassword(value),
                          controller: password,
                          obscureText: true,
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDarkMode
                                ? const Color(0xFF2C2C2C)
                                : Colors.white,
                            labelText: "Password",
                            labelStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  style: BorderStyle.none, width: 0),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            contentPadding: const EdgeInsets.only(left: 60),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 1,
                      top: 4,
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkMode
                              ? const Color(0xFF2C2C2C)
                              : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.blueGrey.withOpacity(0.3)
                                  : const Color.fromARGB(255, 72, 182, 255),
                              spreadRadius: -3,
                              blurRadius: 8,
                              offset: const Offset(2, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          color: isDarkMode
                              ? Colors.blueGrey
                              : const Color.fromARGB(255, 72, 182, 255),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Registration()),
                        );
                      },
                      child: Text(
                        "Create an account",
                        style: TextStyle(
                            color: isDarkMode ? Colors.blueGrey : Colors.blue),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                            color: isDarkMode ? Colors.blueGrey : Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      signIn();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? const Color(0xFF0C65AF)
                        : null, // Blue in dark mode, default in light mode
                  ),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
