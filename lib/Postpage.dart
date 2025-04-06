import 'package:civic/main.dart';
import 'package:flutter/material.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<Map<String, dynamic>> _postList = [];
  Map<int, int> _likeCounts = {}; // Like count per post
  Set<int> _likedPosts = {}; // Posts liked by current user

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> toggleLike(int postId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      if (_likedPosts.contains(postId)) {
        await supabase.from("User_tbl_like").delete().match({
          'post_id': postId,
          'user_id': userId,
        });
        _likedPosts.remove(postId);
        _likeCounts[postId] = (_likeCounts[postId] ?? 1) - 1;
      } else {
        await supabase.from("User_tbl_like").insert({
          'post_id': postId,
          'user_id': userId,
        });
        _likedPosts.add(postId);
        _likeCounts[postId] = (_likeCounts[postId] ?? 0) + 1;
      }

      setState(() {});
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  Future<void> fetchPosts() async {
    try {
      final userId = supabase.auth.currentUser?.id; // Use ? instead of !
      if (userId == null) {
        print("No authenticated user found.");
        return;
      }

      final postsResponse = await supabase.from('KSEB_tbl_publicpost').select();
      final likesResponse =
          await supabase.from('User_tbl_like').select('post_id');
      final userLikesResponse = await supabase
          .from('User_tbl_like')
          .select('post_id')
          .eq('user_id', userId);

      // Handle posts
      _postList = (postsResponse as List<dynamic>)
          .where((p) => p['id'] != null) // Filter out null IDs
          .map((p) => Map<String, dynamic>.from(p))
          .toList();

      // Handle like counts
      Map<int, int> likeCounts = {};
      for (var like in likesResponse) {
        if (like['post_id'] != null) {
          int postId = like['post_id'] as int;
          likeCounts[postId] = (likeCounts[postId] ?? 0) + 1;
        }
      }
      _likeCounts = likeCounts;

      // Handle user likes
      _likedPosts = {
        for (var item in userLikesResponse)
          if (item['post_id'] != null) item['post_id'] as int
      };

      setState(() {});
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  String _getDepartment(Map<String, dynamic> post) {
    if (post['kseb_id'] != null) return 'KSEB';
    if (post['mvd_id'] != null) return 'MVD';
    if (post['muncipality_id'] != null) return 'Municipality';
    if (post['pwd_id'] != null) return 'PWD';
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Posts', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.blue.shade700,
      ),
      body: _postList.isEmpty
          ? const Center(
              child: Text(
                "No posts available.",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: _postList.length + 1, // Add extra space at the end
                itemBuilder: (context, index) {
                  if (index == _postList.length) {
                    return const SizedBox(
                        height: 100); // Extra spacing at the bottom
                  }

                  final post = _postList[index];
                  final postId =
                      post['id'] as int; // Safe since filtered in fetchPosts
                  final department = _getDepartment(post);
                  final likeCount = _likeCounts[postId] ?? 0;
                  final isLiked = _likedPosts.contains(postId);

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
                          Text(
                            'Department: $department',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Posted on: ${post['post_date'] ?? 'Unknown Date'}',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              post['post_file'] ?? '',
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image,
                                      size: 80, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            post['post_details'] ?? 'No details available',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => toggleLike(postId),
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
