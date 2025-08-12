import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text(
          'My Dashboard Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}