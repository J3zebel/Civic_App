import 'dart:io';
import 'package:civic/Login.dart';
import 'package:civic/form_validation.dart';
import 'package:civic/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  // Text controllers for form fields
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController contact = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController address = TextEditingController();

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Image handling
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Data lists for dropdown menus
  List<Map<String, dynamic>> _districtlist = [];
  List<Map<String, dynamic>> _placelist = [];
  List<Map<String, dynamic>> _locallist = [];
  List<Map<String, dynamic>> _muncipalitylist = [];

  // Variables to store user selections from dropdowns
  String? selectedDistrict;
  String? selectedPlace;
  String? selectedLocal;
  String? selectedMunicipality;

  @override
  void initState() {
    super.initState();
    fetchDistricts();
  }

  Future<void> fetchDistricts() async {
    try {
      final response = await supabase.from('Admin_tbl_district').select();
      setState(() {
        _districtlist = response;
      });
    } catch (e) {
      print('Error fetching districts: $e');
    }
  }

  Future<void> fetchPlaces(String districtId) async {
    try {
      final response = await supabase
          .from('Admin_tbl_place')
          .select()
          .eq('district_id', districtId);
      setState(() {
        _placelist = response;
        selectedPlace = null;
        selectedLocal = null;
      });
    } catch (e) {
      print('Error fetching places: $e');
    }
  }

  Future<void> fetchLocalPlaces(String placeId) async {
    try {
      final response = await supabase
          .from('Admin_tbl_localplace')
          .select()
          .eq('place_id', placeId);
      setState(() {
        _locallist = response;
        selectedLocal = null;
      });
    } catch (e) {
      print('Error fetching local places: $e');
    }
  }

  Future<void> fetchMunicipalities(String districtId) async {
    try {
      final response = await supabase
          .from('Guest_tbl_muncipality')
          .select()
          .eq('district_id', districtId);
      setState(() {
        _muncipalitylist = response;
        selectedMunicipality = null;
      });
    } catch (e) {
      print('Error fetching municipalities: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image, String userId) async {
    try {
      final folderName = "UserDocs";
      final fileName = '$folderName/user_$userId';
      await supabase.storage.from('civic').upload(fileName, image);
      final imageUrl = supabase.storage.from('civic').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> _registration() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Step 1: Sign up with Supabase Authentication
      final AuthResponse response = await supabase.auth.signUp(
        email: email.text,
        password: password.text,
      );

      final User? user = response.user;
      if (user != null) {
        String fullName = name.text;
        String firstName = fullName.split(' ').first;
        await supabase.auth.updateUser(UserAttributes(
          data: {'display_name': firstName},
        ));

        final String userId = user.id;

        // Step 2: Upload profile photo (if selected)
        String? photoUrl;
        if (_image != null) {
          photoUrl = await _uploadImage(_image!, userId);
        }

        // Step 3: Insert user details including locality into Guest_tbl_user
        await supabase.from('Guest_tbl_user').insert({
          'user_id': userId,
          'user_name': name.text,
          'user_contact': contact.text,
          'user_email': email.text,
          'user_photo': photoUrl,
          'user_password': password.text,
          'user_address': address.text,
          'localplace_id': selectedLocal,
          'muncipality_id': selectedMunicipality,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Created Successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up failed')),
        );
      }
    } catch (e) {
      print('Registration failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration"),
        backgroundColor: const Color.fromARGB(255, 12, 101, 175),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Create Your Profile",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color.fromARGB(255, 223, 223, 223),
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(Icons.person,
                              color: Colors.grey, size: 50)
                          : null,
                    ),
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child:
                          const Icon(Icons.edit, size: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                validator: (value) => FormValidation.validateName(value),
                controller: name,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  labelText: "Username",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                validator: (value) => FormValidation.validateEmail(value),
                controller: email,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  labelText: "E-mail",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                validator: (value) => FormValidation.validateContact(value),
                controller: contact,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.call),
                  labelText: "Contact",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                validator: (value) => FormValidation.validatePassword(value),
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: "Password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Locality Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                validator: (value) => FormValidation.validateAddress(value),
                controller: address,
                minLines: 3,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                value: selectedDistrict,
                hint: const Text('Select a district'),
                onChanged: (newValue) {
                  setState(() {
                    selectedDistrict = newValue;
                    fetchPlaces(newValue!);
                    fetchMunicipalities(newValue);
                  });
                },
                items: _districtlist.map((district) {
                  return DropdownMenuItem<String>(
                    value: district['id'].toString(),
                    child: Text(district['district_name']),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select a district' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Place',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                value: selectedPlace,
                hint: const Text('Select a place'),
                onChanged: (newValue) {
                  setState(() {
                    selectedPlace = newValue;
                    fetchLocalPlaces(newValue!);
                  });
                },
                items: _placelist.map((place) {
                  return DropdownMenuItem<String>(
                    value: place['id'].toString(),
                    child: Text(place['place_name']),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select a place' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Local Place',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                value: selectedLocal,
                hint: const Text('Select a local place'),
                onChanged: (newValue) {
                  setState(() {
                    selectedLocal = newValue;
                  });
                },
                items: _locallist.map((local) {
                  return DropdownMenuItem<String>(
                    value: local['id'].toString(),
                    child: Text(local['local_place']),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select a local place' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Municipality',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                value: selectedMunicipality,
                hint: const Text('Select a municipality'),
                onChanged: (newValue) {
                  setState(() {
                    selectedMunicipality = newValue;
                  });
                },
                items: _muncipalitylist.map((municipality) {
                  return DropdownMenuItem<String>(
                    value: municipality['mun_id'].toString(),
                    child: Text(municipality['mun_name']),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select a municipality' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 12, 101, 175),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _registration,
                child: const Text(
                  "Register",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
