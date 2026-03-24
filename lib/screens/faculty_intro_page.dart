import 'package:flutter/material.dart';
import 'faculty_page.dart';
import 'feedback_page.dart';

class FacultyIntroPage extends StatelessWidget {
  final String name;
  final String enrollment; // ✅ ADD THIS

  const FacultyIntroPage({
    super.key,
    required this.name,
    required this.enrollment, // ✅ ADD THIS
  });

  bool get isGirl {
    final n = name.toLowerCase();
    return n.contains("suhani") || n.contains("ashka");
  }

  Map<String, dynamic> get data {
    switch (name) {
      case "Prof. Suhani Shah":
        return {
          "about":
              "Prof. Suhani Shah specializes in Advanced Machine Learning with strong expertise in neural networks, predictive systems, and AI-driven analytics. She motivates students to build intelligent real-world applications.",
          "work":
              "8+ years teaching Machine Learning with live industry projects in NLP, deep learning, and recommendation engines.",
          "subjects": "Advanced Machine Learning",
          "students": "520+",
          "awards": "5",
        };

      case "Prof. Neel Sanghvi":
        return {
          "about":
              "A Data Science expert, Prof. Neel Sanghvi trains students in data analytics, visualization, and statistical intelligence while connecting theory to real industry workflows.",
          "work":
              "10+ years teaching Data Science, Python, and Big Data technologies with strong career mentorship.",
          "subjects": "Data Science",
          "students": "750+",
          "awards": "6",
        };

      case "Prof. Hardi Patel":
        return {
          "about":
              "Prof. Hardi Patel focuses on Artificial Intelligence and smart automation, helping students design intelligent systems using modern AI frameworks.",
          "work":
              "9+ years teaching AI including computer vision, deep learning, and intelligent agents.",
          "subjects": "Artificial Intelligence",
          "students": "600+",
          "awards": "4",
        };

      case "Prof. Arvind Meghani":
        return {
          "about":
              "Full Stack specialist empowering students to build scalable web applications using modern frontend, backend, and cloud technologies.",
          "work":
              "11+ years teaching MERN stack, APIs, deployment, and enterprise architecture.",
          "subjects": "Full Stack Development",
          "students": "820+",
          "awards": "7",
        };

      case "Prof. Ashka Jain":
        return {
          "about":
              "Expert in Cross Platform Development guiding students to create high-performance apps using Flutter and modern UI systems.",
          "work":
              "7+ years teaching mobile engineering across Android, iOS, and hybrid platforms.",
          "subjects": "Cross Platform Development",
          "students": "480+",
          "awards": "3",
        };

      case "Prof. Elvish Rao":
        return {
          "about":
              "Specialist in Data Warehousing teaching enterprise data architecture, ETL pipelines, and analytics infrastructure.",
          "work":
              "12+ years teaching database systems and large-scale data engineering.",
          "subjects": "Data Warehousing",
          "students": "690+",
          "awards": "6",
        };

      default:
        return {
          "about": "Dedicated faculty focused on student success.",
          "work": "Experienced professor with strong academic background.",
          "subjects": "Core Computing",
          "students": "500+",
          "awards": "3",
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = data;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F7FB), Color(0xFFE9ECF8), Color(0xFFDDE3F4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1150),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    /// TOP BAR
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FacultyPage(enrollment: enrollment),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text("Home"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// PROFILE
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 42,
                            backgroundImage: AssetImage(
                              isGirl
                                  ? 'assets/images/girl.png'
                                  : 'assets/images/boy.png',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// GRID
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 1.15,
                        children: [
                          _card(Icons.info, "About", d["about"], Colors.blue.shade50),
                          _card(Icons.work, "Experience", d["work"], Colors.orange.shade50),
                          _card(Icons.menu_book, "Subjects", d["subjects"], Colors.green.shade50),
                          _card(Icons.school, "Students", d["students"], Colors.purple.shade50),
                          _card(Icons.emoji_events, "Awards", d["awards"], Colors.red.shade50),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// BUTTON
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 6,
                        backgroundColor: const Color(0xFF5C6BC0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 45,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FeedbackPage(
                              facultyName: name,
                              enrollment: enrollment, // ✅ FIXED HERE
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Faculty Evaluation",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// CARD
  Widget _card(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
