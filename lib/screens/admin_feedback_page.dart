import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFeedbackPage extends StatefulWidget {
  const AdminFeedbackPage({super.key});

  @override
  State<AdminFeedbackPage> createState() => _AdminFeedbackPageState();
}

class _AdminFeedbackPageState extends State<AdminFeedbackPage> {

  String selectedFaculty = "Prof. Suhani Shah";

  final List<String> facultyList = [
    "Prof. Suhani Shah",
    "Prof. Neel Sanghvi",
    "Prof. Hardi Patel",
    "Prof. Arvind Meghani",
    "Prof. Ashka Jain",
    "Prof. Elvish Rao",
  ];

  /// STREAM FILTER BY FACULTY
  Stream<QuerySnapshot> getStream() {
    return FirebaseFirestore.instance
        .collection('feedback')
        .where('faculty', isEqualTo: selectedFaculty)
        .snapshots();
  }

  double calcAverage(List<QueryDocumentSnapshot> docs) {

    if (docs.isEmpty) return 0;

    double total = 0;

    for (var d in docs) {
      final data = d.data() as Map<String, dynamic>;
      total += (data['average_rating'] ?? 0);
    }

    return total / docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Feedback Analytics")),

      body: Column(
        children: [

          /// 🔥 FACULTY DROPDOWN
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField(
              value: selectedFaculty,
              decoration: InputDecoration(
                labelText: "Select Faculty",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: facultyList.map((f) {
                return DropdownMenuItem(
                  value: f,
                  child: Text(f),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedFaculty = val!;
                });
              },
            ),
          ),

          /// 🔥 STREAM DATA
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getStream(),
              builder: (context, snapshot) {

                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Create Firestore Index ⚡"),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No feedback for this faculty yet",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final avg = calcAverage(docs);

                return Column(
                  children: [

                    /// 🔥 TOP ANALYTICS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [

                          _analyticsCard(
                            "Total Feedback",
                            docs.length.toString(),
                            Colors.blue,
                          ),

                          _analyticsCard(
                            "Average Rating",
                            avg.toStringAsFixed(1),
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// 🔥 FEEDBACK LIST
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {

                          final raw =
                              docs[index].data() as Map<String, dynamic>;

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  /// ENROLLMENT
                                  Text(
                                    "Enrollment: ${raw['enrollment'] ?? '-'}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text("⭐ Rating: ${raw['average_rating'].toStringAsFixed(1)}"),

                                  const Divider(),

                                  Text("Teaching: ${raw['q1']}"),
                                  Text("Communication: ${raw['q2']}"),
                                  Text("Knowledge: ${raw['q3']}"),
                                  Text("Interaction: ${raw['q4']}"),
                                  Text("Punctuality: ${raw['q5']}"),
                                  Text("Overall: ${raw['q6']}"),

                                  if (raw['comment'] != null &&
                                      raw['comment'].toString().isNotEmpty) ...[
                                    const Divider(),
                                    const Text(
                                      "Comment:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(raw['comment']),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ANALYTICS CARD
  Widget _analyticsCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(title),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
