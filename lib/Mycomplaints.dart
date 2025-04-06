import 'package:civic/Complaintupdate.dart';
import 'package:civic/theam_provider.dart'; // Import ThemeProvider
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:civic/main.dart';
import 'package:provider/provider.dart';

class MyComplaintsPage extends StatefulWidget {
  const MyComplaintsPage({super.key});

  @override
  State<MyComplaintsPage> createState() => _MyComplaintsPageState();
}

class _MyComplaintsPageState extends State<MyComplaintsPage> {
  List<Map<String, dynamic>> _complaintlist = [];
  late DateTime currentDate;

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    fetchcomplaint();
  }

  Future<void> fetchcomplaint() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        print('User is not logged in.');
        return;
      }
      final response = await supabase
          .from('User_tbl_complaint')
          .select()
          .eq('user_id', userId);

      setState(() {
        _complaintlist = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  String _getComplaintType(Map<String, dynamic> request) {
    if (request['kseb_id'] != null) return 'KSEB';
    if (request['mvd_id'] != null) return 'MVD';
    if (request['muncipality_id'] != null) return 'Municipality';
    if (request['pwd_id'] != null) return 'PWD';
    return 'Unknown';
  }

  List<DateTime> _generateWeekDates() {
    DateTime startOfWeek =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'In Progress';
      case 2:
        return 'Resolved';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    List<DateTime> weekDates = _generateWeekDates();

    String formattedDate = DateFormat('dd-MM-yyyy').format(currentDate);
    String formattedDay = DateFormat('EEEE').format(currentDate);

    return Scaffold(
      backgroundColor: themeProvider.themeMode == ThemeMode.dark
          ? Colors.grey[900]
          : Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? Colors.grey[400]
                        : Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  formattedDay,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? Colors.blue[300]
                        : Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weekDates.map((date) {
                bool isToday = DateFormat('yyyy-MM-dd').format(date) ==
                    DateFormat('yyyy-MM-dd').format(currentDate);

                return Column(
                  children: [
                    Text(
                      DateFormat('EEE').format(date),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: isToday
                            ? (themeProvider.themeMode == ThemeMode.dark
                                ? Colors.blue[700]
                                : Colors.blue.shade700)
                            : (themeProvider.themeMode == ThemeMode.dark
                                ? Colors.grey[800]
                                : Colors.grey.shade300),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        DateFormat('d').format(date),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? (isToday ? Colors.white : Colors.white70)
                              : (isToday ? Colors.white : Colors.black),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: _complaintlist.isEmpty
                ? Center(
                    child: Text(
                      "No complaints found.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? Colors.grey[400]
                            : Colors.grey,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      itemCount: _complaintlist.length,
                      itemBuilder: (context, index) {
                        final complaint = _complaintlist[index];
                        final status = complaint['status'] ?? 0;

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? Colors.grey[850]
                              : Colors.white,
                          shadowColor: Colors.blueGrey.withOpacity(0.5),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Complaint ID: ${complaint['id']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: themeProvider.themeMode ==
                                                ThemeMode.dark
                                            ? Colors.blue[300]
                                            : Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Type: ${_getComplaintType(complaint)}',
                                  style: TextStyle(
                                    color: themeProvider.themeMode ==
                                            ThemeMode.dark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Filed on: ${complaint['complaint_date']}',
                                  style: TextStyle(
                                    color: themeProvider.themeMode ==
                                            ThemeMode.dark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Complaint: ${complaint['complaint_content']}',
                                  style: TextStyle(
                                    color: themeProvider.themeMode ==
                                            ThemeMode.dark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ComplaintUpdatesPage(
                                          complaintId: complaint['id'],
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: themeProvider.themeMode ==
                                            ThemeMode.dark
                                        ? Colors.blue[700]
                                        : Colors.blue.shade700,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text("Show Updates"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
