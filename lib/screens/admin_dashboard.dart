import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'admin_student_feedback_page.dart';
import 'admin_feedback_page.dart';
import 'admin_feedback_chart_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;
  bool darkMode = false;
  String searchText = "";

  final firestore = FirebaseFirestore.instance;

  // RIGHT SIDE SWITCH
  Widget rightContent() {
    switch (selectedIndex) {
      case 0:
        return dashboardHome();
      case 1:
        return const AdminFeedbackPage();
      case 2:
        return const AdminFeedbackChartPage();
      default:
        return const SizedBox();
    }
  }

  // MAIN DASHBOARD
  Widget dashboardHome() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('feedback').snapshots(),
      builder: (context, feedbackSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: firestore.collection('students').snapshots(),
          builder: (context, studentSnap) {
            if (!feedbackSnap.hasData || !studentSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final feedbackDocs = feedbackSnap.data!.docs;
            final studentDocs = studentSnap.data!.docs;

            int totalStudents = studentDocs.length;
            int totalFeedback = feedbackDocs.length;

            Set<String> faculties = {};
            double avg = 0;

            Map<String, int> trend = {
              "Mon": 0,
              "Tue": 0,
              "Wed": 0,
              "Thu": 0,
              "Fri": 0,
              "Sat": 0,
              "Sun": 0
            };

            for (var doc in feedbackDocs) {
              final d = doc.data() as Map<String, dynamic>;

              faculties.add(d['faculty'] ?? "");

              if (d['average_rating'] != null) {
                avg += (d['average_rating'] as num).toDouble();
              }

              if (d['createdAt'] != null) {
                DateTime date = (d['createdAt'] as Timestamp).toDate();
                String day =
                    ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][date.weekday % 7];

                trend[day] = trend[day]! + 1;
              }
            }

            double overallAvg = totalFeedback == 0 ? 0 : avg / totalFeedback;

            /// SEARCH FROM STUDENTS
            final filteredStudents = studentDocs.where((doc) {
              final enroll = doc.id;

              return enroll
                  .toLowerCase()
                  .contains(searchText.toLowerCase());
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP BAR
                  Row(
                    children: [
                      const Text(
                        "Dashboard Overview",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          darkMode ? Icons.dark_mode : Icons.light_mode,
                        ),
                        onPressed: () {
                          setState(() {
                            darkMode = !darkMode;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // STATS
                  Wrap(
                    spacing: 25,
                    runSpacing: 25,
                    children: [
                      statCard("Students", totalStudents.toString(),
                          Icons.school, Colors.blue),
                      statCard("Feedback", totalFeedback.toString(),
                          Icons.feedback, Colors.green),
                      statCard("Faculties", faculties.length.toString(),
                          Icons.person, Colors.orange),
                      statCard("Avg Rating", overallAvg.toStringAsFixed(2),
                          Icons.star, Colors.deepPurple),
                    ],
                  ),

                  const SizedBox(height: 40),

                  const Text("Feedback Trend",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 260,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(7, (i) {
                              return FlSpot(
                                  i.toDouble(),
                                  trend.values.elementAt(i).toDouble());
                            }),
                            isCurved: true,
                            barWidth: 4,
                            color: Colors.deepPurple,
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // SEARCH STUDENTS
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search Student Enrollment...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchText = val;
                      });
                    },
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Students",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  ...filteredStudents.map((doc) {
                    final enroll = doc.id;

                    int count = feedbackDocs.where((f) {
                      final data = f.data() as Map<String, dynamic>;
                      return data['enrollment'] == enroll;
                    }).length;

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text("Enrollment: $enroll"),
                        subtitle: Text(
                          count == 0
                              ? "No feedback given"
                              : "$count feedback submitted",
                        ),
                        trailing:
                            const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AdminStudentFeedbackPage(enrollment: enroll),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget statCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 250,
      height: 130,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: darkMode ? Colors.black54 : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Colors.black12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          darkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: Row(
        children: [
          Container(
            width: 230,
            color: const Color(0xFF2E3B55),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "ADMIN PANEL",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                sideItem(Icons.dashboard, "Dashboard", 0),
                sideItem(Icons.list_alt, "Feedback List", 1),
                sideItem(Icons.bar_chart, "Feedback Charts", 2),
                const Spacer(),
                const Divider(color: Colors.white24),
                sideItem(Icons.logout, "Logout", 99),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(child: rightContent()),
        ],
      ),
    );
  }

  Widget sideItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      selected: selectedIndex == index,
      selectedTileColor: Colors.white24,
      onTap: () {
        if (index == 99) {
          Navigator.pop(context);
        } else {
          setState(() {
            selectedIndex = index;
          });
        }
      },
    );
  }
}
