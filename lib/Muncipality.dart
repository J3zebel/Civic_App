import 'package:civic/Filecomplaintmun.dart';
import 'package:civic/main.dart';
import 'package:civic/theam_provider.dart'; // Import ThemeProvider
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MunicipalityScreen extends StatefulWidget {
  const MunicipalityScreen({super.key});

  @override
  _MunicipalityScreenState createState() => _MunicipalityScreenState();
}

class _MunicipalityScreenState extends State<MunicipalityScreen> {
  final TextEditingController local = TextEditingController();
  String? selectedDistrict;

  List<Map<String, dynamic>> _districtlist = [];
  List<Map<String, dynamic>> _munlist = [];

  @override
  void initState() {
    super.initState();
    fetchDistricts();
    fetchmun();
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

  Future<void> fetchmuncipality(String selectedDistrict) async {
    try {
      final response = await supabase
          .from('Guest_tbl_muncipality')
          .select('*, Admin_tbl_district(*)')
          .eq('district_id', selectedDistrict);
      setState(() {
        _munlist = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  Future<void> fetchmun() async {
    try {
      final response = await supabase
          .from('Guest_tbl_muncipality')
          .select('*, Admin_tbl_district(*)');
      setState(() {
        _munlist = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Municipality Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage('assets/muncipality-logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
              width: double.infinity,
              height: 250,
            ),
            const SizedBox(height: 16),

            // Welcome Text
            Text(
              "Welcome to the Municipality Page",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Info Text
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam.",
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white54 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // District Dropdown (Circular Box)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              width: 200,
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
                                  fetchmuncipality(
                                      newValue!); // Fetch filtered municipalities
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
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Municipality List with Buttons Inside Each Card
            Expanded(
              child: _munlist.isNotEmpty
                  ? ListView.builder(
                      itemCount: _munlist.length,
                      itemBuilder: (context, index) {
                        var muncipality = _munlist[index];
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
                                  muncipality['mun_name'],
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
                                  "📧 Email: ${muncipality['mun_email'] ?? 'N/A'}",
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "📞 Contact: ${muncipality['mun_contact'] ?? 'N/A'}",
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "📍 Address: ${muncipality['mun_address'] ?? 'N/A'}, "
                                  "${muncipality['Admin_tbl_district']?['district_name'] ?? 'N/A'}",
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Buttons inside each card
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MunicipalityComplaintPage(
                                              selectedMun:
                                                  muncipality['mun_id'],
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 12, 101, 175),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text("File Complaint"),
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
                        "No Municipality found.",
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
