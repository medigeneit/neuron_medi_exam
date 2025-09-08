import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/courses_model.dart';
import 'package:medi_exam/data/services/all_batch_courses_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/courses_card_widget.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/widgets/show_disciplne_dialog.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final AllBatchCoursesService _service = AllBatchCoursesService();
  List<Course>? _courses;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBatchCourses();
  }

  Future<void> _fetchBatchCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _service.fetchAllBatchCourses();

    if (response.isSuccess && response.responseData is CoursesModel) {
      final allBatchCourses = response.responseData as CoursesModel;
      setState(() {
        _courses = allBatchCourses.courses;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.errorMessage ?? 'Failed to load courses';
        _isLoading = false;
        // ignore: avoid_print
        print('error: $_errorMessage');
      });
    }
  }

  Future<void> _retry() async {
    await _fetchBatchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              // _errorMessage!,
              'Try Again Later',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_courses == null || _courses!.isEmpty) {
      return const Center(
        child: Text(
          'No courses available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: const BoxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header section
              Text(
                'All Courses',
                style: TextStyle(
                  fontSize: Sizes.subTitleText(context),
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Explore our wide range of courses to enhance your knowledge',
                style: TextStyle(
                  fontSize: Sizes.normalText(context),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Give the GridView a bounded height using Expanded
        Expanded(
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
                itemCount: _courses!.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 items per row
                  crossAxisSpacing: gridSpacing,
                  mainAxisSpacing: gridSpacing,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final course = _courses![index];
                  return SizedBox(
                    width: itemWidth,
                    child: CoursesCardWidget(
                      title: course.courseName ?? 'Unnamed Course',
                      icon: Icons.menu_book_rounded,
                      onTap: () => showDisciplineDialog(
                        context,
                        course.courseName ?? 'Unknown Course',
                        Icons.school_rounded,
                        true,
                        course.package ?? [],
                      ),
                      onLearnMore: () => showDisciplineDialog(
                        context,
                        course.courseName ?? 'Unknown Course',
                        Icons.school_rounded,
                        true,
                        course.package ?? [],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
