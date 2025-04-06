import 'package:civic/Filecomplaintpwd.dart';
import 'package:civic/main.dart';
import 'package:civic/theam_provider.dart'; // Import ThemeProvider
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PwdScreen extends StatefulWidget {
  const PwdScreen({super.key});

  @override
  _PwdScreenState createState() => _PwdScreenState();
}

class _PwdScreenState extends State<PwdScreen> {
  String? selectedDistrict;
  String? selectedPwd;

  List<Map<String, dynamic>> _districtlist = [];
  List<Map<String, dynamic>> _pwdlist = [];

  @override
  void initState() {
    super.initState();
    fetchDistricts();
    pwddisplay();
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

  Future<void> fetchPWD(String districtId) async {
    try {
      final response = await supabase
          .from('Guest_tbl_pwd')
          .select('*, Admin_tbl_district(*)')
          .eq('district_id', districtId);

      setState(() {
        _pwdlist = response;
      });
    } catch (e) {
      print('Error fetching PWD offices: $e');
    }
  }

  Future<void> pwddisplay() async {
    try {
      final response = await supabase
          .from('Guest_tbl_pwd')
          .select('*, Admin_tbl_district(*)');

      setState(() {
        _pwdlist = response;
      });
    } catch (e) {
      print('Error fetching PWD offices: $e');
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: AssetImage('assets/pwd-logo.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  width: double.infinity,
                  height: 350,
                ),
                const SizedBox(height: 16),
                Text(
                  "Welcome to the PWD Page",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white70 : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam.",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  width: 200,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade200,
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
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black,
                                  ),
                                  dropdownColor: isDarkMode
                                      ? const Color(0xFF2A2A2A)
                                      : Colors.white,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black,
                                  ),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedDistrict = newValue;
                                      fetchPWD(
                                          newValue!); // Fetch filtered PWDs
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
              ],
            ),
            Expanded(
              child: _pwdlist.isNotEmpty
                  ? ListView.builder(
                      itemCount: _pwdlist.length,
                      itemBuilder: (context, index) {
                        var pwd = _pwdlist[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                          color: isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pwd['pwd_name'],
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
                                  "📧 Email: ${pwd['pwd_email']}",
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  "📞 Contact: ${pwd['pwd_contact']}",
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  "📍 Address: ${pwd['pwd_address']}, "
                                  "${pwd['Admin_tbl_district']?['district_name'] ?? 'N/A'}",
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.center,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedPwd = pwd['pwd_id'].toString();
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PWDComplaintPage(
                                            selectedPwd: selectedPwd!,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 12, 101, 175),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text("File Complaint"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No PWD offices found.",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
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
