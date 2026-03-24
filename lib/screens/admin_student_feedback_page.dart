import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStudentFeedbackPage extends StatelessWidget {

  final String enrollment;

  const AdminStudentFeedbackPage({
    super.key,
    required this.enrollment,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Feedback History - $enrollment"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection('feedback')
            .where('enrollment', isEqualTo: enrollment)
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "This student has not submitted any feedback yet.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data = docs[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(14),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        data['faculty'] ?? "Unknown Faculty",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text("⭐ Average: ${data['average_rating']?.toStringAsFixed(1) ?? "-"}"),

                      const Divider(),

                      Text("Teaching: ${data['q1']}"),
                      Text("Communication: ${data['q2']}"),
                      Text("Knowledge: ${data['q3']}"),
                      Text("Interaction: ${data['q4']}"),
                      Text("Punctuality: ${data['q5']}"),
                      Text("Overall: ${data['q6']}"),

                      if (data['comment'] != null &&
                          data['comment'].toString().isNotEmpty) ...[
                        const Divider(),
                        const Text("Comment:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(data['comment']),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
