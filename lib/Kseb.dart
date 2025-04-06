import 'package:flutter/material.dart';
import 'package:civic/Filecomplaintkseb.dart';
import 'package:civic/KsebRequestservice.dart';
import 'package:civic/main.dart';
import 'package:civic/theam_provider.dart'; // Import ThemeProvider
import 'package:provider/provider.dart';

class KsebScreen extends StatefulWidget {
  const KsebScreen({super.key});

  @override
  _KsebScreenState createState() => _KsebScreenState();
}

class _KsebScreenState extends State<KsebScreen> {
  String? selectedKseb;

  List<Map<String, dynamic>> _districtlist = [];
  List<Map<String, dynamic>> _placelist = [];
  List<Map<String, dynamic>> _locallist = [];
  List<Map<String, dynamic>> _kseblist = [];

  @override
  void initState() {
    super.initState();
    fetchDistricts();
    fetchKSEB();
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

  Future<void> fetchKseb(String selectedLocal) async {
    try {
      final response = await supabase
          .from('Guest_tbl_kseb')
          .select()
          .eq('localplace_id', selectedLocal);

      setState(() {
        _kseblist = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  Future<void> fetchKSEB() async {
    try {
      final response = await supabase.from('Guest_tbl_kseb').select(
          '*, Admin_tbl_localplace(*, Admin_tbl_place(*, Admin_tbl_district(*)))');

      setState(() {
        _kseblist = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  String? selectedDistrict;
  String? selectedPlace;
  String? selectedLocal;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Column(
          children: [
            // Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage('assets/kseb-logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
              width: double.infinity,
              height: 350,
            ),
            const SizedBox(height: 16),

            // Welcome Text
            Text(
              "Welcome to the KSEB Page",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            // Lorem Ipsum Text
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white54 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 26),

            // Dropdown Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 18),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color:
                      isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black54 : Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // District Dropdown
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_city,
                          color: isDarkMode ? Colors.white70 : Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedDistrict,
                              hint: Text(
                                'District',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black,
                                ),
                              ),
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color:
                                    isDarkMode ? Colors.white70 : Colors.black,
                              ),
                              dropdownColor: isDarkMode
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.white,
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white70 : Colors.black,
                              ),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedDistrict = newValue;
                                  fetchPlaces(newValue!);
                                });
                              },
                              items: _districtlist.map((district) {
                                return DropdownMenuItem<String>(
                                  value: district['id'].toString(),
                                  child: Text(district['district_name']),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Vertical Divider
                  Container(
                    height: 40,
                    width: 1,
                    color: isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),

                  // Place Dropdown
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.place,
                          color: isDarkMode ? Colors.white70 : Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedPlace,
                              hint: Text(
                                'Place',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black,
                                ),
                              ),
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color:
                                    isDarkMode ? Colors.white70 : Colors.black,
                              ),
                              dropdownColor: isDarkMode
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.white,
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white70 : Colors.black,
                              ),
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
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Vertical Divider
                  Container(
                    height: 40,
                    width: 1,
                    color: isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),

                  // Local Place Dropdown
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.map,
                          color: isDarkMode ? Colors.white70 : Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedLocal,
                              hint: Text(
                                'Local Place',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black,
                                ),
                              ),
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color:
                                    isDarkMode ? Colors.white70 : Colors.black,
                              ),
                              dropdownColor: isDarkMode
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.white,
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white70 : Colors.black,
                              ),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedLocal = newValue;
                                  fetchKseb(newValue!);
                                });
                              },
                              items: _locallist.map((local) {
                                return DropdownMenuItem<String>(
                                  value: local['id'].toString(),
                                  child: Text(local['local_place']),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Display KSEB Stations as Cards
            Expanded(
              child: _kseblist.isNotEmpty
                  ? ListView.builder(
                      itemCount: _kseblist.length,
                      itemBuilder: (context, index) {
                        var kseb = _kseblist[index];
                        return Card(
                          elevation: 3,
                          color: isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : Colors.white,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kseb['kseb_name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "📧 Email: ${kseb['kseb_email']}",
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "📞 Contact: ${kseb['kseb_contact']}",
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "📍 Address: ${kseb['kseb_address'] ?? 'N/A'}, "
                                  "${kseb['Admin_tbl_localplace']?['local_place'] ?? 'N/A'}, "
                                  "${kseb['Admin_tbl_localplace']?['Admin_tbl_place']?['place_name'] ?? 'N/A'}, "
                                  "${kseb['Admin_tbl_localplace']?['Admin_tbl_place']?['Admin_tbl_district']?['district_name'] ?? 'N/A'}",
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // File Complaint Button
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedKseb =
                                              kseb['kseb_id'].toString();
                                        });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                KSEBFileComplaintPage(
                                              selectedKseb:
                                                  selectedKseb.toString(),
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 12, 101, 175),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: const Text("File Complaint"),
                                    ),
                                    const SizedBox(width: 10),
                                    // Request Service Button
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedKseb =
                                                kseb['kseb_id'].toString();
                                          });
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  KsebRequestService(
                                                      kseb: selectedKseb!),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isDarkMode
                                              ? const Color(0xFF2A2A2A)
                                              : Colors.white,
                                          foregroundColor: const Color.fromARGB(
                                              255, 12, 101, 175),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        child: const Text("Request Service"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No KSEB stations found.",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
