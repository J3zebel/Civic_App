import 'package:civic/Requestupdate.dart';
import 'package:civic/main.dart';
import 'package:civic/theam_provider.dart'; // Ensure correct spelling: 'theme_provider.dart'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Myrequest extends StatefulWidget {
  const Myrequest({super.key});

  @override
  State<Myrequest> createState() => _MyrequestState();
}

class _MyrequestState extends State<Myrequest> {
  List<Map<String, dynamic>> _requestlist = [];

  @override
  void initState() {
    super.initState();
    fetchrequest();
  }

  Future<void> fetchrequest() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        print('User is not logged in.');
        return;
      }

      final response = await supabase
          .from('User_tbl_request')
          .select()
          .eq('user_id', userId);

      if (mounted) {
        setState(() {
          _requestlist = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  IconData _getIconForRequest(Map<String, dynamic> request) {
    if (request['kseb_id'] != null) return Icons.electrical_services;
    if (request['mvd_id'] != null) return Icons.directions_car;
    if (request['muncipality_id'] != null) return Icons.location_city;
    return Icons.help_outline;
  }

  String _getRequestType(Map<String, dynamic> request) {
    if (request['kseb_id'] != null) return 'KSEB';
    if (request['mvd_id'] != null) return 'MVD';
    if (request['muncipality_id'] != null) return 'Municipality';
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Requests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white, // White text for AppBar regardless of theme
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 101, 175),
        elevation: 5,
      ),
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[100],
      body: _requestlist.isEmpty
          ? Center(
              child: Text(
                "No requests found.",
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _requestlist.length,
                itemBuilder: (context, index) {
                  final request = _requestlist[index];
                  final requestType = _getRequestType(request);
                  final response =
                      request['request_response'] ?? 'No response yet';

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestUpdatePage(
                            requestId: request['id'],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      color:
                          isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                      shadowColor: Colors.grey.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  _getIconForRequest(request),
                                  color:
                                      const Color.fromARGB(255, 12, 101, 175),
                                  size: 28,
                                ),
                                Text(
                                  'Request ID: ${request['id']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 12, 101, 175),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Type: $requestType',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Filed on: ${request['request_date']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Request: ${request['request_content']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Response: $response',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
