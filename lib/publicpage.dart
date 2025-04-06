import 'package:civic/main.dart';
import 'package:flutter/material.dart';

class Publicpage extends StatefulWidget {
  const Publicpage({super.key});

  @override
  State<Publicpage> createState() => _PublicpageState();
}

class _PublicpageState extends State<Publicpage> {
  List<Map<String, dynamic>> _complaintlist = [];
  Map<int, int> _likeCounts = {};
  Set<int> _likedComplaints = {};

  @override
  void initState() {
    super.initState();
    fetchcomplaint();
  }

  Future<void> toggleLike(int cid) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      if (_likedComplaints.contains(cid)) {
        await supabase.from("User_tbl_like").delete().match({
          'complaint_id': cid,
          'user_id': userId,
        });

        _likedComplaints.remove(cid);
        _likeCounts[cid] = (_likeCounts[cid] ?? 1) - 1;
      } else {
        await supabase.from("User_tbl_like").insert({
          'complaint_id': cid,
          'user_id': userId,
        });

        _likedComplaints.add(cid);
        _likeCounts[cid] = (_likeCounts[cid] ?? 0) + 1;
      }

      setState(() {});
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  Future<void> fetchcomplaint() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final complaintsResponse =
          await supabase.from('User_tbl_complaint').select();
      final likesResponse =
          await supabase.from('User_tbl_like').select('complaint_id');
      final userLikesResponse = await supabase
          .from('User_tbl_like')
          .select('complaint_id')
          .eq('user_id', userId);

      // Handle complaints
      _complaintlist = (complaintsResponse as List<dynamic>)
          .where((c) => c['id'] != null) // Filter out null IDs
          .map((c) => Map<String, dynamic>.from(c))
          .toList();

      // Handle like counts
      Map<int, int> likeCounts = {};
      for (var like in likesResponse) {
        if (like['complaint_id'] != null) {
          int complaintId = like['complaint_id'] as int;
          likeCounts[complaintId] = (likeCounts[complaintId] ?? 0) + 1;
        }
      }
      _likeCounts = likeCounts;

      // Handle user likes
      _likedComplaints = {
        for (var item in userLikesResponse)
          if (item['complaint_id'] != null) item['complaint_id'] as int
      };

      setState(() {});
    } catch (e) {
      print('Error fetching complaints: $e');
    }
  }

  String _getComplaintType(Map<String, dynamic> request) {
    if (request['kseb_id'] != null) return 'KSEB';
    if (request['mvd_id'] != null) return 'MVD';
    if (request['muncipality_id'] != null) return 'Municipality';
    if (request['pwd_id'] != null) return 'PWD';
    return 'Unknown';
  }

  IconData _getComplaintIcon(String type) {
    switch (type) {
      case 'KSEB':
        return Icons.bolt;
      case 'MVD':
        return Icons.directions_car;
      case 'Municipality':
        return Icons.location_city;
      case 'PWD':
        return Icons.build;
      default:
        return Icons.report_problem;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Complaints', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.blue.shade700,
      ),
      body: _complaintlist.isEmpty
          ? const Center(
              child: Text(
                "No complaints found.",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: _complaintlist.length,
                itemBuilder: (context, index) {
                  final complaint = _complaintlist[index];
                  final complaintType = _getComplaintType(complaint);
                  final complaintId = complaint['id']
                      as int; // Safe since filtered in fetchcomplaint
                  final likeCount = _likeCounts[complaintId] ?? 0;
                  final isLiked = _likedComplaints.contains(complaintId);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: Colors.blueGrey.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(_getComplaintIcon(complaintType),
                                  color: Colors.blue.shade700, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                'Complaint ID: $complaintId',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Type: $complaintType',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Filed on: ${complaint['complaint_date'] ?? 'Unknown'}',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Complaint: ${complaint['complaint_content'] ?? 'No description'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => toggleLike(complaintId),
                                    icon: Icon(
                                      Icons.thumb_up,
                                      color: isLiked ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$likeCount Likes',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
