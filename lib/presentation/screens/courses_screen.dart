import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/courses_model.dart';
import 'package:medi_exam/data/services/all_batch_courses_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
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
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _service.fetchAllBatchCourses();

      if (response.isSuccess && response.responseData is CoursesModel) {
        final model = response.responseData as CoursesModel;
        setState(() {
          _courses = model.courses ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.errorMessage ?? 'Failed to load courses';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _retry() async {
    await _fetchCourses();
  }

  // ✅ Centralized navigation logic for this screen
  void _handlePickedPackage({
    required bool isBatch,
    required String courseTitle,
    required IconData icon,
    required Package package,
  }) {

      Get.toNamed(
        RouteNames.session_wise_batches,
        arguments: {
          'courseTitle': courseTitle,
          'icon': icon,
          'title': package.packageName,
          'isBatch': isBatch,
          'coursePackageId': package.packageId,
        },
      );

  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Try Again Later',
              style: TextStyle(color: Colors.red),
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

    // ✅ This screen is "All Courses" => usually subject-wise
    // Change this to true if you want batch-wise behavior here.
    const bool isBatch = false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const horizontalPadding = 16.0;
              const gridSpacing = 12.0;

              final gridWidth = constraints.maxWidth - (horizontalPadding * 2);
              final itemWidth = (gridWidth - gridSpacing) / 2;

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  16,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: _courses!.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: gridSpacing,
                  mainAxisSpacing: gridSpacing,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final course = _courses![index];

                  void openDialog() {
                    showDisciplineDialog(
                      context,
                      courseTitle: course.courseName ?? 'Unknown Course',
                      courseIcon: Icons.school_rounded,
                      isBatch: isBatch,
                      packages: course.package ?? [],
                      onPicked: (pickedPackage) {
                        _handlePickedPackage(
                          isBatch: isBatch,
                          courseTitle: course.courseName ?? 'Unknown Course',
                          icon: Icons.school_rounded,
                          package: pickedPackage,
                        );
                      },
                    );
                  }

                  return SizedBox(
                    width: itemWidth,
                    child: CoursesCardWidget(
                      title: course.courseName ?? 'Unnamed Course',
                      icon: Icons.menu_book_rounded,
                      onTap: openDialog,
                      onLearnMore: openDialog,
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
