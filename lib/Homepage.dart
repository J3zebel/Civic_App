import 'package:civic/Kseb.dart';
import 'package:civic/Muncipality.dart';
import 'package:civic/Mvd.dart';
import 'package:civic/Postpage.dart';
import 'package:civic/Pwd.dart';
import 'package:civic/Accountpage.dart';
import 'package:civic/main.dart';
import 'package:civic/publicpage.dart';
import 'package:civic/theam_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const PostPage(),
    const Publicpage(),
    const AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        body: Stack(
          children: [
            _pages[_selectedIndex],
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BottomNavigationBar(
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home, size: 28),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add, size: 28),
                        label: 'Post',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.public, size: 28),
                        label: 'Public',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.contact_emergency_rounded, size: 28),
                        label: 'Account',
                      ),
                    ],
                    backgroundColor: const Color(0xFF0C65AF), // Changed to blue
                    currentIndex: _selectedIndex,
                    selectedItemColor: Colors.white, // Selected item white
                    unselectedItemColor: Colors
                        .white70, // Unselected items slightly lighter white
                    onTap: _onItemTapped,
                    type: BottomNavigationBarType
                        .fixed, // Ensures all items are visible
                    selectedLabelStyle: const TextStyle(color: Colors.white),
                    unselectedLabelStyle:
                        const TextStyle(color: Colors.white70),
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

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController nameController = TextEditingController();
  Map<String, dynamic>? _userlist;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchuser();
  }

  Future<void> fetchuser() async {
    try {
      setState(() {
        isLoading = true;
      });
      final userid = supabase.auth.currentUser?.id;
      if (userid != null) {
        final response = await supabase
            .from('Guest_tbl_user')
            .select()
            .eq("user_id", userid)
            .single();
        setState(() {
          _userlist = response;
          nameController.text = _userlist?['user_name'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Exception during fetch: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error fetching user: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220.0,
          backgroundColor: const Color.fromARGB(255, 12, 101, 175),
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(60)),
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: []),
                const SizedBox(height: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _userlist?['user_name'] ?? 'Loading...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    const SizedBox(height: 4),
                    const Text(
                      "Welcome Back",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pinned: true,
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              _buildCategories(context),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategories(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final categories = [
      {
        'title': 'KSEB',
        'icon': Icons.bolt,
        'color': const Color.fromARGB(255, 12, 101, 175), // Original blue
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const KsebScreen())),
      },
      {
        'title': 'Municipality',
        'icon': Icons.location_city,
        'color': isDarkMode ? Colors.white : Colors.black, // Theme-based color
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MunicipalityScreen())),
      },
      {
        'title': 'MVD',
        'icon': Icons.directions_car,
        'color': isDarkMode ? Colors.white : Colors.black, // Theme-based color
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MvdScreen())),
      },
      {
        'title': 'PWD',
        'icon': Icons.build,
        'color': const Color.fromARGB(255, 12, 101, 175), // Original blue
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PwdScreen())),
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(19.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Category",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isDarkMode ? Colors.white70 : Colors.black,
                ),
              ),
              Icon(
                Icons.more_horiz,
                color: isDarkMode ? Colors.white70 : Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3 / 2,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(
                context,
                title: category['title'] as String,
                icon: category['icon'] as IconData,
                color: category['color']
                    as Color, // Pass the color from the category map
                onTap: category['onTap'] as VoidCallback,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color, // Use the passed color
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color, // Use the dynamic or static color
        ),
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color == Colors.white
                  ? Colors.black
                  : Colors.white, // Adjust icon color based on background
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color == Colors.white
                    ? Colors.black
                    : Colors.white, // Adjust text color based on background
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
