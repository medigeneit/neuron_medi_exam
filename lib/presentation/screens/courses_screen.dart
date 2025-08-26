import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/courses_card_widget.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  // Demo courses data (icon + title)
  List<Map<String, dynamic>> get _coursesList => const [
    {'title': 'FCPS Part-1 Foundation', 'icon': Icons.menu_book_rounded},
    {'title': 'BCS Preparation Crash', 'icon': Icons.school_rounded},
    {'title': 'Anatomy Quick Review', 'icon': Icons.biotech_rounded},
    {'title': 'Physiology MCQ Drills', 'icon': Icons.quiz_rounded},
    {'title': 'Pharmacology Essentials', 'icon': Icons.vaccines_rounded},
    {'title': 'Medicine Long Case', 'icon': Icons.local_hospital_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Grid layout: 2 items per row
            const horizontalPadding = 16.0;
            const gridSpacing = 12.0;
            final gridWidth = constraints.maxWidth - (horizontalPadding * 2);
            final itemWidth = (gridWidth - gridSpacing) / 2;

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding, 16, horizontalPadding, 16,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: _coursesList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 items per row
                crossAxisSpacing: gridSpacing,
                mainAxisSpacing: gridSpacing,
                childAspectRatio: 0.85, // Better aspect ratio for square-ish cards
              ),
              itemBuilder: (context, index) {
                final course = _coursesList[index];
                return SizedBox(
                  width: itemWidth,
                  child: CoursesCardWidget(
                    title: course['title'] as String,
                    icon: course['icon'] as IconData,
                    onTap: () {
                      // Navigate to course details
                      Get.toNamed('/course/details', arguments: {
                        'title': course['title'],
                        'icon': course['icon'],
                      });
                    },
                    onLearnMore: () {
                      // Show snackbar
                      Get.snackbar(
                        'Course',
                        'Opening ${course['title']}',
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(12),
                        backgroundColor: Colors.black87,
                        colorText: Colors.white,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      );
  }
}
