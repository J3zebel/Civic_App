import 'package:civic/main.dart';
import 'package:civic/theam_provider.dart'; // Corrected spelling
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:civic/form_validation.dart'; // Added to use FormValidation

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Added for form validation

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _userlist;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchuser();
  }

  Future<void> fetchuser() async {
    try {
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
          contactController.text = _userlist?['user_contact'] ?? '';
          addressController.text = _userlist?['user_address'] ?? '';
        });
      } else {
        print("User ID is null");
      }
    } catch (e) {
      print("Exception during fetch: $e");
    }
  }

  Future<void> edituser() async {
    if (!_formKey.currentState!.validate()) return; // Validate form

    setState(() {
      _isLoading = true;
    });

    try {
      final userid = supabase.auth.currentUser?.id;
      if (userid != null) {
        String? photoUrl;
        if (_profileImage != null) {
          photoUrl = await _uploadImage(_profileImage!, userid);
        }

        await supabase.from('Guest_tbl_user').update({
          'user_name': nameController.text,
          'user_contact': contactController.text,
          'user_address': addressController.text,
          if (photoUrl != null) 'user_photo': photoUrl,
          // Note: 'user_email' is excluded from update since it's read-only
        }).eq("user_id", userid);

        fetchuser();
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      }
    } catch (e) {
      print("Exception during update: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _profileImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      print("Image picking failed: $e");
    }
  }

  Future<String?> _uploadImage(File image, String userid) async {
    try {
      final folderName = "UserDocs";
      final fileName = '$folderName/user_$userid';

      await supabase.storage.from('civic').upload(fileName, image);
      final imageUrl = supabase.storage.from('civic').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeProvider.themeMode == ThemeMode.dark
                    ? [Colors.grey[800]!, Colors.grey[900]!]
                    : [
                        const Color.fromARGB(255, 124, 174, 214),
                        const Color.fromARGB(255, 156, 159, 201),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              image: _profileImage != null
                  ? DecorationImage(
                      image: FileImage(_profileImage!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.4), BlendMode.darken),
                    )
                  : (_userlist?['user_photo'] != null
                      ? DecorationImage(
                          image: NetworkImage(_userlist!['user_photo']),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.4), BlendMode.darken),
                        )
                      : null),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? Colors.grey[850]
                        : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          const SizedBox(height: 100),
                          _buildProfileField(
                              'Name', nameController, themeProvider,
                              validator: (value) =>
                                  FormValidation.validateName(value)),
                          const SizedBox(height: 20),
                          _buildProfileField(
                              'Email', emailController, themeProvider,
                              isEditable: false), // Email is read-only
                          const SizedBox(height: 20),
                          _buildProfileField(
                              'Contact', contactController, themeProvider,
                              validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your contact number';
                            }
                            if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                              return 'Please enter a valid 10-digit contact number';
                            }
                            return null;
                          }),
                          const SizedBox(height: 20),
                          _buildProfileField(
                              'Address', addressController, themeProvider,
                              validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          }),
                          const SizedBox(height: 20),
                          if (_isEditing)
                            ElevatedButton(
                              onPressed: _isLoading ? null : edituser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeProvider.themeMode ==
                                        ThemeMode.dark
                                    ? Colors.grey[700]
                                    : const Color.fromARGB(255, 12, 101, 175),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Save'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -80,
                  left: MediaQuery.of(context).size.width * 0.5 - 80,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (_userlist?['user_photo'] != null
                                    ? NetworkImage(_userlist!['user_photo'])
                                    : const AssetImage('assets/camera.png'))
                                as ImageProvider,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? Colors.grey[700]
                                    : Colors.white,
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 24,
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? Colors.white
                                    : const Color.fromARGB(255, 12, 101, 175),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.1,
            right: 20,
            child: FloatingActionButton(
              onPressed: _toggleEditMode,
              backgroundColor: themeProvider.themeMode == ThemeMode.dark
                  ? Colors.grey[700]
                  : Colors.white,
              child: Icon(
                Icons.edit,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? Colors.white
                    : const Color.fromARGB(255, 12, 101, 175),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 12, 101, 175)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller,
      ThemeProvider themeProvider,
      {String? Function(String?)? validator, bool isEditable = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[400]
                : Colors.grey,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          readOnly: !_isEditing || !isEditable, // Email is always read-only
          validator: validator,
          decoration: InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: themeProvider.themeMode == ThemeMode.dark
                    ? Colors.grey[600]!
                    : Colors.grey,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: themeProvider.themeMode == ThemeMode.dark
                    ? Colors.grey[600]!
                    : Colors.grey,
              ),
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            color: themeProvider.themeMode == ThemeMode.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
      ],
    );
  }
}
