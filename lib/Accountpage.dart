import 'dart:ui';
import 'package:civic/Login.dart';
import 'package:civic/MyRequest.dart';
import 'package:civic/Mycomplaints.dart';
import 'package:civic/Myprofile.dart';
import 'package:civic/Password.dart';
import 'package:civic/main.dart';
import 'package:civic/theam_provider.dart'; // Assuming 'theam_provider.dart' is your ThemeProvider file
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  Map<String, dynamic>? _userlist;
  bool isLoading = true;

  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchuser();
  }

  Future<void> fetchuser() async {
    try {
      setState(() {
        isLoading = true;
      });
      final userid = supabase.auth.currentUser?.id;
      if (userid != null) {
        final response = await supabase
            .from('Guest_tbl_user')
            .select()
            .eq("user_id", userid)
            .single();
        setState(() {
          _userlist = response;
          nameController.text = _userlist?['user_name'] ?? '';
          emailController.text = _userlist?['user_email'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Exception during fetch: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching user data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 12, 101, 175),
        title: const Text(
          'Account Page',
          style: TextStyle(color: Colors.white),
        ),
        toolbarHeight: 70,
        actions: [
          IconButton(
            onPressed: () {
              themeProvider.toggleTheme();
            },
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
            ),
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Center(
                  child: Column(
                    children: [
                      isLoading
                          ? CircleAvatar(
                              radius: 70,
                              backgroundColor:
                                  isDarkMode ? Colors.grey[800] : Colors.grey,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : CircleAvatar(
                              radius: 70,
                              backgroundImage: NetworkImage(
                                _userlist?['user_photo'] ?? '',
                              ),
                              onBackgroundImageError: (_, __) => const Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.grey,
                              ),
                            ),
                      const SizedBox(height: 20),
                      isLoading
                          ? Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode ? Colors.white70 : Colors.black,
                              ),
                            )
                          : Text(
                              _userlist?['user_name'] ?? '',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode ? Colors.white70 : Colors.black,
                              ),
                            ),
                      const SizedBox(height: 5),
                      isLoading
                          ? Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isDarkMode ? Colors.white70 : Colors.black,
                              ),
                            )
                          : Text(
                              _userlist?['user_email'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isDarkMode ? Colors.white70 : Colors.black,
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildListTile(
                  icon: Icons.person,
                  title: 'My Profile',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyProfile(),
                    ),
                  ),
                  isDarkMode: isDarkMode,
                ),
                _buildListTile(
                  icon: Icons.lock,
                  title: 'Password',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Password(),
                    ),
                  ),
                  isDarkMode: isDarkMode,
                ),
                _buildListTile(
                  icon: Icons.report,
                  title: 'My Complaints',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyComplaintsPage(),
                    ),
                  ),
                  isDarkMode: isDarkMode,
                ),
                _buildListTile(
                  icon: Icons.request_page,
                  title: 'My Requests',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Myrequest(),
                    ),
                  ),
                  isDarkMode: isDarkMode,
                ),
                _buildListTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: logout,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode
            ? const Color.fromARGB(255, 12, 101, 175)
            : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
      ),
      onTap: onTap,
      tileColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
