import 'package:flutter/material.dart';
import 'faculty_intro_page.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class FacultyPage extends StatelessWidget {
  final String? enrollment;
  final String? facultyName;
  final String? studentName;
  final String? course;

  const FacultyPage({
    super.key,
    this.enrollment,
    this.facultyName,
    this.studentName,
    this.course,
  });

  final List<Map<String, String>> facultyList = const [
    {"name": "Prof. Suhani Shah", "tag": "Advance Machine Learning", "gender": "girl"},
    {"name": "Prof. Neel Sanghvi", "tag": "Data Science", "gender": "boy"},
    {"name": "Prof. Hardi Patel", "tag": "Artificial Intelligence", "gender": "girl"},
    {"name": "Prof. Arvind Meghani", "tag": "Full Stack", "gender": "boy"},
    {"name": "Prof. Ashka Jain", "tag": "Cross Platform", "gender": "girl"},
    {"name": "Prof. Elvish Rao", "tag": "Data Warehouse", "gender": "boy"},
  ];

  // ✅ KEEP makeBar INSIDE CLASS
  BarChartGroupData makeBar(int x, double value) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          width: 32,
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 5,
            color: Colors.grey.withOpacity(0.08),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (facultyName != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Faculty Dashboard"),
          backgroundColor: const Color(0xFF6A7BA2),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('feedback')
              .where('faculty', isEqualTo: facultyName)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  "No feedback available yet",
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            double q1 = 0, q2 = 0, q3 = 0, q4 = 0, q5 = 0, q6 = 0;

            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              q1 += (data['q1'] ?? 0);
              q2 += (data['q2'] ?? 0);
              q3 += (data['q3'] ?? 0);
              q4 += (data['q4'] ?? 0);
              q5 += (data['q5'] ?? 0);
              q6 += (data['q6'] ?? 0);
            }

            final total = docs.length;

            final avgQ1 = q1 / total;
            final avgQ2 = q2 / total;
            final avgQ3 = q3 / total;
            final avgQ4 = q4 / total;
            final avgQ5 = q5 / total;
            final avgQ6 = q6 / total;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    facultyName!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      height: 600,
                      width: 990,
                    child: BarChart(
                      BarChartData(
                        minY: 0,
                        maxY: 5,
                        alignment: BarChartAlignment.spaceAround,

                        // ✅ Tooltip only on hover
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.black87,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                "⭐ Avg: ${rod.toY.toStringAsFixed(2)}\n"
                                "🧾 Feedbacks: $total",
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),

                        barGroups: [
                          makeBar(0, avgQ1),
                          makeBar(1, avgQ2),
                          makeBar(2, avgQ3),
                          makeBar(3, avgQ4),
                          makeBar(4, avgQ5),
                          makeBar(5, avgQ6),
                        ],

                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const titles = [
                                  "Teaching",
                                  "Knowledge",
                                  "Communication",
                                  "Interaction",
                                  "Punctuality",
                                  "Overall"
                                ];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    titles[value.toInt()],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                      ),
                    ),
                  ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // -------- TOP BAR --------
            Row(
              children: [
                const Text(
                  "🏠 Home",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Tooltip(
                  message:
                  "Name: $studentName\nCourse: $course\nEnrollment: $enrollment",
                  child: const Icon(
                    Icons.account_circle,
                    size: 28,
                    color: Colors.black54,
                    ),
               ),
                  
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FacultyPage(
                            enrollment: enrollment,
                            studentName: studentName,
                            course: course,
                            ),
                          ),
                        );
                      },
                      child: const Text("Home"),
                      ),

                // -------- LOGOUT --------
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Logout"),
                        content: const Text(
                          "Are you sure you want to logout?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            },
                            child: const Text(
                              "Yes, Logout",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),      
  
            const SizedBox(height: 30),
            
            // -------- HERO --------
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "🎓 Your Feedback Shapes the Future",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Feedback helps teachers improve and students learn better.\n\n"
                        "✨ Be honest\n"
                        "📚 Help teachers grow\n"
                        "🌱 Improve learning for everyone",
                        style: TextStyle(fontSize: 16, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/feedback_banner.png',
                      height: 260,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            const Text(
              "👩‍🏫 Select Faculty",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: facultyList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemBuilder: (context, index) {
                final f = facultyList[index];
                return HoverNameCard(
                  name: f["name"]!,
                  tag: f["tag"]!,
                  gender: f["gender"]!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FacultyIntroPage(
                          name: f["name"]!,
                          enrollment: enrollment!, // ✅ PASS HERE
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 40),

            // -------- BOTTOM --------
            Center(
              child: Column(
                children: const [
                  Text(
                    "“Great teaching begins with listening.” 🎧",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Your feedback makes education better for everyone.",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 BarChartGroupData makeBar(int x, double value) {
  final percent = ((value / 5) * 100).toStringAsFixed(0);

  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: value,
        width: 32,
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: 5,
          color: Colors.grey.withOpacity(0.08),
        ),
      ),
    ],
    barsSpace: 8,
    showingTooltipIndicators: [0],
  );
}



// -------- CARD --------

class HoverNameCard extends StatefulWidget {
  final String name;
  final String tag;
  final String gender;
  final VoidCallback onTap;

  const HoverNameCard({
    super.key,
    required this.name,
    required this.tag,
    required this.gender,
    required this.onTap,
  });

  @override
  State<HoverNameCard> createState() => _HoverNameCardState();
}

class _HoverNameCardState extends State<HoverNameCard> {
  bool isHover = false;

  Color get baseColor {
    switch (widget.name) {
      case "Prof. Suhani Shah":
        return const Color(0xFFFFE4EA);
      case "Prof. Neel Sanghvi":
        return const Color(0xFFE9F7EF);
      case "Prof. Hardi Patel":
        return const Color(0xFFFFF3E0);
      case "Prof. Arvind Meghani":
        return const Color(0xFFE3F2FD);
      case "Prof. Ashka Jain":
        return const Color(0xFFF3E5F5);
      default:
        return const Color(0xFFE0F7FA);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform:
              isHover ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: isHover
                    ? Colors.deepPurple.withOpacity(0.25)
                    : Colors.black12,
                blurRadius: isHover ? 12 : 6,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(
                  widget.gender == "girl"
                      ? 'assets/images/girl.png'
                      : 'assets/images/boy.png',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                widget.tag,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
