import 'package:civic/main.dart';
import 'package:civic/theam_provider.dart'; // Ensure correct spelling: 'theme_provider.dart'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Password extends StatefulWidget {
  const Password({super.key});

  @override
  _PasswordState createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String oldP = "";

  Future<void> fetchpass() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('Guest_tbl_user')
          .select()
          .eq('user_id', uid)
          .single();
      setState(() {
        oldP = response['user_password'];
      });
    } catch (e) {
      print("Error fetching data:$e");
    }
  }

  Future<void> updatePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        String uid = supabase.auth.currentUser!.id;
        if (oldPasswordController.text != oldP) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Old password is incorrect'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await supabase.auth.updateUser(
          UserAttributes(
            password: newPasswordController.text,
          ),
        );

        await supabase.from('Guest_tbl_user').update(
            {'user_password': newPasswordController.text}).eq('user_id', uid);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Password Updated',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating password: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchpass();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 101, 175),
        elevation: 5,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
              maxHeight: 500,
            ),
            child: Card(
              color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Old Password TextField
                      TextFormField(
                        controller: oldPasswordController,
                        obscureText: !_isOldPasswordVisible,
                        style: TextStyle(
                            color:
                                isDarkMode ? Colors.white70 : Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Old Password',
                          labelStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[600]),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 12, 101, 175)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isOldPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _isOldPasswordVisible = !_isOldPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your old password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // New Password TextField
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: !_isNewPasswordVisible,
                        style: TextStyle(
                            color:
                                isDarkMode ? Colors.white70 : Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[600]),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 12, 101, 175)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isNewPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your new password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password TextField
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        style: TextStyle(
                            color:
                                isDarkMode ? Colors.white70 : Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[600]),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 12, 101, 175)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // Save and Cancel Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                const Color.fromARGB(255, 12, 101, 175),
                              ),
                              foregroundColor:
                                  WidgetStateProperty.all(Colors.white),
                              padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12)),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            onPressed: updatePassword,
                            child: const Text('Save',
                                style: TextStyle(fontSize: 16)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
