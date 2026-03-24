import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatefulWidget {
  final String facultyName;
  final String enrollment; // ✅ ADD THIS

  const FeedbackPage({
    super.key,
    required this.facultyName,
    required this.enrollment,
  });

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int q1 = 0, q2 = 0, q3 = 0, q4 = 0, q5 = 0, q6 = 0;
  final TextEditingController commentController = TextEditingController();

  final List<String> labels = [
    "Teaching",
    "Communication",
    "Knowledge",
    "Interaction",
    "Punctuality",
    "Overall",
  ];

  double get avg {
    List<int> v = [q1, q2, q3, q4, q5, q6];
    if (v.any((e) => e == 0)) return 0;
    return v.reduce((a, b) => a + b) / 6;
  }

  String get mood {
    if (avg == 0) return "🤔";
    if (avg < 2) return "😡";
    if (avg < 3.5) return "😐";
    if (avg < 4.5) return "🙂";
    return "😍";
  }

  Widget starRow(String title, int value, Function(int) onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: List.generate(5, (i) {
            return IconButton(
              icon: Icon(
                i < value ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () => onChange(i + 1),
            );
          }),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  List<PieChartSectionData> buildPie() {
    List<int> values = [q1, q2, q3, q4, q5, q6];
    double total = values.fold(0, (a, b) => a + b).toDouble();

    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          title: "No Data",
          color: Colors.grey,
        ),
      ];
    }

    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.teal,
    ];

    return List.generate(6, (i) {
      double percent = (values[i] / total) * 100;
      return PieChartSectionData(
        value: values[i].toDouble(),
        title: "${labels[i]}\n${percent.toStringAsFixed(0)}%",
        color: colors[i],
        radius: 110,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  // 🔥 SUBMIT TO FIRESTORE (WITH ENROLLMENT)
  Future<void> submit() async {
    if ([q1, q2, q3, q4, q5, q6].any((e) => e == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please rate all questions")),
      );
      return;
    }

    List<int> values = [q1, q2, q3, q4, q5, q6];
    double total = values.fold(0, (a, b) => a + b).toDouble();

    List<double> percents =
        values.map((v) => (v / total) * 100).toList();

    await FirebaseFirestore.instance.collection('feedback').add({
      'enrollment': widget.enrollment, // ✅ KEY LINE
      'faculty': widget.facultyName,

      'q1': q1,
      'q2': q2,
      'q3': q3,
      'q4': q4,
      'q5': q5,
      'q6': q6,

      'q1_percent': percents[0],
      'q2_percent': percents[1],
      'q3_percent': percents[2],
      'q4_percent': percents[3],
      'q5_percent': percents[4],
      'q6_percent': percents[5],

      'average_rating': avg,
      'average_percent': (avg / 5) * 100,

      'comment': commentController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback Submitted Successfully ✅")),
    );

    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.facultyName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Average: ${avg.toStringAsFixed(1)} / 5   $mood",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    starRow("Teaching Quality", q1, (v) => setState(() => q1 = v)),
                    starRow("Communication", q2, (v) => setState(() => q2 = v)),
                    starRow("Subject Knowledge", q3, (v) => setState(() => q3 = v)),
                    starRow("Interaction", q4, (v) => setState(() => q4 = v)),
                    starRow("Punctuality", q5, (v) => setState(() => q5 = v)),
                    starRow("Overall", q6, (v) => setState(() => q6 = v)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 320,
                  child: PieChart(
                    PieChartData(
                      sections: buildPie(),
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Text("Comments"),
          const SizedBox(height: 6),
          Container(
            height: 140,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 183, 149, 208),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: commentController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: "Write detailed feedback here...",
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: submit,
              child: const Text("Submit Feedback"),
            ),
          ),
        ],
      ),
    );
  }
}
