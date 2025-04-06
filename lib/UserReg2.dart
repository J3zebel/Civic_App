// Import necessary packages
import 'package:civic/form_validation.dart';
import 'package:civic/main.dart';
import 'package:flutter/material.dart'; // Flutter UI framework

class Registration1 extends StatefulWidget {
  const Registration1({super.key}); // Constructor for the widget

  @override
  State<Registration1> createState() => _Registration1State();
}

class _Registration1State extends State<Registration1> {
  // Define text controllers for form fields
  final TextEditingController address = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    fetchDistricts(); // Fetch districts when the widget initializes
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

  Future<void> _register() async {
    try {
      await supabase.from('Guest_tbl_user').insert({
        'user_address': address.text,
        'district_id': selectedDistrict,
        'place_id': selectedPlace,
        'localplace_id': selectedLocal,
        'muncipality_id': selectedMunicipality,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful')),
      );
    } catch (e) {
      print('Registration failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Locality"),
        backgroundColor: const Color.fromARGB(255, 12, 101, 175),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                validator: (value) => FormValidation.validateAddress(value),
                controller: address,
                minLines: 3,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(),
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
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Place',
                  border: OutlineInputBorder(),
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
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Local Place',
                  border: OutlineInputBorder(),
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
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Municipality',
                  border: OutlineInputBorder(),
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
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _register();
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
