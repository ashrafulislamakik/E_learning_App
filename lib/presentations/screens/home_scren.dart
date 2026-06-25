import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/auth_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  String? _userName;
  String? _profileUrl;
  Uint8List? _webImage; // ওয়েবের জন্য ইমেজের বাইট ডাটা
  bool _isUploading = false;

  // কোর্স ডাটা লিস্ট
  List<Map<String, dynamic>> _allCourses = [
    {"title": "Flutter UI/UX Design Mastery", "instructor": "Dr. Angela Yu", "price": "২৫০০"},
    {"title": "Python for Beginners", "instructor": "John Doe", "price": "১২০০"},
    {"title": "Web Development Bootcamp", "instructor": "Colt Steele", "price": "৩০০০"},
    {"title": "Dart Mastery with Firebase", "instructor": "Asraful Islam", "price": "২০০০"},
  ];

  List<Map<String, dynamic>> _foundCourses = [];

  @override
  void initState() {
    super.initState();
    _foundCourses = _allCourses;
    _userName = user?.displayName ?? user?.email?.split('@')[0];
    _fetchUserData();
    _fetchCoursesFromFirestore();
  }

  // ফায়ারস্টোর থেকে লাইভ কোর্স আনা
  Future<void> _fetchCoursesFromFirestore() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('courses').get();
      if (snapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> loadedCourses = snapshot.docs.map((doc) => {
          "title": doc.data()["title"] ?? "Untitled Course",
          "instructor": doc.data()["instructor"] ?? "Unknown Instructor",
          "price": doc.data()["price"]?.toString() ?? "0",
        }).toList();
        setState(() {
          _allCourses = loadedCourses;
          _foundCourses = loadedCourses;
        });
      }
    } catch (e) {
      debugPrint("Error fetching courses: $e");
    }
  }

  // ইউজার ডাটা আনা
  Future<void> _fetchUserData() async {
    try {
      var userData = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
      if (userData.exists) {
        setState(() {
          _userName = userData.data()?['name'] ?? _userName;
          _profileUrl = userData.data()?['profileUrl'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  // সার্চ ফিল্টার লজিক
  void _runFilter(String enteredKeyword) {
    setState(() {
      if (enteredKeyword.isEmpty) {
        _foundCourses = _allCourses;
      } else {
        _foundCourses = _allCourses.where((course) =>
        course["title"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
            course["instructor"].toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
      }
    });
  }

  // ওয়েবে ছবি আপলোড করার ফাংশন
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);

    if (image != null) {
      var f = await image.readAsBytes();
      setState(() {
        _webImage = f;
        _isUploading = true;
      });

      try {
        var storageRef = FirebaseStorage.instance.ref().child('profile_pics/${user?.uid}.jpg');
        SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

        await storageRef.putData(f, metadata);
        String downloadUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
          'profileUrl': downloadUrl
        });

        setState(() {
          _profileUrl = downloadUrl;
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated!")),
        );
      } catch (e) {
        setState(() => _isUploading = false);
        debugPrint("Upload Error: $e");
      }
    }
  }

  // নাম পরিবর্তনের ডায়ালগ
  void _showRenameDialog() {
    TextEditingController nameController = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Update Name", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: "Enter your name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              String newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                await user?.updateDisplayName(newName);
                await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({'name': newName});
                setState(() => _userName = newName);
                if (!mounted) return;
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // মডার্ন প্রোফাইল মেনু
  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SingleChildScrollView(
          child: StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                      const SizedBox(height: 25),
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.indigo.withOpacity(0.1),
                        backgroundImage: _webImage != null
                            ? MemoryImage(_webImage!)
                            : (_profileUrl != null ? NetworkImage(_profileUrl!) as ImageProvider : null),
                        child: _isUploading
                            ? const CircularProgressIndicator(color: Colors.indigo)
                            : (_webImage == null && _profileUrl == null
                            ? const Icon(Icons.person, size: 50, color: Colors.indigo)
                            : null),
                      ),
                      const SizedBox(height: 12),
                      Text(_userName ?? 'Guest', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                      Text(user?.email ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      const SizedBox(height: 25),
                      _buildMenuTile(Icons.edit_outlined, "Rename Profile", Colors.blue, _showRenameDialog),
                      _buildMenuTile(Icons.camera_alt_outlined, "Change Picture", Colors.purple, () async {
                        Navigator.pop(context);
                        await _pickImage();
                      }),
                      _buildMenuTile(Icons.logout_rounded, "Logout", Colors.redAccent, () async {
                        Navigator.pop(context);
                        await AuthService().signOut();
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      }),
                    ],
                  ),
                );
              }
          ),
        );
      },
    );
  }

  Widget _buildMenuTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hello,", style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text(_userName ?? 'User', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_active_outlined, color: Colors.black)),
          GestureDetector(
            onTap: _showProfileMenu,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.indigo,
                backgroundImage: _webImage != null
                    ? MemoryImage(_webImage!)
                    : (_profileUrl != null ? NetworkImage(_profileUrl!) : null),
                child: (_webImage == null && _profileUrl == null)
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // প্রিমিয়াম সার্চ বার
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: TextField(
                onChanged: _runFilter,
                decoration: const InputDecoration(
                  hintText: "Search your favorite course",
                  prefixIcon: Icon(Icons.search, color: Colors.indigo),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text("Popular Courses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: _foundCourses.isNotEmpty
                  ? ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _foundCourses.length,
                itemBuilder: (context, index) => _buildCourseCard(
                  _foundCourses[index]['title'],
                  _foundCourses[index]['instructor'],
                  _foundCourses[index]['price'],
                ),
              )
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
                    const Text("No response item found!", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // সেই প্রিমিয়াম কোর্স কার্ড ডিজাইন
  Widget _buildCourseCard(String title, String instructor, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              height: 160,
              width: double.infinity,
              color: Colors.indigo[50],
              child: const Icon(Icons.play_circle_rounded, size: 60, color: Colors.indigo),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(instructor, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("৳ $price", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.indigo)),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text("Enroll Now", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}