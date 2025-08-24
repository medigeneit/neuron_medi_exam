import 'package:flutter/material.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text(
          'Courses Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}