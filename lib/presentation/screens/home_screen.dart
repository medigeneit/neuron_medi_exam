import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/available_batch_item.dart';
import 'package:medi_exam/data/models/available_subject_item.dart';
import 'package:medi_exam/data/models/course_item.dart';
import 'package:medi_exam/data/models/slider_image.dart';
import 'package:medi_exam/presentation/widgets/available_course_container_widget.dart';
import 'package:medi_exam/presentation/widgets/available_subjects_container.dart';
import '../widgets/session_wise_batch_container.dart';
import '../widgets/image_slider_banner.dart'; // Import the fixed widget

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy list for demo
    final List<CourseItem> demoCourse = demoCourses;


    return SafeArea(
      child: Container(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Slider Banner at the top
              ImageSliderBanner(
                images: sliderImages,
                height: 240,
              ),

              const SizedBox(height: 8),


              AvailableCourseContainerWidget(
                title: "Batch Wise Preparation",
                courses: demoCourse,
                isBatch: true,
              ),

              const SizedBox(height: 8),

              AvailableCourseContainerWidget(
                title: "Subject Wise Preparation",
                courses: demoCourse,
                isBatch: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}