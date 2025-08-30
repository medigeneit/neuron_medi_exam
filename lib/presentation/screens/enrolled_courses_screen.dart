import 'package:flutter/material.dart';
import 'package:medi_exam/data/models/enrolled_course_item.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/enrolled_courses_card_widget.dart';

class EnrolledCoursesScreen extends StatefulWidget {
  const EnrolledCoursesScreen({super.key});

  @override
  State<EnrolledCoursesScreen> createState() => _EnrolledCoursesScreenState();
}

class _EnrolledCoursesScreenState extends State<EnrolledCoursesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'Enrolled Courses',
      body: Column(
        children: [
          // Custom Tab Bar with gradient background
          Container(
/*            decoration: BoxDecoration(
              gradient: AppColor.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),*/
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(6),
              labelColor: AppColor.primaryColor,
              unselectedLabelColor: AppColor.secondaryColor.withOpacity(0.7),
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Sizes.normalText(context),
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: Sizes.normalText(context),
              ),
              tabs: const [
                Tab(
                  text: 'Active',
                  icon: Icon(Icons.play_circle_fill_rounded, size: 20),
                ),
                Tab(
                  text: 'Unpaid',
                  icon: Icon(Icons.payment_rounded, size: 20),
                ),
                Tab(
                  text: 'Previous',
                  icon: Icon(Icons.history_rounded, size: 20),
                ),
              ],
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active Courses Tab
                _buildCourseList(
                  courses: DemoEnrolledCourses.activeCourses,
                  emptyMessage: 'No active courses found',
                  emptyIcon: Icons.play_circle_outline_rounded,
                ),

                // Unpaid Courses Tab
                _buildCourseList(
                  courses: DemoEnrolledCourses.unpaidCourses,
                  emptyMessage: 'No unpaid courses',
                  emptyIcon: Icons.payment_outlined,
                ),

                // Previous Courses Tab
                _buildCourseList(
                  courses: DemoEnrolledCourses.previousCourses,
                  emptyMessage: 'No previous courses',
                  emptyIcon: Icons.history_toggle_off_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList({
    required List<EnrolledCourseItem> courses,
    required String emptyMessage,
    required IconData emptyIcon,
  }) {
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: Sizes.bodyText(context),
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore our courses to get started',
              style: TextStyle(
                fontSize: Sizes.smallText(context),
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: EnrolledCourseCard(courseItem: course),
        );
      },
    );
  }
}