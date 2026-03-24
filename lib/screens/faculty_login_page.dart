import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'faculty_page.dart';

class FacultyLoginPage extends StatefulWidget {
  const FacultyLoginPage({super.key});

  @override
  State<FacultyLoginPage> createState() => _FacultyLoginPageState();
}

class _FacultyLoginPageState extends State<FacultyLoginPage> {

  final TextEditingController passwordController = TextEditingController();

  String? selectedFaculty;

  final List<String> facultyList = [
    "Prof. Suhani Shah",
    "Prof. Neel Sanghvi",
    "Prof. Hardi Patel",
    "Prof. Arvind Meghani",
    "Prof. Ashka Jain",
    "Prof. Elvish Rao",
  ];

  bool isLoading = false;

  Future<void> loginFaculty() async {

    final facultyName = selectedFaculty;
    final password = passwordController.text.trim();

    if (facultyName == null || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select faculty and enter password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final query = await FirebaseFirestore.instance
          .collection('faculties')
          .where('name', isEqualTo: facultyName)
          .where('password', isEqualTo: password)
          .get();

      if (query.docs.isNotEmpty) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FacultyPage(
              facultyName: facultyName,
            ),
          ),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid credentials")),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3E8F0),
              Color(0xFFD6DCE5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 65,
                  color: Color(0xFF4A5568),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Faculty Login",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 30),

                /// FACULTY DROPDOWN
                DropdownButtonFormField<String>(
                  value: selectedFaculty,
                  hint: const Text("Select Faculty"),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: const Color(0xFFF7FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: facultyList.map((faculty) {
                    return DropdownMenuItem(
                      value: faculty,
                      child: Text(faculty),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFaculty = value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                /// PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    filled: true,
                    fillColor: const Color(0xFFF7FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : loginFaculty,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A5568),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Back to Login",
                    style: TextStyle(
                      color: Color(0xFF4A5568),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}