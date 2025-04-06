import 'dart:io';
import 'package:civic/main.dart';
import 'package:civic/theam_provider.dart'; // Ensure correct spelling: 'theme_provider.dart'
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MvdRequestService extends StatefulWidget {
  final String mvd;
  const MvdRequestService({super.key, required this.mvd});

  @override
  State<MvdRequestService> createState() => _MvdRequestServiceState();
}

class _MvdRequestServiceState extends State<MvdRequestService> {
  String? _selectedRequestType;
  File? _selectedImage;
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _requestTypes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRequestTypes();
  }

  Future<void> _fetchRequestTypes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase.from("Admin_tbl_mvdrequesttype").select();
      setState(() {
        _requestTypes = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
      print("response$response");
    } catch (e) {
      print("Fetching request types error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    setState(() {
      isLoading = true;
    });

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      isLoading = false;
    });

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    setState(() {
      isLoading = true;
    });

    try {
      final folderName = "RequestDocs";
      final fileName =
          "$folderName/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}";

      await supabase.storage.from('civic').upload(fileName, image);
      return supabase.storage.from('civic').getPublicUrl(fileName);
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _Request() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userid = supabase.auth.currentUser?.id;
      if (userid != null) {
        String? photoUrl;
        if (_selectedImage != null) {
          photoUrl = await _uploadImage(_selectedImage!);
        }

        await supabase.from('User_tbl_request').insert({
          'request_content': _descriptionController.text,
          'user_id': userid,
          'mvd_id': widget.mvd,
          'request_date': DateTime.now().toIso8601String(),
          'request_photo': photoUrl,
          'mvdrequesttype_id': _selectedRequestType,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Requested Successfully")),
        );
      }
    } catch (e) {
      print("Inserting Error : $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MVD Request Service',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0C65AF),
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[100],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Request Type Section
                  Text(
                    'Request Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode ? Colors.white70 : const Color(0xFF0C65AF),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color:
                          isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.grey.withOpacity(isDarkMode ? 0.1 : 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      value: _selectedRequestType,
                      hint: Text(
                        'Select a request type',
                        style: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey),
                      ),
                      items: _requestTypes.map((type) {
                        return DropdownMenuItem(
                          value: type['id'].toString(),
                          child: Text(
                            type['request_type'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRequestType = value;
                        });
                      },
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: isDarkMode
                            ? Colors.white70
                            : const Color(0xFF0C65AF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Request Description Section
                  Text(
                    'Request Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode ? Colors.white70 : const Color(0xFF0C65AF),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color:
                          isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.grey.withOpacity(isDarkMode ? 0.1 : 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Describe your request',
                        hintStyle: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Image Section
                  Text(
                    'Attach Image (Optional)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode ? Colors.white70 : const Color(0xFF0C65AF),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color:
                            isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.grey.withOpacity(isDarkMode ? 0.1 : 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.image,
                            color: isDarkMode
                                ? Colors.white70
                                : const Color(0xFF0C65AF),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedImage != null
                                  ? _selectedImage!.path.split('/').last
                                  : 'No file chosen',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedImage != null
                                    ? (isDarkMode
                                        ? Colors.white
                                        : Colors.black87)
                                    : (isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  Center(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _Request,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C65AF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0C65AF)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
