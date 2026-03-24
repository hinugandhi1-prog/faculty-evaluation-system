import 'package:flutter/material.dart';

class RatingScreen extends StatefulWidget {
  final String facultyName;
  const RatingScreen({super.key, required this.facultyName});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final List<int> ratings = List.generate(5, (_) => 0);

  final questions = [
    "Teaching clarity",
    "Subject knowledge",
    "Interaction with students",
    "Punctuality",
    "Overall effectiveness",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.facultyName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(5, (index) {
            return Card(
              child: ListTile(
                title: Text(questions[index]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (star) {
                    return IconButton(
                      icon: Icon(
                        star < ratings[index] ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() => ratings[index] = star + 1);
                      },
                    );
                  }),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
