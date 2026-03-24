import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'faculty_page.dart';
import 'admin_login_page.dart';
import 'faculty_login_page.dart'; // ✅ ADDED

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController enrollmentController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? enrollmentError;
  bool isLoading = false;

  Future<void> login() async {
    final enroll = enrollmentController.text.trim();
    final pass = passwordController.text.trim();

    // validation
    if (!RegExp(r'^\d+$').hasMatch(enroll)) {
      setState(() {
        enrollmentError = "Enrollment number must contain only digits";
      });
      return;
    }

    if (pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password required")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔥 CHECK STUDENT IN FIRESTORE
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(enroll)
          .get();

final studentName = doc['name'];
final course = doc['course'];

      if (doc.exists) {
        // ✅ STUDENT FOUND → OPEN USER SIDE (PASS ENROLLMENT)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FacultyPage(
              enrollment: enroll,
              studentName: studentName,
              course: course,),
          ),
        );
      } else {
        // ❌ NOT FOUND
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid Enrollment Number")),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.6)),
          ),
          Center(
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 208, 201, 156)
                    .withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school,
                      size: 70, color: Color(0xFF6A7BA2)),
                  const SizedBox(height: 16),

                  const Text(
                    "Faculty Evaluation System",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Enrollment
                  TextField(
                    controller: enrollmentController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enrollment Number",
                      errorText: enrollmentError,
                      filled: true,
                      fillColor: const Color(0xFFF2F4F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Password
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => login(),
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: const Color(0xFFF2F4F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A7BA2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 12),

                  // ADMIN LOGIN
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminLoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Login as Admin",
                      style: TextStyle(
                        color: Color(0xFF6A7BA2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // ✅ FACULTY LOGIN (ADDED ONLY THIS)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FacultyLoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Login as Faculty",
                      style: TextStyle(
                        color: Color(0xFF6A7BA2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
