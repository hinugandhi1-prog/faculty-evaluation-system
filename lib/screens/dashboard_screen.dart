// import 'package:flutter/material.dart';
// import '../widgets/sidebar.dart';
// import '../widgets/stat_card.dart';
// import '../widgets/faculty_card.dart';
// import '../data/faculty_data.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       body: Row(
//         children: [
//           const Sidebar(),

//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Faculty Evaluation Dashboard",
//                     style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // 🔢 Stats Row
//                   Row(
//                     children: const [
//                       StatCard(title: "Total Faculty", value: "12"),
//                       StatCard(title: "Total Feedback", value: "1,248"),
//                       StatCard(title: "Avg Rating", value: "4.3"),
//                     ],
//                   ),

//                   const SizedBox(height: 30),

//                   const Text(
//                     "Faculty Performance",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//                   ),

//                   const SizedBox(height: 16),

//                   // 👨‍🏫 Faculty Cards
//                   Expanded(
//                     child: GridView.builder(
//                       itemCount: facultyList.length,
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         crossAxisSpacing: 16,
//                         mainAxisSpacing: 16,
//                       ),
//                       itemBuilder: (context, index) {
//                         final faculty = facultyList[index];
//                         return FacultyCard(
//                           name: faculty['name'],
//                           subject: faculty['subject'],
//                           rating: faculty['rating'],
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
