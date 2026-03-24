import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminFeedbackChartPage extends StatelessWidget {
  const AdminFeedbackChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        final Map<String, double> total = {};
        final Map<String, int> count = {};

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;

          if (!data.containsKey('faculty') ||
              !data.containsKey('average_rating')) {
            continue;
          }

          final faculty = data['faculty'].toString();
          final avg = (data['average_rating'] as num).toDouble();

          total[faculty] = (total[faculty] ?? 0) + avg;
          count[faculty] = (count[faculty] ?? 0) + 1;
        }

        if (total.isEmpty) {
          return const Center(
            child: Text(
              "No valid feedback data available",
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        final faculties = total.keys.toList();

        /// 🔥 CALCULATE FINAL AVERAGES
        final Map<String, double> averages = {
          for (var f in faculties) f: total[f]! / count[f]!
        };

        /// 🔥 FIND TOP + LOWEST
        String topFaculty =
            averages.entries.reduce((a, b) => a.value > b.value ? a : b).key;

        String lowestFaculty =
            averages.entries.reduce((a, b) => a.value < b.value ? a : b).key;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔥 TOP + LOWEST CARDS
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("👑 Top Performing Faculty",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 6),
                          Text(
                            topFaculty,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${averages[topFaculty]!.toStringAsFixed(2)} ⭐",
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("⚠️ Lowest Rated Faculty",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 6),
                          Text(
                            lowestFaculty,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${averages[lowestFaculty]!.toStringAsFixed(2)} ⭐",
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Text(
                "Faculty-wise Average Ratings",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              /// 🔥 CHART
              Expanded(
                child: BarChart(
                  BarChartData(
                    minY: 0,
                    maxY: 5,
                    alignment: BarChartAlignment.spaceAround,

                    /// ⭐ TOOLTIP WITH COUNT + %
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.black87,
                        tooltipRoundedRadius: 10,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final faculty =
                              faculties[group.x.toInt()];
                          final avg = rod.toY;
                          final percent = (avg / 5) * 100;

                          return BarTooltipItem(
                            "$faculty\n"
                            "⭐ Avg: ${avg.toStringAsFixed(2)}\n"
                            "📊 ${percent.toStringAsFixed(1)}%\n"
                            "🧾 ${count[faculty]} Feedbacks",
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),

                    /// 🔥 AXIS
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < faculties.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  faculties[i],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),

                    /// 🔥 BIGGER BARS + GRADIENT
                    barGroups: List.generate(faculties.length, (i) {
                      final faculty = faculties[i];
                      final avgRating = averages[faculty]!;

                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: avgRating,
                            width: 34, // ⭐ BIGGER
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              colors: [
                                Colors.deepPurple,
                                Colors.indigo,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
